import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Devices,
    PpgSamples,
    TempSamples,
    ImuSamples,
    FeatureRows,
    Anomalies,
    BaselineStats,
    ChatMessages,
    Profiles,
  ],
)
class AppDb extends _$AppDb {
  AppDb() : super(_open());
  AppDb.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(profiles, profiles.username);
      }
    },
    beforeOpen: (details) async {
      // Sensible runtime knobs for time-series workloads.
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
      await customStatement('PRAGMA temp_store = MEMORY');
      await customStatement('PRAGMA mmap_size = 134217728'); // 128 MB
      // Indexes - drift creates the tables; we add hot-path indexes here.
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_ppg_ts ON ppg_samples (device_id, ts_ms)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_temp_ts ON temp_samples (device_id, ts_ms)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_imu_ts ON imu_samples (device_id, ts_ms)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_features_ts ON feature_rows (ts_ms)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_anomalies_ts ON anomalies (ts_ms)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_chat_session ON chat_messages (session_id, ts_ms)',
      );
    },
  );
}

QueryExecutor _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'pulse_edge.db');
    final f = File(path);
    if (!await f.parent.exists()) {
      await f.parent.create(recursive: true);
    }
    return NativeDatabase.createInBackground(
      f,
      logStatements: false,
      setup: (db) {
        // Foreign keys must be enabled per-connection in SQLite.
        db.execute('PRAGMA foreign_keys = ON');
      },
    );
  });
}

/// Time-of-day buckets used by the baseline service.
class TimeBuckets {
  static int forHour(int hour) {
    if (hour < 6) return 3; // night
    if (hour < 12) return 0; // morning
    if (hour < 18) return 1; // afternoon
    return 2; // evening
  }

  static String name(int bucket) =>
      const ['Morning', 'Afternoon', 'Evening', 'Night'][bucket];
}

class ActivityClass {
  static const int resting = 0;
  static const int walking = 1;
  static const int running = 2;
  static const int other = 3;

  static String name(int a) =>
      const ['Resting', 'Walking', 'Running', 'Other'][a.clamp(0, 3)];
}
