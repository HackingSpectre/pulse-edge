import 'package:drift/drift.dart';

import 'database.dart';
import '../ml/feature_window.dart';

/// Thin domain wrappers around the drift DAOs. The rest of the app should
/// use these — never reach into [AppDb] directly from feature code.
class SensorRepo {
  SensorRepo(this._db);
  final AppDb _db;

  Future<void> insertPpg({
    required String deviceId,
    required int tsMs,
    required double hrBpm,
    double? spo2,
    Uint8List? rawWindow,
  }) {
    return _db
        .into(_db.ppgSamples)
        .insert(
          PpgSamplesCompanion(
            deviceId: Value(deviceId),
            tsMs: Value(tsMs),
            hrBpm: Value(hrBpm),
            spo2: Value(spo2),
            rawWindow: Value(rawWindow),
          ),
        );
  }

  Future<void> insertTemp({
    required String deviceId,
    required int tsMs,
    required double celsius,
  }) {
    return _db
        .into(_db.tempSamples)
        .insert(
          TempSamplesCompanion(
            deviceId: Value(deviceId),
            tsMs: Value(tsMs),
            celsius: Value(celsius),
          ),
        );
  }

  Future<void> insertImu({
    required String deviceId,
    required int tsMs,
    required double ax,
    required double ay,
    required double az,
    required double gx,
    required double gy,
    required double gz,
    int activity = 0,
  }) {
    return _db
        .into(_db.imuSamples)
        .insert(
          ImuSamplesCompanion(
            deviceId: Value(deviceId),
            tsMs: Value(tsMs),
            ax: Value(ax),
            ay: Value(ay),
            az: Value(az),
            gx: Value(gx),
            gy: Value(gy),
            gz: Value(gz),
            activity: Value(activity),
          ),
        );
  }

  /// Bulk insert helper called by the BLE service every ~200 ms.
  Future<void> insertPpgBatch(List<PpgSamplesCompanion> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((b) => b.insertAll(_db.ppgSamples, rows));
  }

  Future<void> insertImuBatch(List<ImuSamplesCompanion> rows) async {
    if (rows.isEmpty) return;
    await _db.batch((b) => b.insertAll(_db.imuSamples, rows));
  }

  Stream<List<PpgSample>> watchRecentPpg({
    Duration window = const Duration(minutes: 1),
  }) {
    return (_db.select(_db.ppgSamples)
          ..orderBy([(t) => OrderingTerm.desc(t.tsMs)])
          ..limit(240))
        .watch()
        .map((rows) {
          final cutoff = DateTime.now().subtract(window).millisecondsSinceEpoch;
          return rows.where((r) => r.tsMs >= cutoff).toList().reversed.toList();
        });
  }

