import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../alerts/alert_engine.dart';
import '../db/repositories.dart';
import '../ml/anomaly_detector.dart';
import '../ml/baseline_service.dart';
import '../ml/feature_extractor.dart';
import '../ml/feature_window.dart';
import '../profile/settings_store.dart';
import '../utils/logger.dart';
import 'ble_protocol.dart';
import 'connection_state.dart';
import 'mock_device_source.dart';
import 'sensor_packet.dart';

/// Top-level orchestrator that owns the BLE connection lifecycle and routes
/// decoded sensor frames into the storage + ML pipeline.
///
/// In demo mode (default until the user pairs a real device) the service
/// uses [MockDeviceSource] so the entire app — including charts, alerts,
/// chat context — works on an emulator with no wearable present.
class BleService {
  BleService({
    required this.settings,
    required this.sensorRepo,
    required this.featureRepo,
    required this.deviceRepo,
    required this.featureExtractor,
    required this.baseline,
    required this.detector,
    required this.alerts,
  }) {
    _attachExtractorPipeline();
  }

  final SettingsStore settings;
  final SensorRepo sensorRepo;
  final FeatureRepo featureRepo;
  final DeviceRepo deviceRepo;
  final FeatureExtractor featureExtractor;
  final BaselineService baseline;
  final AnomalyDetector detector;
  final AlertEngine alerts;

  static const String _mockDeviceId = 'mock-device-0001';

  final _statusSubject = BehaviorSubject<BleStatus>.seeded(BleStatus.idle);

  // Live latest values for the dashboard.
  final _liveHr = BehaviorSubject<double?>.seeded(null);
  final _liveSpo2 = BehaviorSubject<double?>.seeded(null);
  final _liveTemp = BehaviorSubject<double?>.seeded(null);
  final _liveActivity = BehaviorSubject<int>.seeded(0);
  final _liveImu = BehaviorSubject<ImuFrame?>.seeded(null);

  Stream<BleStatus> get status$ => _statusSubject.stream;
  BleStatus get status => _statusSubject.value;
  Stream<double?> get hr$ => _liveHr.stream;
  Stream<double?> get spo2$ => _liveSpo2.stream;
  Stream<double?> get temp$ => _liveTemp.stream;
  Stream<int> get activity$ => _liveActivity.stream;
  Stream<ImuFrame?> get imu$ => _liveImu.stream;

  MockDeviceSource? _mock;
  StreamSubscription<dynamic>? _ppgSub;
  StreamSubscription<dynamic>? _tempSub;
  StreamSubscription<dynamic>? _imuSub;
  StreamSubscription<dynamic>? _statusSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<FeatureWindow>? _featureSub;
  final List<StreamSubscription<List<int>>> _notifySubs = [];
  BluetoothDevice? _device;
  String _activeDeviceId = _mockDeviceId;
  int? _deviceEpochOffsetMs;
  Timer? _reconnectTimer;
  bool _intentionalStop = false;
  bool _connecting = false;

  bool get isDemo => _statusSubject.value.demo;

  // ─── public API ────────────────────────────────────────────────────────

  /// Start in demo mode using the mock device source.
  Future<void> startDemo() async {
    await stop();
    _intentionalStop = false;
    _activeDeviceId = _mockDeviceId;
    _deviceEpochOffsetMs = null;
    await deviceRepo.ensureDevice(
      id: _mockDeviceId,
      name: 'Demo Wearable',
      hardwareId: _mockDeviceId,
      firmwareVersion: '0.1 (mock)',
    );
    _mock = MockDeviceSource();
    _ppgSub = _mock!.ppg.listen(_onPpg);
    _tempSub = _mock!.temp.listen(_onTemp);
    _imuSub = _mock!.imu.listen(_onImu);
    _statusSub = _mock!.status.listen(_onStatus);
    _mock!.start();
    _statusSubject.add(
      BleStatus(
        state: BleConnState.connected,
        deviceName: 'Demo Wearable',
        batteryPct: 87,
        firmwareVersion: '0.1 (mock)',
        demo: true,
      ),
    );
  }

