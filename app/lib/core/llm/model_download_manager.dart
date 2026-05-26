import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

/// Model bundle the app downloads when the user enables richer local chat.
class ModelBundle {
  const ModelBundle({
    required this.name,
    required this.url,
    required this.sizeBytes,
    required this.sha256,
    this.notes = '',
  });

  final String name;
  final String url;
  final int sizeBytes;
  final String sha256;
  final String notes;

  static const edgeModel = ModelBundle(
    name: 'Offline edge model',
    // The URL is configurable to support a self-hosted mirror for offline
    // lab environments.
    url:
        'https://huggingface.co/google/gemma-3-1b-it-qat-q4_0-gguf/resolve/main/gemma-3-1b-it-q4_0.gguf',
    sizeBytes: 720 * 1024 * 1024,
    sha256: '', // empty = skip integrity check (set when self-hosting).
    notes: 'Runs locally after a one-time download.',
  );
}

enum DownloadState { idle, downloading, paused, complete, failed }

class DownloadProgress {
  const DownloadProgress({
    required this.state,
    required this.received,
    required this.total,
    this.error,
  });
  final DownloadState state;
  final int received;
  final int total;
  final String? error;

  double get fraction => total == 0 ? 0 : (received / total).clamp(0.0, 1.0);
}

/// Resumable downloader with SHA-256 verify. Writes to `<docs>/<bundle>.bin`.
/// Re-running from a partial file uses an HTTP Range header.
class ModelDownloadManager {
  ModelBundle bundle = ModelBundle.edgeModel;

  final _progress = StreamController<DownloadProgress>.broadcast();
  Stream<DownloadProgress> get progress$ => _progress.stream;
  DownloadProgress _last = const DownloadProgress(
    state: DownloadState.idle,
    received: 0,
    total: 0,
  );
  DownloadProgress get progress => _last;

  http.Client? _client;
  IOSink? _sink;

  Future<File> get localFile async {
    final docs = await getApplicationDocumentsDirectory();
    return File(p.join(docs.path, 'llm', _safeFilename()));
  }

  String _safeFilename() {
    final b = bundle.name.replaceAll(RegExp(r'[^A-Za-z0-9_.-]+'), '_');
    return '$b.bin';
  }

  Future<bool> isInstalled() async {
    final f = await localFile;
    return await f.exists() && (await f.length()) >= bundle.sizeBytes - 1024;
  }

  Future<void> start() async {
    if (_last.state == DownloadState.downloading) return;
    final f = await localFile;
    if (!await f.parent.exists()) await f.parent.create(recursive: true);
    final start = await f.exists() ? await f.length() : 0;

    _client = http.Client();
    final req = http.Request('GET', Uri.parse(bundle.url));
    if (start > 0) req.headers['Range'] = 'bytes=$start-';

    try {
      final res = await _client!.send(req);
      if (res.statusCode != 200 && res.statusCode != 206) {
        _emit(state: DownloadState.failed, error: 'HTTP ${res.statusCode}');
        return;
      }
      final total = (res.contentLength ?? 0) + start;
      _sink = f.openWrite(mode: start > 0 ? FileMode.append : FileMode.write);
      var received = start;
      _emit(state: DownloadState.downloading, received: received, total: total);

      await for (final chunk in res.stream) {
        _sink!.add(chunk);
        received += chunk.length;
        if (received - _last.received > 256 * 1024) {
          _emit(
            state: DownloadState.downloading,
            received: received,
            total: total,
          );
        }
      }
      await _sink!.flush();
      await _sink!.close();
      _sink = null;

      // Optional integrity check.
      if (bundle.sha256.isNotEmpty) {
        final ok = await _verifyHash(f);
        if (!ok) {
          _emit(state: DownloadState.failed, error: 'Checksum mismatch');
          await f.delete();
          return;
        }
      }
      _emit(state: DownloadState.complete, received: received, total: total);
    } catch (e) {
      log.e('Download failed', error: e);
      _emit(state: DownloadState.failed, error: e.toString());
    } finally {
      _client?.close();
      _client = null;
    }
  }

  Future<void> pause() async {
    _client?.close();
    _client = null;
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
    _emit(state: DownloadState.paused);
  }

  Future<void> delete() async {
    final f = await localFile;
    if (await f.exists()) await f.delete();
    _emit(state: DownloadState.idle, received: 0, total: 0);
  }

  Future<bool> _verifyHash(File f) async {
    final stream = f.openRead();
    final digest = await sha256.bind(stream).first;
    final hex = digest.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return hex == bundle.sha256.toLowerCase();
  }

  void _emit({DownloadState? state, int? received, int? total, String? error}) {
    _last = DownloadProgress(
      state: state ?? _last.state,
      received: received ?? _last.received,
      total: total ?? _last.total,
      error: error,
    );
    _progress.add(_last);
  }

  Future<String?> manifestJson() async {
    if (!await isInstalled()) return null;
    final f = await localFile;
    return jsonEncode({
      'name': bundle.name,
      'path': f.path,
      'sizeBytes': await f.length(),
    });
  }
}
