import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/logger.dart';
import 'feature_window.dart';

/// On-device anomaly detector.
///
/// Loads a TFLite classifier from assets/models/anomaly.tflite — if absent
/// (development build), falls back to a deterministic heuristic so the
/// pipeline still produces interpretable scores. The Python training
/// notebook in `/ml/anomaly/` produces the real model.
class AnomalyDetector {
  Interpreter? _interpreter;
  bool _initTried = false;
  late List<int> _inputShape;
  late int _outputLen;

  static const String _assetModel = 'assets/models/anomaly.tflite';
  static const String _localModel = 'anomaly.tflite';

  Future<void> _init() async {
    if (_initTried) return;
    _initTried = true;
    try {
      File? f;
      // Prefer a model copied from assets to app docs at first launch — keeps
      // the asset bundle small while still letting users replace the model.
      final docs = await getApplicationDocumentsDirectory();
      final local = File(p.join(docs.path, _localModel));
      if (await local.exists()) {
        f = local;
      } else {
        try {
          final bytes = await rootBundle.load(_assetModel);
          await local.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
          f = local;
        } catch (_) {
          // Asset not bundled — fall back to heuristic.
          log.w('No TFLite anomaly model bundled; using heuristic fallback.');
          return;
        }
      }
      _interpreter = Interpreter.fromFile(f);
      _inputShape = _interpreter!.getInputTensor(0).shape;
      _outputLen = _interpreter!.getOutputTensor(0).shape.reduce((a, b) => a * b);
      log.i('Anomaly model loaded; input=$_inputShape output=$_outputLen');
    } catch (e, st) {
      log.e('Failed to load anomaly model', error: e, stackTrace: st);
    }
  }

  /// Returns anomaly probability ∈ [0, 1]. Higher = more anomalous.
  Future<double> score(FeatureWindow w) async {
    await _init();
    if (_interpreter != null) {
      try {
        final input = w.toModelInput();
        // Reshape to model expectation (assumed [1, n] for v1 MLP).
        final shaped = [input];
        final out = List.filled(_outputLen, 0.0).reshape([1, _outputLen]);
        _interpreter!.run(shaped, out);
        final raw = (out[0][0] as num).toDouble();
        return raw.clamp(0.0, 1.0);
      } catch (e) {
        log.e('TFLite inference failed; falling back', error: e);
      }
    }
    return _heuristic(w);
  }

  /// Smooth, opinionated heuristic. Used until the TFLite model is dropped in.
  /// Mirrors the rough decision surface a 1D-CNN trained on WESAD produces.
  double _heuristic(FeatureWindow w) {
    final hrPenalty = _bell(w.hrMean, center: 72, sigma: 22);
    final hrvPenalty = w.rmssd < 18 ? (18 - w.rmssd) / 36 : 0.0;
    final tempPenalty = _bell(w.tempMean, center: 33.6, sigma: 1.4);
    final spo2 = w.spo2Mean ?? 98.0;
    final spo2Penalty = spo2 < 95 ? (95 - spo2) / 6 : 0.0;
    final activityPenalty = w.activity == 2 && w.hrMean > 175 ? 0.4 : 0.0;
    final raw = 0.40 * hrPenalty +
        0.18 * hrvPenalty +
        0.18 * tempPenalty +
        0.16 * spo2Penalty +
        0.08 * activityPenalty;
    return raw.clamp(0.0, 1.0);
  }

  /// 0 at center, → 1 as |x - center| grows past ~3σ.
  double _bell(double x, {required double center, required double sigma}) {
    final z = (x - center).abs() / sigma;
    if (z <= 1) return 0;
    return (1 - math.exp(-(z - 1) * (z - 1))).clamp(0.0, 1.0);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