  /// Scan for advertising Pulse Edge wearables. Returns the first device
  /// matching our advertised name or primary service UUID.
  Stream<List<ScanResult>> scan({
    Duration timeout = const Duration(seconds: 8),
  }) async* {
    final needsLocation = await _needsLocationForBle();
    await _ensureBluetoothReady();
    await _ensureScanPermissions(needsLocation: needsLocation);
    await FlutterBluePlus.stopScan();
    _statusSubject.add(BleStatus(state: BleConnState.scanning));
    await FlutterBluePlus.startScan(
      withServices: [Guid(BleUuids.service)],
      withNames: [BleUuids.advName],
      timeout: timeout,
      removeIfGone: const Duration(seconds: 3),
      continuousUpdates: true,
      androidLegacy: true,
      androidUsesFineLocation: needsLocation,
    );
    yield* FlutterBluePlus.scanResults
        .map(_pulseEdgeResults)
        .takeUntil(Stream<void>.value(null).delay(timeout))
        .doOnDone(() => unawaited(stopScan()));
  }

  Future<bool> _needsLocationForBle() async {
    if (!Platform.isAndroid) return false;
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt <= 30;
  }

  Future<void> _ensureScanPermissions({required bool needsLocation}) async {
    if (!Platform.isAndroid) return;
    if (needsLocation) {
      final status = await Permission.location.request();
      if (!status.isGranted && !status.isLimited) {
        throw StateError('Missing Bluetooth scan permission: location');
      }
      return;
    }
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    final scan = statuses[Permission.bluetoothScan];
    final connect = statuses[Permission.bluetoothConnect];
    final granted = scan?.isGranted == true && connect?.isGranted == true;
    if (!granted) {
      throw StateError('Missing Bluetooth scan permission: bluetooth');
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Connect to a real wearable.
  Future<void> connect(BluetoothDevice device) async {
    if (_connecting) return;
    _connecting = true;
    await stop();
    _intentionalStop = false;
    await stopScan();
    _device = device;
    _activeDeviceId = device.remoteId.str;
    _deviceEpochOffsetMs = null;
    final deviceName = _displayName(device);
    _statusSubject.add(
      BleStatus(state: BleConnState.connecting, deviceName: deviceName),
    );

    try {
      await _ensureBluetoothReady();
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 18),
        mtu: 247,
        license: License
            .free, // Educational use — see flutter_blue_plus License enum.
      );
      await deviceRepo.savePaired(
        id: _activeDeviceId,
        name: deviceName,
        hardwareId: device.remoteId.str,
      );
      _connSub = device.connectionState.listen(_onConnectionStateChanged);
      await _wirePulseEdge(device);
      _statusSubject.add(
        BleStatus(
          state: BleConnState.connected,
          deviceName: deviceName,
          demo: false,
        ),
      );
    } on Object catch (e) {
      log.e('connect failed', error: e);
      _statusSubject.add(
        BleStatus(state: BleConnState.error, lastError: e.toString()),
      );
      try {
        await device.disconnect(queue: false);
      } catch (_) {}
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  Future<void> sendVibrate(int pattern) async {
    if (_device == null) return;
    final services = await _device!.discoverServices();
    final svc = services.firstWhere(
      (s) => s.uuid.str.toLowerCase() == BleUuids.service,
    );
    final c = svc.characteristics.firstWhere(
      (c) => c.uuid.str.toLowerCase() == BleUuids.charVibrate,
    );
    await c.write([pattern], withoutResponse: true);
  }

  Future<void> stop() async {
    _intentionalStop = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    for (final sub in _notifySubs) {
      await sub.cancel();
    }
    _notifySubs.clear();
    await _ppgSub?.cancel();
    await _tempSub?.cancel();
    await _imuSub?.cancel();
    await _statusSub?.cancel();
    await _connSub?.cancel();
    _ppgSub = null;
    _tempSub = null;
    _imuSub = null;
    _statusSub = null;
    _connSub = null;
    _deviceEpochOffsetMs = null;
    if (_mock != null) {
      await _mock!.dispose();
      _mock = null;
    }
    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
      _device = null;
    }
    _statusSubject.add(BleStatus(state: BleConnState.idle));
  }

  Future<void> dispose() async {
    await stop();
    await _featureSub?.cancel();
    await _statusSubject.close();
    await _liveHr.close();
    await _liveSpo2.close();
    await _liveTemp.close();
    await _liveActivity.close();
    await _liveImu.close();
  }

  // ─── frame handlers ────────────────────────────────────────────────────

  void _onPpg(PpgFrame f) {
    if (!f.hrBpm.isFinite || f.hrBpm < 25 || f.hrBpm > 240) return;
    final normalized = PpgFrame(
      seq: f.seq,
      tsMs: _normalizeTimestamp(f.tsMs),
      hrBpm: f.hrBpm,
      spo2: f.spo2 != null && f.spo2!.isFinite ? f.spo2 : null,
      samples: f.samples,
    );
    _liveHr.add(normalized.hrBpm);
    if (normalized.spo2 != null) _liveSpo2.add(normalized.spo2);
    unawaited(
      sensorRepo
          .insertPpg(
            deviceId: _activeDeviceId,
            tsMs: normalized.tsMs,
            hrBpm: normalized.hrBpm,
            spo2: normalized.spo2,
            rawWindow: int16ListToBytes(normalized.samples),
          )
          .catchError((Object e, StackTrace st) {
            log.e('failed to persist PPG frame', error: e, stackTrace: st);
          }),
    );
    featureExtractor.addPpg(normalized);
  }

  void _onTemp(TempFrame f) {
    if (!f.celsius.isFinite || f.celsius < -20 || f.celsius > 80) return;
    final normalized = TempFrame(
      tsMs: _normalizeTimestamp(f.tsMs),
      celsius: f.celsius,
    );
    _liveTemp.add(normalized.celsius);
    unawaited(
      sensorRepo
          .insertTemp(
            deviceId: _activeDeviceId,
            tsMs: normalized.tsMs,
            celsius: normalized.celsius,
          )
          .catchError((Object e, StackTrace st) {
            log.e(
              'failed to persist temperature frame',
              error: e,
              stackTrace: st,
            );
          }),
    );
    featureExtractor.addTemp(normalized);
  }

  void _onImu(ImuFrame f) {
    if (!_finiteAll([f.ax, f.ay, f.az, f.gx, f.gy, f.gz])) return;
    final normalized = ImuFrame(
      tsMs: _normalizeTimestamp(f.tsMs),
      ax: f.ax,
      ay: f.ay,
      az: f.az,
      gx: f.gx,
      gy: f.gy,
      gz: f.gz,
      magnitudeMean: f.magnitudeMean,
      magnitudeStd: f.magnitudeStd,
    );
    _liveImu.add(normalized);
    unawaited(
      sensorRepo
          .insertImu(
            deviceId: _activeDeviceId,
            tsMs: normalized.tsMs,
            ax: normalized.ax,
            ay: normalized.ay,
            az: normalized.az,
            gx: normalized.gx,
            gy: normalized.gy,
            gz: normalized.gz,
          )
          .catchError((Object e, StackTrace st) {
            log.e('failed to persist IMU frame', error: e, stackTrace: st);
          }),
    );
    featureExtractor.addImu(normalized);
  }

  void _onStatus(StatusFrame f) {
    _liveActivity.add(_liveActivity.value); // touch
    _statusSubject.add(
      _statusSubject.value.copyWith(
        batteryPct: f.batteryPct,
        firmwareVersion: f.fwVersion,
        sensorOk: f.sensorOk,
        contactOk: f.demoMode ? null : f.contactOk,
        lastSeenMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    unawaited(
      deviceRepo.bumpLastSeen(_activeDeviceId).catchError((Object _) {}),
    );
  }

  void _onConnectionStateChanged(BluetoothConnectionState s) {
    if (s == BluetoothConnectionState.disconnected && !_intentionalStop) {
      _statusSubject.add(
        _statusSubject.value.copyWith(state: BleConnState.reconnecting),
      );
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () async {
      final d = _device;
      if (d == null) return;
      try {
        await d.connect(
          autoConnect: false,
          timeout: const Duration(seconds: 12),
          mtu: 247,
          license: License.free,
        );
        _deviceEpochOffsetMs = null;
        await _wirePulseEdge(d);
        _statusSubject.add(
          _statusSubject.value.copyWith(
            state: BleConnState.connected,
            deviceName: _displayName(d),
          ),
        );
      } catch (e) {
        log.w('reconnect attempt failed: $e');
        _scheduleReconnect();
      }
    });
  }

  // ─── feature pipeline ──────────────────────────────────────────────────

  void _attachExtractorPipeline() {
    _featureSub = featureExtractor.windowStream.listen((vec) async {
      try {
        _liveActivity.add(vec.activity);
        await baseline.update(vec);
        final p = await detector.score(vec);
        await featureRepo.insertWindow(vec, anomalyP: p);
        await alerts.evaluate(vec, modelP: p);
      } catch (e, st) {
        log.e('feature pipeline failed', error: e, stackTrace: st);
      }
    });
  }

  Future<void> _ensureBluetoothReady() async {
    final supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      throw StateError('Bluetooth LE is not supported on this device.');
    }
    final state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.on) return;
    try {
      await FlutterBluePlus.turnOn(timeout: 12);
    } catch (_) {
      throw StateError('Turn Bluetooth on, then scan again.');
    }
  }

  List<ScanResult> _pulseEdgeResults(List<ScanResult> results) {
    final service = Guid(BleUuids.service);
    final filtered = results.where((r) {
      final name = r.advertisementData.advName.isNotEmpty
          ? r.advertisementData.advName
          : _displayName(r.device);
      return name == BleUuids.advName ||
          r.advertisementData.serviceUuids.any((uuid) => uuid == service);
    }).toList()..sort((a, b) => b.rssi.compareTo(a.rssi));
    return filtered;
  }

  Future<void> _wirePulseEdge(BluetoothDevice device) async {
    for (final sub in _notifySubs) {
      await sub.cancel();
    }
    _notifySubs.clear();

    final services = await device.discoverServices();
    final serviceIds = services
        .map((s) => s.uuid.str.toLowerCase())
        .toList(growable: false);
    log.d('BLE services: ${serviceIds.join(", ")}');
    final svc = services.firstWhere(
      (s) => s.uuid.str.toLowerCase() == BleUuids.service,
      orElse: () => throw StateError(
        'Pulse Edge service not found. Found: ${serviceIds.join(", ")}. '
        'Upload the PulseEdge firmware and scan again.',
      ),
    );

    final charIds = svc.characteristics
        .map((c) => c.uuid.str.toLowerCase())
        .toList(growable: false);
    log.d('Pulse Edge characteristics: ${charIds.join(", ")}');

    Future<void> wireNotify(
      String uuid,
      void Function(Uint8List) handler,
    ) async {
      final c = svc.characteristics.firstWhere(
        (c) => c.uuid.str.toLowerCase() == uuid,
        orElse: () =>
            throw StateError('Pulse Edge characteristic $uuid not found.'),
      );
      final sub = c.onValueReceived.listen((data) {
        if (data.isEmpty) return;
        handler(Uint8List.fromList(data));
      });
      _notifySubs.add(sub);
      await c.setNotifyValue(true, timeout: 8);
    }

    await wireNotify(BleUuids.charPpg, (b) {
      final f = PpgFrame.tryParse(b);
      if (f != null) _onPpg(f);
    });
    await wireNotify(BleUuids.charTemp, (b) {
      final f = TempFrame.tryParse(b);
      if (f != null) _onTemp(f);
    });
    await wireNotify(BleUuids.charImu, (b) {
      final f = ImuFrame.tryParse(b);
      if (f != null) _onImu(f);
    });
    await wireNotify(BleUuids.charStatus, (b) {
      final f = StatusFrame.tryParse(b);
      if (f != null) _onStatus(f);
    });
  }

  int _normalizeTimestamp(int tsMs) {
    const epochThreshold = 946684800000; // 2000-01-01 UTC.
    if (tsMs >= epochThreshold) return tsMs;
    _deviceEpochOffsetMs ??= DateTime.now().millisecondsSinceEpoch - tsMs;
    return _deviceEpochOffsetMs! + tsMs;
  }

  String _displayName(BluetoothDevice device) {
    if (device.platformName.isNotEmpty) return device.platformName;
    if (device.advName.isNotEmpty) return device.advName;
    return 'Pulse Edge';
  }

  bool _finiteAll(Iterable<double> values) => values.every((v) => v.isFinite);
}