  Stream<PpgSample?> watchLatestPpg() {
    return (_db.select(_db.ppgSamples)
          ..orderBy([(t) => OrderingTerm.desc(t.tsMs)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<TempSample?> watchLatestTemp() {
    return (_db.select(_db.tempSamples)
          ..orderBy([(t) => OrderingTerm.desc(t.tsMs)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<ImuSample?> watchLatestImu() {
    return (_db.select(_db.imuSamples)
          ..orderBy([(t) => OrderingTerm.desc(t.tsMs)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<PpgSample>> ppgInRange(int fromMs, int toMs) {
    return (_db.select(_db.ppgSamples)
          ..where((t) => t.tsMs.isBetweenValues(fromMs, toMs))
          ..orderBy([(t) => OrderingTerm.asc(t.tsMs)]))
        .get();
  }

  Future<List<TempSample>> tempInRange(int fromMs, int toMs) {
    return (_db.select(_db.tempSamples)
          ..where((t) => t.tsMs.isBetweenValues(fromMs, toMs))
          ..orderBy([(t) => OrderingTerm.asc(t.tsMs)]))
        .get();
  }

  Future<List<ImuSample>> imuInRange(int fromMs, int toMs) {
    return (_db.select(_db.imuSamples)
          ..where((t) => t.tsMs.isBetweenValues(fromMs, toMs))
          ..orderBy([(t) => OrderingTerm.asc(t.tsMs)]))
        .get();
  }

  /// Compact older raw windows. Called periodically.
  Future<void> compactOlderThan(Duration age) async {
    final cutoff = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await _db.customStatement(
      'UPDATE ppg_samples SET raw_window = NULL WHERE ts_ms < ?',
      [cutoff],
    );
  }
}

class FeatureRepo {
  FeatureRepo(this._db);
  final AppDb _db;

  Future<void> insertWindow(FeatureWindow w, {required double anomalyP}) {
    return _db
        .into(_db.featureRows)
        .insert(
          FeatureRowsCompanion(
            tsMs: Value(w.tsMs),
            windowS: Value(w.windowS),
            hrMean: Value(w.hrMean),
            hrStd: Value(w.hrStd),
            hrMin: Value(w.hrMin),
            hrMax: Value(w.hrMax),
            rmssd: Value(w.rmssd),
            pnn50: Value(w.pnn50),
            spo2Mean: Value(w.spo2Mean),
            tempMean: Value(w.tempMean),
            tempSlope: Value(w.tempSlope),
            accelMean: Value(w.accelMean),
            accelStd: Value(w.accelStd),
            activity: Value(w.activity),
            anomalyP: Value(anomalyP),
          ),
        );
  }
}

class AnomalyRepo {
  AnomalyRepo(this._db);
  final AppDb _db;

  Future<void> upsert(AnomaliesCompanion row) =>
      _db.into(_db.anomalies).insertOnConflictUpdate(row);

  Stream<List<AnomalyRow>> watchAll({int limit = 200}) {
    return (_db.select(_db.anomalies)
          ..orderBy([(t) => OrderingTerm.desc(t.tsMs)])
          ..limit(limit))
        .watch();
  }

  Stream<int> watchUnreadCount() {
    return _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM anomalies WHERE dismissed_at_ms IS NULL',
        )
        .watchSingle()
        .map((row) => row.read<int>('c'));
  }

  Future<AnomalyRow?> byId(String id) {
    return (_db.select(
      _db.anomalies,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<AnomalyRow>> recentSince(int fromMs) {
    return (_db.select(_db.anomalies)
          ..where((t) => t.tsMs.isBiggerOrEqualValue(fromMs))
          ..orderBy([(t) => OrderingTerm.desc(t.tsMs)]))
        .get();
  }

  Future<void> dismiss(String id, {bool markNotAnomalous = false}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.anomalies)..where((t) => t.id.equals(id))).write(
      AnomaliesCompanion(
        dismissedAtMs: Value(now),
        markedNotAnomalous: Value(markNotAnomalous),
      ),
    );
  }
}

class ProfileRepo {
  ProfileRepo(this._db);
  final AppDb _db;

  Future<Profile?> get() {
    return (_db.select(
      _db.profiles,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
  }

  Stream<Profile?> watch() {
    return (_db.select(
      _db.profiles,
    )..where((t) => t.id.equals(1))).watchSingleOrNull();
  }

  Future<void> save(ProfilesCompanion data) async {
    await _db
        .into(_db.profiles)
        .insertOnConflictUpdate(data.copyWith(id: const Value(1)));
  }
}

class DeviceRepo {
  DeviceRepo(this._db);
  final AppDb _db;

  Future<void> savePaired({
    required String id,
    required String name,
    required String hardwareId,
    String? firmwareVersion,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db
        .into(_db.devices)
        .insertOnConflictUpdate(
          DevicesCompanion(
            id: Value(id),
            name: Value(name),
            hardwareId: Value(hardwareId),
            pairedAtMs: Value(now),
            lastSeenMs: Value(now),
            firmwareVersion: Value(firmwareVersion),
          ),
        );
  }

  Stream<Device?> watchPaired() {
    return (_db.select(_db.devices)
          ..where((t) => t.id.equals('mock-device-0001').not())
          ..orderBy([(t) => OrderingTerm.desc(t.pairedAtMs)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<void> ensureDevice({
    required String id,
    required String name,
    required String hardwareId,
    String? firmwareVersion,
  }) async {
    final existing = await (_db.select(
      _db.devices,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing != null) return;
    await savePaired(
      id: id,
      name: name,
      hardwareId: hardwareId,
      firmwareVersion: firmwareVersion,
    );
  }

  Future<void> forget() async {
    await _db.delete(_db.devices).go();
  }

  Future<void> bumpLastSeen(String id) async {
    await (_db.update(_db.devices)..where((t) => t.id.equals(id))).write(
      DevicesCompanion(
        lastSeenMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}

class ChatRepo {
  ChatRepo(this._db);
  final AppDb _db;

  Future<void> insert({
    required String sessionId,
    required int role,
    required String content,
    String? anomalyId,
  }) {
    return _db
        .into(_db.chatMessages)
        .insert(
          ChatMessagesCompanion(
            sessionId: Value(sessionId),
            tsMs: Value(DateTime.now().millisecondsSinceEpoch),
            role: Value(role),
            content: Value(content),
            anomalyId: Value(anomalyId),
          ),
        );
  }

  Stream<List<ChatMessage>> watchSession(String sessionId) {
    return (_db.select(_db.chatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.tsMs)]))
        .watch();
  }

  Future<void> clearSession(String sessionId) async {
    await (_db.delete(
      _db.chatMessages,
    )..where((t) => t.sessionId.equals(sessionId))).go();
  }
}
