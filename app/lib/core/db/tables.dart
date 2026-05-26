import 'package:drift/drift.dart';

/// Paired wearable device. There is a single row per known device; a fresh
/// install starts with zero rows.
class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get hardwareId => text()(); // BLE device.remoteId
  IntColumn get pairedAtMs => integer()();
  IntColumn get lastSeenMs => integer().nullable()();
  TextColumn get firmwareVersion => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// PPG sample. Stored as a per-window row (not per individual sample) to
/// keep the DB small. The full raw waveform is in [rawWindow] for re-analysis.
class PpgSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().references(Devices, #id)();
  IntColumn get tsMs => integer()();
  RealColumn get hrBpm => real()(); // derived bpm
  RealColumn get spo2 => real().nullable()();

  /// Raw 25-Hz PPG window as float32 LE bytes (optional; downsampled after 7d).
  BlobColumn get rawWindow => blob().nullable()();
}

/// Skin temperature reading.
class TempSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().references(Devices, #id)();
  IntColumn get tsMs => integer()();
  RealColumn get celsius => real()();
}

/// IMU sample. Stored at ~25 Hz, used for activity classification.
class ImuSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text().references(Devices, #id)();
  IntColumn get tsMs => integer()();
  RealColumn get ax => real()();
  RealColumn get ay => real()();
  RealColumn get az => real()();
  RealColumn get gx => real()();
  RealColumn get gy => real()();
  RealColumn get gz => real()();

  /// Activity label assigned by the on-device classifier:
  /// 0=resting 1=walking 2=running 3=other
  IntColumn get activity => integer().withDefault(const Constant(0))();
}

/// Per-window feature vector - the input to the anomaly detection model.
/// Persisted so we can re-score windows after the model is updated.
class FeatureRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get tsMs => integer()();
  IntColumn get windowS => integer().withDefault(const Constant(30))();

  RealColumn get hrMean => real()();
  RealColumn get hrStd => real()();
  RealColumn get hrMin => real()();
  RealColumn get hrMax => real()();
  RealColumn get rmssd => real()();
  RealColumn get pnn50 => real()();
  RealColumn get spo2Mean => real().nullable()();
  RealColumn get tempMean => real()();
  RealColumn get tempSlope => real()();
  RealColumn get accelMean => real()();
  RealColumn get accelStd => real()();
  IntColumn get activity => integer()();

  /// Anomaly probability output by the on-device model in [0, 1].
  RealColumn get anomalyP => real().nullable()();
}

/// Persisted alert.
@DataClassName('AnomalyRow')
class Anomalies extends Table {
  TextColumn get id => text()();
  IntColumn get tsMs => integer()();
  IntColumn get severity => integer()(); // 0 LOW, 1 MEDIUM, 2 HIGH
  TextColumn get type =>
      text()(); // tachycardia, bradycardia, hypoxia, fever, fall, model
  TextColumn get explanation => text().nullable()();
  TextColumn get guidance => text().nullable()();

  /// Snapshot of metrics at fire-time (JSON-encoded map).
  TextColumn get metricsJson => text()();
  IntColumn get dismissedAtMs => integer().nullable()();
  BoolColumn get markedNotAnomalous =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Welford running statistics keyed by metric × time-of-day × activity.
/// Accumulated lazily as samples flow in.
class BaselineStats extends Table {
  TextColumn get metric => text()(); // 'hr', 'spo2', 'temp', 'rmssd' …
  IntColumn get bucketTod =>
      integer()(); // 0=morning, 1=afternoon, 2=evening, 3=night
  IntColumn get bucketActivity => integer()(); // 0=rest 1=walk 2=run 3=other
  IntColumn get n => integer().withDefault(const Constant(0))();
  RealColumn get mean => real().withDefault(const Constant(0))();
  RealColumn get m2 => real().withDefault(const Constant(0))(); // Welford M2
  RealColumn get minVal => real()();
  RealColumn get maxVal => real()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {metric, bucketTod, bucketActivity};
}

/// Chat message inside an LLM conversation. Sessions are grouped by [sessionId].
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  IntColumn get tsMs => integer()();
  IntColumn get role => integer()(); // 0=user 1=assistant 2=system
  TextColumn get content => text()();

  /// Anomaly id this message is contextually about, if any (for "explain" flow).
  TextColumn get anomalyId => text().nullable()();
}

/// Owner profile. Single row (id = 1).
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get name => text()();
  TextColumn get username => text().nullable()();
  IntColumn get sex => integer()(); // 0 unspecified, 1 male, 2 female, 3 other
  IntColumn get birthYear => integer()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get conditionsJson => text().withDefault(const Constant('[]'))();
  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
