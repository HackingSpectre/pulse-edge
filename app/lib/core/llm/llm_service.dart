import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:rxdart/rxdart.dart';

import '../db/repositories.dart';
import '../utils/logger.dart';
import 'model_download_manager.dart';
import 'prompt_templates.dart';
import 'scripted_assistant.dart';

enum LlmStatus { uninitialized, loadingModel, ready, missingModel, failed }

class LlmService {
  LlmService({
    required this.sensorRepo,
    required this.anomalyRepo,
    required this.profileRepo,
    required this.download,
  });

  final SensorRepo sensorRepo;
  final AnomalyRepo anomalyRepo;
  final ProfileRepo profileRepo;
  final ModelDownloadManager download;

  final _status = BehaviorSubject<LlmStatus>.seeded(LlmStatus.uninitialized);
  Stream<LlmStatus> get status$ => _status.stream;
  LlmStatus get status => _status.value;

  InferenceModel? _model;
  InferenceChat? _chat;

  /// Try to load the local model. Safe to call repeatedly — only initialises
  /// once. If no model is on disk, status becomes [LlmStatus.missingModel].
  Future<void> ensureLoaded() async {
    if (_status.value == LlmStatus.ready ||
        _status.value == LlmStatus.loadingModel) {
      return;
    }
    final installed = await download.isInstalled();
    if (!installed) {
      _status.add(LlmStatus.missingModel);
      return;
    }
    _status.add(LlmStatus.loadingModel);
    try {
      final f = await download.localFile;
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
      ).fromFile(f.path).install();
      _model = await FlutterGemmaPlugin.instance.createModel(
        modelType: ModelType.gemmaIt,
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
      );
      _chat = await _model!.createChat(
        temperature: 0.7,
        topK: 40,
        randomSeed: 42,
      );
      _status.add(LlmStatus.ready);
    } catch (e, st) {
      log.e('LLM load failed', error: e, stackTrace: st);
      _status.add(LlmStatus.failed);
    }
  }

  /// Free chat. Yields the assistant message + an injected disclaimer.
  Stream<String> chat(String userMessage) async* {
    await ensureLoaded();
    if (_status.value != LlmStatus.ready) {
      final context = await _recentContext();
      yield ScriptedAssistant.reply(userMessage, context: context);
      yield Prompts.disclaimer;
      return;
    }
    try {
      await _chat!.addQueryChunk(Message.text(text: userMessage, isUser: true));
      // Stream tokens as they arrive — only TextResponse carries token text.
      await for (final r in _chat!.generateChatResponseAsync()) {
        if (r case TextResponse(:final token)) {
          yield token;
        }
      }
      yield Prompts.disclaimer;
    } catch (e) {
      log.e('chat failed', error: e);
      yield 'Sorry — I hit an error. Please try again.';
      yield Prompts.disclaimer;
    }
  }

  /// One-shot anomaly explanation. Returns the full text, never streams.
  Future<String> explainAnomaly({
    required String type,
    required String metricsJson,
  }) async {
    await ensureLoaded();
    if (_status.value != LlmStatus.ready) {
      return '${_scriptedExplain(type, metricsJson)}${Prompts.disclaimer}';
    }
    try {
      final session = await _model!.createSession();
      try {
        await session.addQueryChunk(
          Message.text(
            text: Prompts.explainAnomaly(type: type, metricsJson: metricsJson),
            isUser: true,
          ),
        );
        final response = await session.getResponse();
        return '$response${Prompts.disclaimer}';
      } finally {
        await session.close();
      }
    } catch (e) {
      log.e('explain failed', error: e);
      return '${_scriptedExplain(type, metricsJson)}${Prompts.disclaimer}';
    }
  }

  Future<String> dailySummary() async {
    final context = await _recentContext();
    final summary = context.shortSummary;
    final json = jsonEncode({'summary': summary});
    await ensureLoaded();
    if (_status.value != LlmStatus.ready) {
      return 'Today: $summary${Prompts.disclaimer}';
    }
    try {
      final session = await _model!.createSession();
      try {
        await session.addQueryChunk(
          Message.text(
            text: Prompts.dailySummary(metricsJson: json),
            isUser: true,
          ),
        );
        final response = await session.getResponse();
        return '$response${Prompts.disclaimer}';
      } finally {
        await session.close();
      }
    } catch (e) {
      log.e('summary failed', error: e);
      return 'Today: $summary${Prompts.disclaimer}';
    }
  }

  Future<HealthChatContext> _recentContext() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final yesterday = now - 24 * 60 * 60 * 1000;
    final ppg = await sensorRepo.ppgInRange(yesterday, now);
    final temps = await sensorRepo.tempInRange(yesterday, now);
    final imu = await sensorRepo.imuInRange(yesterday, now);
    final anomalies = await anomalyRepo.recentSince(yesterday);

    final hrs = ppg.map((s) => s.hrBpm).where((v) => v.isFinite).toList();
    final spo2 = ppg
        .map((s) => s.spo2)
        .whereType<double>()
        .where((v) => v.isFinite)
        .toList();
    final tempVals = temps
        .map((s) => s.celsius)
        .where((v) => v.isFinite)
        .toList();
    final motion = imu
        .map((s) {
          final mag = (s.ax * s.ax + s.ay * s.ay + s.az * s.az);
          return mag <= 0 ? null : mag;
        })
        .whereType<double>()
        .map((v) => math.sqrt(v) / 9.80665)
        .where((v) => v.isFinite)
        .toList();

    return HealthChatContext(
      sampleCount: ppg.length,
      hrMin: ScriptedAssistant.minOrNull(hrs),
      hrMedian: ScriptedAssistant.median(hrs),
      hrMax: ScriptedAssistant.maxOrNull(hrs),
      spo2Min: ScriptedAssistant.minOrNull(spo2),
      spo2Mean: ScriptedAssistant.mean(spo2),
      tempMean: ScriptedAssistant.mean(tempVals),
      tempMin: ScriptedAssistant.minOrNull(tempVals),
      tempMax: ScriptedAssistant.maxOrNull(tempVals),
      motionMean: ScriptedAssistant.mean(motion),
      recentHighAlerts: anomalies.where((a) => a.severity == 2).length,
      recentMediumAlerts: anomalies.where((a) => a.severity == 1).length,
    );
  }

  String _scriptedExplain(String type, String metricsJson) {
    return 'Pulse Edge spotted a $type pattern (${metricsJson.length > 80 ? "${metricsJson.substring(0, 80)}…" : metricsJson}). '
        'Sit, breathe slowly, and check again in a few minutes. If it persists, '
        'contact your doctor.';
  }

  Future<void> dispose() async {
    await _chat?.session.close();
    await _model?.close();
    await _status.close();
  }
}
