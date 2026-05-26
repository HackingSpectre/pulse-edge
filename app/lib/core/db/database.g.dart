// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hardwareIdMeta = const VerificationMeta(
    'hardwareId',
  );
  @override
  late final GeneratedColumn<String> hardwareId = GeneratedColumn<String>(
    'hardware_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtMsMeta = const VerificationMeta(
    'pairedAtMs',
  );
  @override
  late final GeneratedColumn<int> pairedAtMs = GeneratedColumn<int>(
    'paired_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMsMeta = const VerificationMeta(
    'lastSeenMs',
  );
  @override
  late final GeneratedColumn<int> lastSeenMs = GeneratedColumn<int>(
    'last_seen_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firmwareVersionMeta = const VerificationMeta(
    'firmwareVersion',
  );
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
    'firmware_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    hardwareId,
    pairedAtMs,
    lastSeenMs,
    firmwareVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hardware_id')) {
      context.handle(
        _hardwareIdMeta,
        hardwareId.isAcceptableOrUnknown(data['hardware_id']!, _hardwareIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hardwareIdMeta);
    }
    if (data.containsKey('paired_at_ms')) {
      context.handle(
        _pairedAtMsMeta,
        pairedAtMs.isAcceptableOrUnknown(
          data['paired_at_ms']!,
          _pairedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pairedAtMsMeta);
    }
    if (data.containsKey('last_seen_ms')) {
      context.handle(
        _lastSeenMsMeta,
        lastSeenMs.isAcceptableOrUnknown(
          data['last_seen_ms']!,
          _lastSeenMsMeta,
        ),
      );
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
        _firmwareVersionMeta,
        firmwareVersion.isAcceptableOrUnknown(
          data['firmware_version']!,
          _firmwareVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      hardwareId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hardware_id'],
      )!,
      pairedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paired_at_ms'],
      )!,
      lastSeenMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_ms'],
      ),
      firmwareVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmware_version'],
      ),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final String id;
  final String name;
  final String hardwareId;
  final int pairedAtMs;
  final int? lastSeenMs;
  final String? firmwareVersion;
  const Device({
    required this.id,
    required this.name,
    required this.hardwareId,
    required this.pairedAtMs,
    this.lastSeenMs,
    this.firmwareVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['hardware_id'] = Variable<String>(hardwareId);
    map['paired_at_ms'] = Variable<int>(pairedAtMs);
    if (!nullToAbsent || lastSeenMs != null) {
      map['last_seen_ms'] = Variable<int>(lastSeenMs);
    }
    if (!nullToAbsent || firmwareVersion != null) {
      map['firmware_version'] = Variable<String>(firmwareVersion);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      hardwareId: Value(hardwareId),
      pairedAtMs: Value(pairedAtMs),
      lastSeenMs: lastSeenMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenMs),
      firmwareVersion: firmwareVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(firmwareVersion),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      hardwareId: serializer.fromJson<String>(json['hardwareId']),
      pairedAtMs: serializer.fromJson<int>(json['pairedAtMs']),
      lastSeenMs: serializer.fromJson<int?>(json['lastSeenMs']),
      firmwareVersion: serializer.fromJson<String?>(json['firmwareVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'hardwareId': serializer.toJson<String>(hardwareId),
      'pairedAtMs': serializer.toJson<int>(pairedAtMs),
      'lastSeenMs': serializer.toJson<int?>(lastSeenMs),
      'firmwareVersion': serializer.toJson<String?>(firmwareVersion),
    };
  }

  Device copyWith({
    String? id,
    String? name,
    String? hardwareId,
    int? pairedAtMs,
    Value<int?> lastSeenMs = const Value.absent(),
    Value<String?> firmwareVersion = const Value.absent(),
  }) => Device(
    id: id ?? this.id,
    name: name ?? this.name,
    hardwareId: hardwareId ?? this.hardwareId,
    pairedAtMs: pairedAtMs ?? this.pairedAtMs,
    lastSeenMs: lastSeenMs.present ? lastSeenMs.value : this.lastSeenMs,
    firmwareVersion: firmwareVersion.present
        ? firmwareVersion.value
        : this.firmwareVersion,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      hardwareId: data.hardwareId.present
          ? data.hardwareId.value
          : this.hardwareId,
      pairedAtMs: data.pairedAtMs.present
          ? data.pairedAtMs.value
          : this.pairedAtMs,
      lastSeenMs: data.lastSeenMs.present
          ? data.lastSeenMs.value
          : this.lastSeenMs,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hardwareId: $hardwareId, ')
          ..write('pairedAtMs: $pairedAtMs, ')
          ..write('lastSeenMs: $lastSeenMs, ')
          ..write('firmwareVersion: $firmwareVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    hardwareId,
    pairedAtMs,
    lastSeenMs,
    firmwareVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.name == this.name &&
          other.hardwareId == this.hardwareId &&
          other.pairedAtMs == this.pairedAtMs &&
          other.lastSeenMs == this.lastSeenMs &&
          other.firmwareVersion == this.firmwareVersion);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> hardwareId;
  final Value<int> pairedAtMs;
  final Value<int?> lastSeenMs;
  final Value<String?> firmwareVersion;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.hardwareId = const Value.absent(),
    this.pairedAtMs = const Value.absent(),
    this.lastSeenMs = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String name,
    required String hardwareId,
    required int pairedAtMs,
    this.lastSeenMs = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       hardwareId = Value(hardwareId),
       pairedAtMs = Value(pairedAtMs);
  static Insertable<Device> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? hardwareId,
    Expression<int>? pairedAtMs,
    Expression<int>? lastSeenMs,
    Expression<String>? firmwareVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (hardwareId != null) 'hardware_id': hardwareId,
      if (pairedAtMs != null) 'paired_at_ms': pairedAtMs,
      if (lastSeenMs != null) 'last_seen_ms': lastSeenMs,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? hardwareId,
    Value<int>? pairedAtMs,
    Value<int?>? lastSeenMs,
    Value<String?>? firmwareVersion,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      hardwareId: hardwareId ?? this.hardwareId,
      pairedAtMs: pairedAtMs ?? this.pairedAtMs,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hardwareId.present) {
      map['hardware_id'] = Variable<String>(hardwareId.value);
    }
    if (pairedAtMs.present) {
      map['paired_at_ms'] = Variable<int>(pairedAtMs.value);
    }
    if (lastSeenMs.present) {
      map['last_seen_ms'] = Variable<int>(lastSeenMs.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('hardwareId: $hardwareId, ')
          ..write('pairedAtMs: $pairedAtMs, ')
          ..write('lastSeenMs: $lastSeenMs, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PpgSamplesTable extends PpgSamples
    with TableInfo<$PpgSamplesTable, PpgSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PpgSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _tsMsMeta = const VerificationMeta('tsMs');
  @override
  late final GeneratedColumn<int> tsMs = GeneratedColumn<int>(
    'ts_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hrBpmMeta = const VerificationMeta('hrBpm');
  @override
  late final GeneratedColumn<double> hrBpm = GeneratedColumn<double>(
    'hr_bpm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spo2Meta = const VerificationMeta('spo2');
  @override
  late final GeneratedColumn<double> spo2 = GeneratedColumn<double>(
    'spo2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawWindowMeta = const VerificationMeta(
    'rawWindow',
  );
  @override
  late final GeneratedColumn<Uint8List> rawWindow = GeneratedColumn<Uint8List>(
    'raw_window',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    tsMs,
    hrBpm,
    spo2,
    rawWindow,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ppg_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<PpgSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('ts_ms')) {
      context.handle(
        _tsMsMeta,
        tsMs.isAcceptableOrUnknown(data['ts_ms']!, _tsMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tsMsMeta);
    }
    if (data.containsKey('hr_bpm')) {
      context.handle(
        _hrBpmMeta,
        hrBpm.isAcceptableOrUnknown(data['hr_bpm']!, _hrBpmMeta),
      );
    } else if (isInserting) {
      context.missing(_hrBpmMeta);
    }
    if (data.containsKey('spo2')) {
      context.handle(
        _spo2Meta,
        spo2.isAcceptableOrUnknown(data['spo2']!, _spo2Meta),
      );
    }
    if (data.containsKey('raw_window')) {
      context.handle(
        _rawWindowMeta,
        rawWindow.isAcceptableOrUnknown(data['raw_window']!, _rawWindowMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PpgSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PpgSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      tsMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts_ms'],
      )!,
      hrBpm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_bpm'],
      )!,
      spo2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spo2'],
      ),
      rawWindow: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw_window'],
      ),
    );
  }

  @override
  $PpgSamplesTable createAlias(String alias) {
    return $PpgSamplesTable(attachedDatabase, alias);
  }
}

class PpgSample extends DataClass implements Insertable<PpgSample> {
  final int id;
  final String deviceId;
  final int tsMs;
  final double hrBpm;
  final double? spo2;

  /// Raw 25-Hz PPG window as float32 LE bytes (optional; downsampled after 7d).
  final Uint8List? rawWindow;
  const PpgSample({
    required this.id,
    required this.deviceId,
    required this.tsMs,
    required this.hrBpm,
    this.spo2,
    this.rawWindow,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['ts_ms'] = Variable<int>(tsMs);
    map['hr_bpm'] = Variable<double>(hrBpm);
    if (!nullToAbsent || spo2 != null) {
      map['spo2'] = Variable<double>(spo2);
    }
    if (!nullToAbsent || rawWindow != null) {
      map['raw_window'] = Variable<Uint8List>(rawWindow);
    }
    return map;
  }

  PpgSamplesCompanion toCompanion(bool nullToAbsent) {
    return PpgSamplesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      tsMs: Value(tsMs),
      hrBpm: Value(hrBpm),
      spo2: spo2 == null && nullToAbsent ? const Value.absent() : Value(spo2),
      rawWindow: rawWindow == null && nullToAbsent
          ? const Value.absent()
          : Value(rawWindow),
    );
  }

  factory PpgSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PpgSample(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      tsMs: serializer.fromJson<int>(json['tsMs']),
      hrBpm: serializer.fromJson<double>(json['hrBpm']),
      spo2: serializer.fromJson<double?>(json['spo2']),
      rawWindow: serializer.fromJson<Uint8List?>(json['rawWindow']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'tsMs': serializer.toJson<int>(tsMs),
      'hrBpm': serializer.toJson<double>(hrBpm),
      'spo2': serializer.toJson<double?>(spo2),
      'rawWindow': serializer.toJson<Uint8List?>(rawWindow),
    };
  }

  PpgSample copyWith({
    int? id,
    String? deviceId,
    int? tsMs,
    double? hrBpm,
    Value<double?> spo2 = const Value.absent(),
    Value<Uint8List?> rawWindow = const Value.absent(),
  }) => PpgSample(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    tsMs: tsMs ?? this.tsMs,
    hrBpm: hrBpm ?? this.hrBpm,
    spo2: spo2.present ? spo2.value : this.spo2,
    rawWindow: rawWindow.present ? rawWindow.value : this.rawWindow,
  );
  PpgSample copyWithCompanion(PpgSamplesCompanion data) {
    return PpgSample(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tsMs: data.tsMs.present ? data.tsMs.value : this.tsMs,
      hrBpm: data.hrBpm.present ? data.hrBpm.value : this.hrBpm,
      spo2: data.spo2.present ? data.spo2.value : this.spo2,
      rawWindow: data.rawWindow.present ? data.rawWindow.value : this.rawWindow,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PpgSample(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsMs: $tsMs, ')
          ..write('hrBpm: $hrBpm, ')
          ..write('spo2: $spo2, ')
          ..write('rawWindow: $rawWindow')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    tsMs,
    hrBpm,
    spo2,
    $driftBlobEquality.hash(rawWindow),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PpgSample &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.tsMs == this.tsMs &&
          other.hrBpm == this.hrBpm &&
          other.spo2 == this.spo2 &&
          $driftBlobEquality.equals(other.rawWindow, this.rawWindow));
}

class PpgSamplesCompanion extends UpdateCompanion<PpgSample> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<int> tsMs;
  final Value<double> hrBpm;
  final Value<double?> spo2;
  final Value<Uint8List?> rawWindow;
  const PpgSamplesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tsMs = const Value.absent(),
    this.hrBpm = const Value.absent(),
    this.spo2 = const Value.absent(),
    this.rawWindow = const Value.absent(),
  });
  PpgSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required int tsMs,
    required double hrBpm,
    this.spo2 = const Value.absent(),
    this.rawWindow = const Value.absent(),
  }) : deviceId = Value(deviceId),
       tsMs = Value(tsMs),
       hrBpm = Value(hrBpm);
  static Insertable<PpgSample> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<int>? tsMs,
    Expression<double>? hrBpm,
    Expression<double>? spo2,
    Expression<Uint8List>? rawWindow,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (tsMs != null) 'ts_ms': tsMs,
      if (hrBpm != null) 'hr_bpm': hrBpm,
      if (spo2 != null) 'spo2': spo2,
      if (rawWindow != null) 'raw_window': rawWindow,
    });
  }

  PpgSamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<int>? tsMs,
    Value<double>? hrBpm,
    Value<double?>? spo2,
    Value<Uint8List?>? rawWindow,
  }) {
    return PpgSamplesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsMs: tsMs ?? this.tsMs,
      hrBpm: hrBpm ?? this.hrBpm,
      spo2: spo2 ?? this.spo2,
      rawWindow: rawWindow ?? this.rawWindow,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tsMs.present) {
      map['ts_ms'] = Variable<int>(tsMs.value);
    }
    if (hrBpm.present) {
      map['hr_bpm'] = Variable<double>(hrBpm.value);
    }
    if (spo2.present) {
      map['spo2'] = Variable<double>(spo2.value);
    }
    if (rawWindow.present) {
      map['raw_window'] = Variable<Uint8List>(rawWindow.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PpgSamplesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsMs: $tsMs, ')
          ..write('hrBpm: $hrBpm, ')
          ..write('spo2: $spo2, ')
          ..write('rawWindow: $rawWindow')
          ..write(')'))
        .toString();
  }
}

class $TempSamplesTable extends TempSamples
    with TableInfo<$TempSamplesTable, TempSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TempSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _tsMsMeta = const VerificationMeta('tsMs');
  @override
  late final GeneratedColumn<int> tsMs = GeneratedColumn<int>(
    'ts_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _celsiusMeta = const VerificationMeta(
    'celsius',
  );
  @override
  late final GeneratedColumn<double> celsius = GeneratedColumn<double>(
    'celsius',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, deviceId, tsMs, celsius];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'temp_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<TempSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('ts_ms')) {
      context.handle(
        _tsMsMeta,
        tsMs.isAcceptableOrUnknown(data['ts_ms']!, _tsMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tsMsMeta);
    }
    if (data.containsKey('celsius')) {
      context.handle(
        _celsiusMeta,
        celsius.isAcceptableOrUnknown(data['celsius']!, _celsiusMeta),
      );
    } else if (isInserting) {
      context.missing(_celsiusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TempSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TempSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      tsMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts_ms'],
      )!,
      celsius: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}celsius'],
      )!,
    );
  }

  @override
  $TempSamplesTable createAlias(String alias) {
    return $TempSamplesTable(attachedDatabase, alias);
  }
}

class TempSample extends DataClass implements Insertable<TempSample> {
  final int id;
  final String deviceId;
  final int tsMs;
  final double celsius;
  const TempSample({
    required this.id,
    required this.deviceId,
    required this.tsMs,
    required this.celsius,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['ts_ms'] = Variable<int>(tsMs);
    map['celsius'] = Variable<double>(celsius);
    return map;
  }

  TempSamplesCompanion toCompanion(bool nullToAbsent) {
    return TempSamplesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      tsMs: Value(tsMs),
      celsius: Value(celsius),
    );
  }

  factory TempSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TempSample(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      tsMs: serializer.fromJson<int>(json['tsMs']),
      celsius: serializer.fromJson<double>(json['celsius']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'tsMs': serializer.toJson<int>(tsMs),
      'celsius': serializer.toJson<double>(celsius),
    };
  }

  TempSample copyWith({
    int? id,
    String? deviceId,
    int? tsMs,
    double? celsius,
  }) => TempSample(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    tsMs: tsMs ?? this.tsMs,
    celsius: celsius ?? this.celsius,
  );
  TempSample copyWithCompanion(TempSamplesCompanion data) {
    return TempSample(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tsMs: data.tsMs.present ? data.tsMs.value : this.tsMs,
      celsius: data.celsius.present ? data.celsius.value : this.celsius,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TempSample(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsMs: $tsMs, ')
          ..write('celsius: $celsius')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, tsMs, celsius);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TempSample &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.tsMs == this.tsMs &&
          other.celsius == this.celsius);
}

class TempSamplesCompanion extends UpdateCompanion<TempSample> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<int> tsMs;
  final Value<double> celsius;
  const TempSamplesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tsMs = const Value.absent(),
    this.celsius = const Value.absent(),
  });
  TempSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required int tsMs,
    required double celsius,
  }) : deviceId = Value(deviceId),
       tsMs = Value(tsMs),
       celsius = Value(celsius);
  static Insertable<TempSample> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<int>? tsMs,
    Expression<double>? celsius,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (tsMs != null) 'ts_ms': tsMs,
      if (celsius != null) 'celsius': celsius,
    });
  }

  TempSamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<int>? tsMs,
    Value<double>? celsius,
  }) {
    return TempSamplesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsMs: tsMs ?? this.tsMs,
      celsius: celsius ?? this.celsius,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tsMs.present) {
      map['ts_ms'] = Variable<int>(tsMs.value);
    }
    if (celsius.present) {
      map['celsius'] = Variable<double>(celsius.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TempSamplesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsMs: $tsMs, ')
          ..write('celsius: $celsius')
          ..write(')'))
        .toString();
  }
}

class $ImuSamplesTable extends ImuSamples
    with TableInfo<$ImuSamplesTable, ImuSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImuSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id)',
    ),
  );
  static const VerificationMeta _tsMsMeta = const VerificationMeta('tsMs');
  @override
  late final GeneratedColumn<int> tsMs = GeneratedColumn<int>(
    'ts_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _axMeta = const VerificationMeta('ax');
  @override
  late final GeneratedColumn<double> ax = GeneratedColumn<double>(
    'ax',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayMeta = const VerificationMeta('ay');
  @override
  late final GeneratedColumn<double> ay = GeneratedColumn<double>(
    'ay',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _azMeta = const VerificationMeta('az');
  @override
  late final GeneratedColumn<double> az = GeneratedColumn<double>(
    'az',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gxMeta = const VerificationMeta('gx');
  @override
  late final GeneratedColumn<double> gx = GeneratedColumn<double>(
    'gx',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gyMeta = const VerificationMeta('gy');
  @override
  late final GeneratedColumn<double> gy = GeneratedColumn<double>(
    'gy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gzMeta = const VerificationMeta('gz');
  @override
  late final GeneratedColumn<double> gz = GeneratedColumn<double>(
    'gz',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<int> activity = GeneratedColumn<int>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    tsMs,
    ax,
    ay,
    az,
    gx,
    gy,
    gz,
    activity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imu_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImuSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('ts_ms')) {
      context.handle(
        _tsMsMeta,
        tsMs.isAcceptableOrUnknown(data['ts_ms']!, _tsMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tsMsMeta);
    }
    if (data.containsKey('ax')) {
      context.handle(_axMeta, ax.isAcceptableOrUnknown(data['ax']!, _axMeta));
    } else if (isInserting) {
      context.missing(_axMeta);
    }
    if (data.containsKey('ay')) {
      context.handle(_ayMeta, ay.isAcceptableOrUnknown(data['ay']!, _ayMeta));
    } else if (isInserting) {
      context.missing(_ayMeta);
    }
    if (data.containsKey('az')) {
      context.handle(_azMeta, az.isAcceptableOrUnknown(data['az']!, _azMeta));
    } else if (isInserting) {
      context.missing(_azMeta);
    }
    if (data.containsKey('gx')) {
      context.handle(_gxMeta, gx.isAcceptableOrUnknown(data['gx']!, _gxMeta));
    } else if (isInserting) {
      context.missing(_gxMeta);
    }
    if (data.containsKey('gy')) {
      context.handle(_gyMeta, gy.isAcceptableOrUnknown(data['gy']!, _gyMeta));
    } else if (isInserting) {
      context.missing(_gyMeta);
    }
    if (data.containsKey('gz')) {
      context.handle(_gzMeta, gz.isAcceptableOrUnknown(data['gz']!, _gzMeta));
    } else if (isInserting) {
      context.missing(_gzMeta);
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImuSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImuSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      tsMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts_ms'],
      )!,
      ax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ax'],
      )!,
      ay: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ay'],
      )!,
      az: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}az'],
      )!,
      gx: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gx'],
      )!,
      gy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gy'],
      )!,
      gz: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gz'],
      )!,
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity'],
      )!,
    );
  }

  @override
  $ImuSamplesTable createAlias(String alias) {
    return $ImuSamplesTable(attachedDatabase, alias);
  }
}

class ImuSample extends DataClass implements Insertable<ImuSample> {
  final int id;
  final String deviceId;
  final int tsMs;
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;

  /// Activity label assigned by the on-device classifier:
  /// 0=resting 1=walking 2=running 3=other
  final int activity;
  const ImuSample({
    required this.id,
    required this.deviceId,
    required this.tsMs,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.activity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['ts_ms'] = Variable<int>(tsMs);
    map['ax'] = Variable<double>(ax);
    map['ay'] = Variable<double>(ay);
    map['az'] = Variable<double>(az);
    map['gx'] = Variable<double>(gx);
    map['gy'] = Variable<double>(gy);
    map['gz'] = Variable<double>(gz);
    map['activity'] = Variable<int>(activity);
    return map;
  }

  ImuSamplesCompanion toCompanion(bool nullToAbsent) {
    return ImuSamplesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      tsMs: Value(tsMs),
      ax: Value(ax),
      ay: Value(ay),
      az: Value(az),
      gx: Value(gx),
      gy: Value(gy),
      gz: Value(gz),
      activity: Value(activity),
    );
  }

  factory ImuSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImuSample(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      tsMs: serializer.fromJson<int>(json['tsMs']),
      ax: serializer.fromJson<double>(json['ax']),
      ay: serializer.fromJson<double>(json['ay']),
      az: serializer.fromJson<double>(json['az']),
      gx: serializer.fromJson<double>(json['gx']),
      gy: serializer.fromJson<double>(json['gy']),
      gz: serializer.fromJson<double>(json['gz']),
      activity: serializer.fromJson<int>(json['activity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'tsMs': serializer.toJson<int>(tsMs),
      'ax': serializer.toJson<double>(ax),
      'ay': serializer.toJson<double>(ay),
      'az': serializer.toJson<double>(az),
      'gx': serializer.toJson<double>(gx),
      'gy': serializer.toJson<double>(gy),
      'gz': serializer.toJson<double>(gz),
      'activity': serializer.toJson<int>(activity),
    };
  }

  ImuSample copyWith({
    int? id,
    String? deviceId,
    int? tsMs,
    double? ax,
    double? ay,
    double? az,
    double? gx,
    double? gy,
    double? gz,
    int? activity,
  }) => ImuSample(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    tsMs: tsMs ?? this.tsMs,
    ax: ax ?? this.ax,
    ay: ay ?? this.ay,
    az: az ?? this.az,
    gx: gx ?? this.gx,
    gy: gy ?? this.gy,
    gz: gz ?? this.gz,
    activity: activity ?? this.activity,
  );
  ImuSample copyWithCompanion(ImuSamplesCompanion data) {
    return ImuSample(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      tsMs: data.tsMs.present ? data.tsMs.value : this.tsMs,
      ax: data.ax.present ? data.ax.value : this.ax,
      ay: data.ay.present ? data.ay.value : this.ay,
      az: data.az.present ? data.az.value : this.az,
      gx: data.gx.present ? data.gx.value : this.gx,
      gy: data.gy.present ? data.gy.value : this.gy,
      gz: data.gz.present ? data.gz.value : this.gz,
      activity: data.activity.present ? data.activity.value : this.activity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImuSample(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsMs: $tsMs, ')
          ..write('ax: $ax, ')
          ..write('ay: $ay, ')
          ..write('az: $az, ')
          ..write('gx: $gx, ')
          ..write('gy: $gy, ')
          ..write('gz: $gz, ')
          ..write('activity: $activity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, tsMs, ax, ay, az, gx, gy, gz, activity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImuSample &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.tsMs == this.tsMs &&
          other.ax == this.ax &&
          other.ay == this.ay &&
          other.az == this.az &&
          other.gx == this.gx &&
          other.gy == this.gy &&
          other.gz == this.gz &&
          other.activity == this.activity);
}

class ImuSamplesCompanion extends UpdateCompanion<ImuSample> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<int> tsMs;
  final Value<double> ax;
  final Value<double> ay;
  final Value<double> az;
  final Value<double> gx;
  final Value<double> gy;
  final Value<double> gz;
  final Value<int> activity;
  const ImuSamplesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.tsMs = const Value.absent(),
    this.ax = const Value.absent(),
    this.ay = const Value.absent(),
    this.az = const Value.absent(),
    this.gx = const Value.absent(),
    this.gy = const Value.absent(),
    this.gz = const Value.absent(),
    this.activity = const Value.absent(),
  });
  ImuSamplesCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required int tsMs,
    required double ax,
    required double ay,
    required double az,
    required double gx,
    required double gy,
    required double gz,
    this.activity = const Value.absent(),
  }) : deviceId = Value(deviceId),
       tsMs = Value(tsMs),
       ax = Value(ax),
       ay = Value(ay),
       az = Value(az),
       gx = Value(gx),
       gy = Value(gy),
       gz = Value(gz);
  static Insertable<ImuSample> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<int>? tsMs,
    Expression<double>? ax,
    Expression<double>? ay,
    Expression<double>? az,
    Expression<double>? gx,
    Expression<double>? gy,
    Expression<double>? gz,
    Expression<int>? activity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (tsMs != null) 'ts_ms': tsMs,
      if (ax != null) 'ax': ax,
      if (ay != null) 'ay': ay,
      if (az != null) 'az': az,
      if (gx != null) 'gx': gx,
      if (gy != null) 'gy': gy,
      if (gz != null) 'gz': gz,
      if (activity != null) 'activity': activity,
    });
  }

  ImuSamplesCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<int>? tsMs,
    Value<double>? ax,
    Value<double>? ay,
    Value<double>? az,
    Value<double>? gx,
    Value<double>? gy,
    Value<double>? gz,
    Value<int>? activity,
  }) {
    return ImuSamplesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      tsMs: tsMs ?? this.tsMs,
      ax: ax ?? this.ax,
      ay: ay ?? this.ay,
      az: az ?? this.az,
      gx: gx ?? this.gx,
      gy: gy ?? this.gy,
      gz: gz ?? this.gz,
      activity: activity ?? this.activity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (tsMs.present) {
      map['ts_ms'] = Variable<int>(tsMs.value);
    }
    if (ax.present) {
      map['ax'] = Variable<double>(ax.value);
    }
    if (ay.present) {
      map['ay'] = Variable<double>(ay.value);
    }
    if (az.present) {
      map['az'] = Variable<double>(az.value);
    }
    if (gx.present) {
      map['gx'] = Variable<double>(gx.value);
    }
    if (gy.present) {
      map['gy'] = Variable<double>(gy.value);
    }
    if (gz.present) {
      map['gz'] = Variable<double>(gz.value);
    }
    if (activity.present) {
      map['activity'] = Variable<int>(activity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImuSamplesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('tsMs: $tsMs, ')
          ..write('ax: $ax, ')
          ..write('ay: $ay, ')
          ..write('az: $az, ')
          ..write('gx: $gx, ')
          ..write('gy: $gy, ')
          ..write('gz: $gz, ')
          ..write('activity: $activity')
          ..write(')'))
        .toString();
  }
}

class $FeatureRowsTable extends FeatureRows
    with TableInfo<$FeatureRowsTable, FeatureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeatureRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tsMsMeta = const VerificationMeta('tsMs');
  @override
  late final GeneratedColumn<int> tsMs = GeneratedColumn<int>(
    'ts_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowSMeta = const VerificationMeta(
    'windowS',
  );
  @override
  late final GeneratedColumn<int> windowS = GeneratedColumn<int>(
    'window_s',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _hrMeanMeta = const VerificationMeta('hrMean');
  @override
  late final GeneratedColumn<double> hrMean = GeneratedColumn<double>(
    'hr_mean',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hrStdMeta = const VerificationMeta('hrStd');
  @override
  late final GeneratedColumn<double> hrStd = GeneratedColumn<double>(
    'hr_std',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hrMinMeta = const VerificationMeta('hrMin');
  @override
  late final GeneratedColumn<double> hrMin = GeneratedColumn<double>(
    'hr_min',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hrMaxMeta = const VerificationMeta('hrMax');
  @override
  late final GeneratedColumn<double> hrMax = GeneratedColumn<double>(
    'hr_max',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rmssdMeta = const VerificationMeta('rmssd');
  @override
  late final GeneratedColumn<double> rmssd = GeneratedColumn<double>(
    'rmssd',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pnn50Meta = const VerificationMeta('pnn50');
  @override
  late final GeneratedColumn<double> pnn50 = GeneratedColumn<double>(
    'pnn50',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spo2MeanMeta = const VerificationMeta(
    'spo2Mean',
  );
  @override
  late final GeneratedColumn<double> spo2Mean = GeneratedColumn<double>(
    'spo2_mean',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempMeanMeta = const VerificationMeta(
    'tempMean',
  );
  @override
  late final GeneratedColumn<double> tempMean = GeneratedColumn<double>(
    'temp_mean',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tempSlopeMeta = const VerificationMeta(
    'tempSlope',
  );
  @override
  late final GeneratedColumn<double> tempSlope = GeneratedColumn<double>(
    'temp_slope',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelMeanMeta = const VerificationMeta(
    'accelMean',
  );
  @override
  late final GeneratedColumn<double> accelMean = GeneratedColumn<double>(
    'accel_mean',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelStdMeta = const VerificationMeta(
    'accelStd',
  );
  @override
  late final GeneratedColumn<double> accelStd = GeneratedColumn<double>(
    'accel_std',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityMeta = const VerificationMeta(
    'activity',
  );
  @override
  late final GeneratedColumn<int> activity = GeneratedColumn<int>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anomalyPMeta = const VerificationMeta(
    'anomalyP',
  );
  @override
  late final GeneratedColumn<double> anomalyP = GeneratedColumn<double>(
    'anomaly_p',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tsMs,
    windowS,
    hrMean,
    hrStd,
    hrMin,
    hrMax,
    rmssd,
    pnn50,
    spo2Mean,
    tempMean,
    tempSlope,
    accelMean,
    accelStd,
    activity,
    anomalyP,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feature_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeatureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ts_ms')) {
      context.handle(
        _tsMsMeta,
        tsMs.isAcceptableOrUnknown(data['ts_ms']!, _tsMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tsMsMeta);
    }
    if (data.containsKey('window_s')) {
      context.handle(
        _windowSMeta,
        windowS.isAcceptableOrUnknown(data['window_s']!, _windowSMeta),
      );
    }
    if (data.containsKey('hr_mean')) {
      context.handle(
        _hrMeanMeta,
        hrMean.isAcceptableOrUnknown(data['hr_mean']!, _hrMeanMeta),
      );
    } else if (isInserting) {
      context.missing(_hrMeanMeta);
    }
    if (data.containsKey('hr_std')) {
      context.handle(
        _hrStdMeta,
        hrStd.isAcceptableOrUnknown(data['hr_std']!, _hrStdMeta),
      );
    } else if (isInserting) {
      context.missing(_hrStdMeta);
    }
    if (data.containsKey('hr_min')) {
      context.handle(
        _hrMinMeta,
        hrMin.isAcceptableOrUnknown(data['hr_min']!, _hrMinMeta),
      );
    } else if (isInserting) {
      context.missing(_hrMinMeta);
    }
    if (data.containsKey('hr_max')) {
      context.handle(
        _hrMaxMeta,
        hrMax.isAcceptableOrUnknown(data['hr_max']!, _hrMaxMeta),
      );
    } else if (isInserting) {
      context.missing(_hrMaxMeta);
    }
    if (data.containsKey('rmssd')) {
      context.handle(
        _rmssdMeta,
        rmssd.isAcceptableOrUnknown(data['rmssd']!, _rmssdMeta),
      );
    } else if (isInserting) {
      context.missing(_rmssdMeta);
    }
    if (data.containsKey('pnn50')) {
      context.handle(
        _pnn50Meta,
        pnn50.isAcceptableOrUnknown(data['pnn50']!, _pnn50Meta),
      );
    } else if (isInserting) {
      context.missing(_pnn50Meta);
    }
    if (data.containsKey('spo2_mean')) {
      context.handle(
        _spo2MeanMeta,
        spo2Mean.isAcceptableOrUnknown(data['spo2_mean']!, _spo2MeanMeta),
      );
    }
    if (data.containsKey('temp_mean')) {
      context.handle(
        _tempMeanMeta,
        tempMean.isAcceptableOrUnknown(data['temp_mean']!, _tempMeanMeta),
      );
    } else if (isInserting) {
      context.missing(_tempMeanMeta);
    }
    if (data.containsKey('temp_slope')) {
      context.handle(
        _tempSlopeMeta,
        tempSlope.isAcceptableOrUnknown(data['temp_slope']!, _tempSlopeMeta),
      );
    } else if (isInserting) {
      context.missing(_tempSlopeMeta);
    }
    if (data.containsKey('accel_mean')) {
      context.handle(
        _accelMeanMeta,
        accelMean.isAcceptableOrUnknown(data['accel_mean']!, _accelMeanMeta),
      );
    } else if (isInserting) {
      context.missing(_accelMeanMeta);
    }
    if (data.containsKey('accel_std')) {
      context.handle(
        _accelStdMeta,
        accelStd.isAcceptableOrUnknown(data['accel_std']!, _accelStdMeta),
      );
    } else if (isInserting) {
      context.missing(_accelStdMeta);
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    } else if (isInserting) {
      context.missing(_activityMeta);
    }
    if (data.containsKey('anomaly_p')) {
      context.handle(
        _anomalyPMeta,
        anomalyP.isAcceptableOrUnknown(data['anomaly_p']!, _anomalyPMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeatureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeatureRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tsMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts_ms'],
      )!,
      windowS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}window_s'],
      )!,
      hrMean: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_mean'],
      )!,
      hrStd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_std'],
      )!,
      hrMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_min'],
      )!,
      hrMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_max'],
      )!,
      rmssd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rmssd'],
      )!,
      pnn50: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pnn50'],
      )!,
      spo2Mean: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spo2_mean'],
      ),
      tempMean: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_mean'],
      )!,
      tempSlope: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temp_slope'],
      )!,
      accelMean: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_mean'],
      )!,
      accelStd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accel_std'],
      )!,
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}activity'],
      )!,
      anomalyP: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}anomaly_p'],
      ),
    );
  }

  @override
  $FeatureRowsTable createAlias(String alias) {
    return $FeatureRowsTable(attachedDatabase, alias);
  }
}

class FeatureRow extends DataClass implements Insertable<FeatureRow> {
  final int id;
  final int tsMs;
  final int windowS;
  final double hrMean;
  final double hrStd;
  final double hrMin;
  final double hrMax;
  final double rmssd;
  final double pnn50;
  final double? spo2Mean;
  final double tempMean;
  final double tempSlope;
  final double accelMean;
  final double accelStd;
  final int activity;

  /// Anomaly probability output by the on-device model in [0, 1].
  final double? anomalyP;
  const FeatureRow({
    required this.id,
    required this.tsMs,
    required this.windowS,
    required this.hrMean,
    required this.hrStd,
    required this.hrMin,
    required this.hrMax,
    required this.rmssd,
    required this.pnn50,
    this.spo2Mean,
    required this.tempMean,
    required this.tempSlope,
    required this.accelMean,
    required this.accelStd,
    required this.activity,
    this.anomalyP,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ts_ms'] = Variable<int>(tsMs);
    map['window_s'] = Variable<int>(windowS);
    map['hr_mean'] = Variable<double>(hrMean);
    map['hr_std'] = Variable<double>(hrStd);
    map['hr_min'] = Variable<double>(hrMin);
    map['hr_max'] = Variable<double>(hrMax);
    map['rmssd'] = Variable<double>(rmssd);
    map['pnn50'] = Variable<double>(pnn50);
    if (!nullToAbsent || spo2Mean != null) {
      map['spo2_mean'] = Variable<double>(spo2Mean);
    }
    map['temp_mean'] = Variable<double>(tempMean);
    map['temp_slope'] = Variable<double>(tempSlope);
    map['accel_mean'] = Variable<double>(accelMean);
    map['accel_std'] = Variable<double>(accelStd);
    map['activity'] = Variable<int>(activity);
    if (!nullToAbsent || anomalyP != null) {
      map['anomaly_p'] = Variable<double>(anomalyP);
    }
    return map;
  }

  FeatureRowsCompanion toCompanion(bool nullToAbsent) {
    return FeatureRowsCompanion(
      id: Value(id),
      tsMs: Value(tsMs),
      windowS: Value(windowS),
      hrMean: Value(hrMean),
      hrStd: Value(hrStd),
      hrMin: Value(hrMin),
      hrMax: Value(hrMax),
      rmssd: Value(rmssd),
      pnn50: Value(pnn50),
      spo2Mean: spo2Mean == null && nullToAbsent
          ? const Value.absent()
          : Value(spo2Mean),
      tempMean: Value(tempMean),
      tempSlope: Value(tempSlope),
      accelMean: Value(accelMean),
      accelStd: Value(accelStd),
      activity: Value(activity),
      anomalyP: anomalyP == null && nullToAbsent
          ? const Value.absent()
          : Value(anomalyP),
    );
  }

  factory FeatureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeatureRow(
      id: serializer.fromJson<int>(json['id']),
      tsMs: serializer.fromJson<int>(json['tsMs']),
      windowS: serializer.fromJson<int>(json['windowS']),
      hrMean: serializer.fromJson<double>(json['hrMean']),
      hrStd: serializer.fromJson<double>(json['hrStd']),
      hrMin: serializer.fromJson<double>(json['hrMin']),
      hrMax: serializer.fromJson<double>(json['hrMax']),
      rmssd: serializer.fromJson<double>(json['rmssd']),
      pnn50: serializer.fromJson<double>(json['pnn50']),
      spo2Mean: serializer.fromJson<double?>(json['spo2Mean']),
      tempMean: serializer.fromJson<double>(json['tempMean']),
      tempSlope: serializer.fromJson<double>(json['tempSlope']),
      accelMean: serializer.fromJson<double>(json['accelMean']),
      accelStd: serializer.fromJson<double>(json['accelStd']),
      activity: serializer.fromJson<int>(json['activity']),
      anomalyP: serializer.fromJson<double?>(json['anomalyP']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tsMs': serializer.toJson<int>(tsMs),
      'windowS': serializer.toJson<int>(windowS),
      'hrMean': serializer.toJson<double>(hrMean),
      'hrStd': serializer.toJson<double>(hrStd),
      'hrMin': serializer.toJson<double>(hrMin),
      'hrMax': serializer.toJson<double>(hrMax),
      'rmssd': serializer.toJson<double>(rmssd),
      'pnn50': serializer.toJson<double>(pnn50),
      'spo2Mean': serializer.toJson<double?>(spo2Mean),
      'tempMean': serializer.toJson<double>(tempMean),
      'tempSlope': serializer.toJson<double>(tempSlope),
      'accelMean': serializer.toJson<double>(accelMean),
      'accelStd': serializer.toJson<double>(accelStd),
      'activity': serializer.toJson<int>(activity),
      'anomalyP': serializer.toJson<double?>(anomalyP),
    };
  }

  FeatureRow copyWith({
    int? id,
    int? tsMs,
    int? windowS,
    double? hrMean,
    double? hrStd,
    double? hrMin,
    double? hrMax,
    double? rmssd,
    double? pnn50,
    Value<double?> spo2Mean = const Value.absent(),
    double? tempMean,
    double? tempSlope,
    double? accelMean,
    double? accelStd,
    int? activity,
    Value<double?> anomalyP = const Value.absent(),
  }) => FeatureRow(
    id: id ?? this.id,
    tsMs: tsMs ?? this.tsMs,
    windowS: windowS ?? this.windowS,
    hrMean: hrMean ?? this.hrMean,
    hrStd: hrStd ?? this.hrStd,
    hrMin: hrMin ?? this.hrMin,
    hrMax: hrMax ?? this.hrMax,
    rmssd: rmssd ?? this.rmssd,
    pnn50: pnn50 ?? this.pnn50,
    spo2Mean: spo2Mean.present ? spo2Mean.value : this.spo2Mean,
    tempMean: tempMean ?? this.tempMean,
    tempSlope: tempSlope ?? this.tempSlope,
    accelMean: accelMean ?? this.accelMean,
    accelStd: accelStd ?? this.accelStd,
    activity: activity ?? this.activity,
    anomalyP: anomalyP.present ? anomalyP.value : this.anomalyP,
  );
  FeatureRow copyWithCompanion(FeatureRowsCompanion data) {
    return FeatureRow(
      id: data.id.present ? data.id.value : this.id,
      tsMs: data.tsMs.present ? data.tsMs.value : this.tsMs,
      windowS: data.windowS.present ? data.windowS.value : this.windowS,
      hrMean: data.hrMean.present ? data.hrMean.value : this.hrMean,
      hrStd: data.hrStd.present ? data.hrStd.value : this.hrStd,
      hrMin: data.hrMin.present ? data.hrMin.value : this.hrMin,
      hrMax: data.hrMax.present ? data.hrMax.value : this.hrMax,
      rmssd: data.rmssd.present ? data.rmssd.value : this.rmssd,
      pnn50: data.pnn50.present ? data.pnn50.value : this.pnn50,
      spo2Mean: data.spo2Mean.present ? data.spo2Mean.value : this.spo2Mean,
      tempMean: data.tempMean.present ? data.tempMean.value : this.tempMean,
      tempSlope: data.tempSlope.present ? data.tempSlope.value : this.tempSlope,
      accelMean: data.accelMean.present ? data.accelMean.value : this.accelMean,
      accelStd: data.accelStd.present ? data.accelStd.value : this.accelStd,
      activity: data.activity.present ? data.activity.value : this.activity,
      anomalyP: data.anomalyP.present ? data.anomalyP.value : this.anomalyP,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeatureRow(')
          ..write('id: $id, ')
          ..write('tsMs: $tsMs, ')
          ..write('windowS: $windowS, ')
          ..write('hrMean: $hrMean, ')
          ..write('hrStd: $hrStd, ')
          ..write('hrMin: $hrMin, ')
          ..write('hrMax: $hrMax, ')
          ..write('rmssd: $rmssd, ')
          ..write('pnn50: $pnn50, ')
          ..write('spo2Mean: $spo2Mean, ')
          ..write('tempMean: $tempMean, ')
          ..write('tempSlope: $tempSlope, ')
          ..write('accelMean: $accelMean, ')
          ..write('accelStd: $accelStd, ')
          ..write('activity: $activity, ')
          ..write('anomalyP: $anomalyP')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tsMs,
    windowS,
    hrMean,
    hrStd,
    hrMin,
    hrMax,
    rmssd,
    pnn50,
    spo2Mean,
    tempMean,
    tempSlope,
    accelMean,
    accelStd,
    activity,
    anomalyP,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeatureRow &&
          other.id == this.id &&
          other.tsMs == this.tsMs &&
          other.windowS == this.windowS &&
          other.hrMean == this.hrMean &&
          other.hrStd == this.hrStd &&
          other.hrMin == this.hrMin &&
          other.hrMax == this.hrMax &&
          other.rmssd == this.rmssd &&
          other.pnn50 == this.pnn50 &&
          other.spo2Mean == this.spo2Mean &&
          other.tempMean == this.tempMean &&
          other.tempSlope == this.tempSlope &&
          other.accelMean == this.accelMean &&
          other.accelStd == this.accelStd &&
          other.activity == this.activity &&
          other.anomalyP == this.anomalyP);
}

class FeatureRowsCompanion extends UpdateCompanion<FeatureRow> {
  final Value<int> id;
  final Value<int> tsMs;
  final Value<int> windowS;
  final Value<double> hrMean;
  final Value<double> hrStd;
  final Value<double> hrMin;
  final Value<double> hrMax;
  final Value<double> rmssd;
  final Value<double> pnn50;
  final Value<double?> spo2Mean;
  final Value<double> tempMean;
  final Value<double> tempSlope;
  final Value<double> accelMean;
  final Value<double> accelStd;
  final Value<int> activity;
  final Value<double?> anomalyP;
  const FeatureRowsCompanion({
    this.id = const Value.absent(),
    this.tsMs = const Value.absent(),
    this.windowS = const Value.absent(),
    this.hrMean = const Value.absent(),
    this.hrStd = const Value.absent(),
    this.hrMin = const Value.absent(),
    this.hrMax = const Value.absent(),
    this.rmssd = const Value.absent(),
    this.pnn50 = const Value.absent(),
    this.spo2Mean = const Value.absent(),
    this.tempMean = const Value.absent(),
    this.tempSlope = const Value.absent(),
    this.accelMean = const Value.absent(),
    this.accelStd = const Value.absent(),
    this.activity = const Value.absent(),
    this.anomalyP = const Value.absent(),
  });
  FeatureRowsCompanion.insert({
    this.id = const Value.absent(),
    required int tsMs,
    this.windowS = const Value.absent(),
    required double hrMean,
    required double hrStd,
    required double hrMin,
    required double hrMax,
    required double rmssd,
    required double pnn50,
    this.spo2Mean = const Value.absent(),
    required double tempMean,
    required double tempSlope,
    required double accelMean,
    required double accelStd,
    required int activity,
    this.anomalyP = const Value.absent(),
  }) : tsMs = Value(tsMs),
       hrMean = Value(hrMean),
       hrStd = Value(hrStd),
       hrMin = Value(hrMin),
       hrMax = Value(hrMax),
       rmssd = Value(rmssd),
       pnn50 = Value(pnn50),
       tempMean = Value(tempMean),
       tempSlope = Value(tempSlope),
       accelMean = Value(accelMean),
       accelStd = Value(accelStd),
       activity = Value(activity);
  static Insertable<FeatureRow> custom({
    Expression<int>? id,
    Expression<int>? tsMs,
    Expression<int>? windowS,
    Expression<double>? hrMean,
    Expression<double>? hrStd,
    Expression<double>? hrMin,
    Expression<double>? hrMax,
    Expression<double>? rmssd,
    Expression<double>? pnn50,
    Expression<double>? spo2Mean,
    Expression<double>? tempMean,
    Expression<double>? tempSlope,
    Expression<double>? accelMean,
    Expression<double>? accelStd,
    Expression<int>? activity,
    Expression<double>? anomalyP,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tsMs != null) 'ts_ms': tsMs,
      if (windowS != null) 'window_s': windowS,
      if (hrMean != null) 'hr_mean': hrMean,
      if (hrStd != null) 'hr_std': hrStd,
      if (hrMin != null) 'hr_min': hrMin,
      if (hrMax != null) 'hr_max': hrMax,
      if (rmssd != null) 'rmssd': rmssd,
      if (pnn50 != null) 'pnn50': pnn50,
      if (spo2Mean != null) 'spo2_mean': spo2Mean,
      if (tempMean != null) 'temp_mean': tempMean,
      if (tempSlope != null) 'temp_slope': tempSlope,
      if (accelMean != null) 'accel_mean': accelMean,
      if (accelStd != null) 'accel_std': accelStd,
      if (activity != null) 'activity': activity,
      if (anomalyP != null) 'anomaly_p': anomalyP,
    });
  }

  FeatureRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? tsMs,
    Value<int>? windowS,
    Value<double>? hrMean,
    Value<double>? hrStd,
    Value<double>? hrMin,
    Value<double>? hrMax,
    Value<double>? rmssd,
    Value<double>? pnn50,
    Value<double?>? spo2Mean,
    Value<double>? tempMean,
    Value<double>? tempSlope,
    Value<double>? accelMean,
    Value<double>? accelStd,
    Value<int>? activity,
    Value<double?>? anomalyP,
  }) {
    return FeatureRowsCompanion(
      id: id ?? this.id,
      tsMs: tsMs ?? this.tsMs,
      windowS: windowS ?? this.windowS,
      hrMean: hrMean ?? this.hrMean,
      hrStd: hrStd ?? this.hrStd,
      hrMin: hrMin ?? this.hrMin,
      hrMax: hrMax ?? this.hrMax,
      rmssd: rmssd ?? this.rmssd,
      pnn50: pnn50 ?? this.pnn50,
      spo2Mean: spo2Mean ?? this.spo2Mean,
      tempMean: tempMean ?? this.tempMean,
      tempSlope: tempSlope ?? this.tempSlope,
      accelMean: accelMean ?? this.accelMean,
      accelStd: accelStd ?? this.accelStd,
      activity: activity ?? this.activity,
      anomalyP: anomalyP ?? this.anomalyP,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tsMs.present) {
      map['ts_ms'] = Variable<int>(tsMs.value);
    }
    if (windowS.present) {
      map['window_s'] = Variable<int>(windowS.value);
    }
    if (hrMean.present) {
      map['hr_mean'] = Variable<double>(hrMean.value);
    }
    if (hrStd.present) {
      map['hr_std'] = Variable<double>(hrStd.value);
    }
    if (hrMin.present) {
      map['hr_min'] = Variable<double>(hrMin.value);
    }
    if (hrMax.present) {
      map['hr_max'] = Variable<double>(hrMax.value);
    }
    if (rmssd.present) {
      map['rmssd'] = Variable<double>(rmssd.value);
    }
    if (pnn50.present) {
      map['pnn50'] = Variable<double>(pnn50.value);
    }
    if (spo2Mean.present) {
      map['spo2_mean'] = Variable<double>(spo2Mean.value);
    }
    if (tempMean.present) {
      map['temp_mean'] = Variable<double>(tempMean.value);
    }
    if (tempSlope.present) {
      map['temp_slope'] = Variable<double>(tempSlope.value);
    }
    if (accelMean.present) {
      map['accel_mean'] = Variable<double>(accelMean.value);
    }
    if (accelStd.present) {
      map['accel_std'] = Variable<double>(accelStd.value);
    }
    if (activity.present) {
      map['activity'] = Variable<int>(activity.value);
    }
    if (anomalyP.present) {
      map['anomaly_p'] = Variable<double>(anomalyP.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeatureRowsCompanion(')
          ..write('id: $id, ')
          ..write('tsMs: $tsMs, ')
          ..write('windowS: $windowS, ')
          ..write('hrMean: $hrMean, ')
          ..write('hrStd: $hrStd, ')
          ..write('hrMin: $hrMin, ')
          ..write('hrMax: $hrMax, ')
          ..write('rmssd: $rmssd, ')
          ..write('pnn50: $pnn50, ')
          ..write('spo2Mean: $spo2Mean, ')
          ..write('tempMean: $tempMean, ')
          ..write('tempSlope: $tempSlope, ')
          ..write('accelMean: $accelMean, ')
          ..write('accelStd: $accelStd, ')
          ..write('activity: $activity, ')
          ..write('anomalyP: $anomalyP')
          ..write(')'))
        .toString();
  }
}

class $AnomaliesTable extends Anomalies
    with TableInfo<$AnomaliesTable, AnomalyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnomaliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMsMeta = const VerificationMeta('tsMs');
  @override
  late final GeneratedColumn<int> tsMs = GeneratedColumn<int>(
    'ts_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guidanceMeta = const VerificationMeta(
    'guidance',
  );
  @override
  late final GeneratedColumn<String> guidance = GeneratedColumn<String>(
    'guidance',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metricsJsonMeta = const VerificationMeta(
    'metricsJson',
  );
  @override
  late final GeneratedColumn<String> metricsJson = GeneratedColumn<String>(
    'metrics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dismissedAtMsMeta = const VerificationMeta(
    'dismissedAtMs',
  );
  @override
  late final GeneratedColumn<int> dismissedAtMs = GeneratedColumn<int>(
    'dismissed_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedNotAnomalousMeta =
      const VerificationMeta('markedNotAnomalous');
  @override
  late final GeneratedColumn<bool> markedNotAnomalous = GeneratedColumn<bool>(
    'marked_not_anomalous',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("marked_not_anomalous" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tsMs,
    severity,
    type,
    explanation,
    guidance,
    metricsJson,
    dismissedAtMs,
    markedNotAnomalous,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anomalies';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnomalyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ts_ms')) {
      context.handle(
        _tsMsMeta,
        tsMs.isAcceptableOrUnknown(data['ts_ms']!, _tsMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tsMsMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('guidance')) {
      context.handle(
        _guidanceMeta,
        guidance.isAcceptableOrUnknown(data['guidance']!, _guidanceMeta),
      );
    }
    if (data.containsKey('metrics_json')) {
      context.handle(
        _metricsJsonMeta,
        metricsJson.isAcceptableOrUnknown(
          data['metrics_json']!,
          _metricsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metricsJsonMeta);
    }
    if (data.containsKey('dismissed_at_ms')) {
      context.handle(
        _dismissedAtMsMeta,
        dismissedAtMs.isAcceptableOrUnknown(
          data['dismissed_at_ms']!,
          _dismissedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('marked_not_anomalous')) {
      context.handle(
        _markedNotAnomalousMeta,
        markedNotAnomalous.isAcceptableOrUnknown(
          data['marked_not_anomalous']!,
          _markedNotAnomalousMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnomalyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnomalyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tsMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts_ms'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      guidance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guidance'],
      ),
      metricsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metrics_json'],
      )!,
      dismissedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dismissed_at_ms'],
      ),
      markedNotAnomalous: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}marked_not_anomalous'],
      )!,
    );
  }

  @override
  $AnomaliesTable createAlias(String alias) {
    return $AnomaliesTable(attachedDatabase, alias);
  }
}

class AnomalyRow extends DataClass implements Insertable<AnomalyRow> {
  final String id;
  final int tsMs;
  final int severity;
  final String type;
  final String? explanation;
  final String? guidance;

  /// Snapshot of metrics at fire-time (JSON-encoded map).
  final String metricsJson;
  final int? dismissedAtMs;
  final bool markedNotAnomalous;
  const AnomalyRow({
    required this.id,
    required this.tsMs,
    required this.severity,
    required this.type,
    this.explanation,
    this.guidance,
    required this.metricsJson,
    this.dismissedAtMs,
    required this.markedNotAnomalous,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ts_ms'] = Variable<int>(tsMs);
    map['severity'] = Variable<int>(severity);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    if (!nullToAbsent || guidance != null) {
      map['guidance'] = Variable<String>(guidance);
    }
    map['metrics_json'] = Variable<String>(metricsJson);
    if (!nullToAbsent || dismissedAtMs != null) {
      map['dismissed_at_ms'] = Variable<int>(dismissedAtMs);
    }
    map['marked_not_anomalous'] = Variable<bool>(markedNotAnomalous);
    return map;
  }

  AnomaliesCompanion toCompanion(bool nullToAbsent) {
    return AnomaliesCompanion(
      id: Value(id),
      tsMs: Value(tsMs),
      severity: Value(severity),
      type: Value(type),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      guidance: guidance == null && nullToAbsent
          ? const Value.absent()
          : Value(guidance),
      metricsJson: Value(metricsJson),
      dismissedAtMs: dismissedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(dismissedAtMs),
      markedNotAnomalous: Value(markedNotAnomalous),
    );
  }

  factory AnomalyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnomalyRow(
      id: serializer.fromJson<String>(json['id']),
      tsMs: serializer.fromJson<int>(json['tsMs']),
      severity: serializer.fromJson<int>(json['severity']),
      type: serializer.fromJson<String>(json['type']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      guidance: serializer.fromJson<String?>(json['guidance']),
      metricsJson: serializer.fromJson<String>(json['metricsJson']),
      dismissedAtMs: serializer.fromJson<int?>(json['dismissedAtMs']),
      markedNotAnomalous: serializer.fromJson<bool>(json['markedNotAnomalous']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tsMs': serializer.toJson<int>(tsMs),
      'severity': serializer.toJson<int>(severity),
      'type': serializer.toJson<String>(type),
      'explanation': serializer.toJson<String?>(explanation),
      'guidance': serializer.toJson<String?>(guidance),
      'metricsJson': serializer.toJson<String>(metricsJson),
      'dismissedAtMs': serializer.toJson<int?>(dismissedAtMs),
      'markedNotAnomalous': serializer.toJson<bool>(markedNotAnomalous),
    };
  }

  AnomalyRow copyWith({
    String? id,
    int? tsMs,
    int? severity,
    String? type,
    Value<String?> explanation = const Value.absent(),
    Value<String?> guidance = const Value.absent(),
    String? metricsJson,
    Value<int?> dismissedAtMs = const Value.absent(),
    bool? markedNotAnomalous,
  }) => AnomalyRow(
    id: id ?? this.id,
    tsMs: tsMs ?? this.tsMs,
    severity: severity ?? this.severity,
    type: type ?? this.type,
    explanation: explanation.present ? explanation.value : this.explanation,
    guidance: guidance.present ? guidance.value : this.guidance,
    metricsJson: metricsJson ?? this.metricsJson,
    dismissedAtMs: dismissedAtMs.present
        ? dismissedAtMs.value
        : this.dismissedAtMs,
    markedNotAnomalous: markedNotAnomalous ?? this.markedNotAnomalous,
  );
  AnomalyRow copyWithCompanion(AnomaliesCompanion data) {
    return AnomalyRow(
      id: data.id.present ? data.id.value : this.id,
      tsMs: data.tsMs.present ? data.tsMs.value : this.tsMs,
      severity: data.severity.present ? data.severity.value : this.severity,
      type: data.type.present ? data.type.value : this.type,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      guidance: data.guidance.present ? data.guidance.value : this.guidance,
      metricsJson: data.metricsJson.present
          ? data.metricsJson.value
          : this.metricsJson,
      dismissedAtMs: data.dismissedAtMs.present
          ? data.dismissedAtMs.value
          : this.dismissedAtMs,
      markedNotAnomalous: data.markedNotAnomalous.present
          ? data.markedNotAnomalous.value
          : this.markedNotAnomalous,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnomalyRow(')
          ..write('id: $id, ')
          ..write('tsMs: $tsMs, ')
          ..write('severity: $severity, ')
          ..write('type: $type, ')
          ..write('explanation: $explanation, ')
          ..write('guidance: $guidance, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('dismissedAtMs: $dismissedAtMs, ')
          ..write('markedNotAnomalous: $markedNotAnomalous')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tsMs,
    severity,
    type,
    explanation,
    guidance,
    metricsJson,
    dismissedAtMs,
    markedNotAnomalous,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnomalyRow &&
          other.id == this.id &&
          other.tsMs == this.tsMs &&
          other.severity == this.severity &&
          other.type == this.type &&
          other.explanation == this.explanation &&
          other.guidance == this.guidance &&
          other.metricsJson == this.metricsJson &&
          other.dismissedAtMs == this.dismissedAtMs &&
          other.markedNotAnomalous == this.markedNotAnomalous);
}

class AnomaliesCompanion extends UpdateCompanion<AnomalyRow> {
  final Value<String> id;
  final Value<int> tsMs;
  final Value<int> severity;
  final Value<String> type;
  final Value<String?> explanation;
  final Value<String?> guidance;
  final Value<String> metricsJson;
  final Value<int?> dismissedAtMs;
  final Value<bool> markedNotAnomalous;
  final Value<int> rowid;
  const AnomaliesCompanion({
    this.id = const Value.absent(),
    this.tsMs = const Value.absent(),
    this.severity = const Value.absent(),
    this.type = const Value.absent(),
    this.explanation = const Value.absent(),
    this.guidance = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.dismissedAtMs = const Value.absent(),
    this.markedNotAnomalous = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnomaliesCompanion.insert({
    required String id,
    required int tsMs,
    required int severity,
    required String type,
    this.explanation = const Value.absent(),
    this.guidance = const Value.absent(),
    required String metricsJson,
    this.dismissedAtMs = const Value.absent(),
    this.markedNotAnomalous = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tsMs = Value(tsMs),
       severity = Value(severity),
       type = Value(type),
       metricsJson = Value(metricsJson);
  static Insertable<AnomalyRow> custom({
    Expression<String>? id,
    Expression<int>? tsMs,
    Expression<int>? severity,
    Expression<String>? type,
    Expression<String>? explanation,
    Expression<String>? guidance,
    Expression<String>? metricsJson,
    Expression<int>? dismissedAtMs,
    Expression<bool>? markedNotAnomalous,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tsMs != null) 'ts_ms': tsMs,
      if (severity != null) 'severity': severity,
      if (type != null) 'type': type,
      if (explanation != null) 'explanation': explanation,
      if (guidance != null) 'guidance': guidance,
      if (metricsJson != null) 'metrics_json': metricsJson,
      if (dismissedAtMs != null) 'dismissed_at_ms': dismissedAtMs,
      if (markedNotAnomalous != null)
        'marked_not_anomalous': markedNotAnomalous,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnomaliesCompanion copyWith({
    Value<String>? id,
    Value<int>? tsMs,
    Value<int>? severity,
    Value<String>? type,
    Value<String?>? explanation,
    Value<String?>? guidance,
    Value<String>? metricsJson,
    Value<int?>? dismissedAtMs,
    Value<bool>? markedNotAnomalous,
    Value<int>? rowid,
  }) {
    return AnomaliesCompanion(
      id: id ?? this.id,
      tsMs: tsMs ?? this.tsMs,
      severity: severity ?? this.severity,
      type: type ?? this.type,
      explanation: explanation ?? this.explanation,
      guidance: guidance ?? this.guidance,
      metricsJson: metricsJson ?? this.metricsJson,
      dismissedAtMs: dismissedAtMs ?? this.dismissedAtMs,
      markedNotAnomalous: markedNotAnomalous ?? this.markedNotAnomalous,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tsMs.present) {
      map['ts_ms'] = Variable<int>(tsMs.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (guidance.present) {
      map['guidance'] = Variable<String>(guidance.value);
    }
    if (metricsJson.present) {
      map['metrics_json'] = Variable<String>(metricsJson.value);
    }
    if (dismissedAtMs.present) {
      map['dismissed_at_ms'] = Variable<int>(dismissedAtMs.value);
    }
    if (markedNotAnomalous.present) {
      map['marked_not_anomalous'] = Variable<bool>(markedNotAnomalous.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnomaliesCompanion(')
          ..write('id: $id, ')
          ..write('tsMs: $tsMs, ')
          ..write('severity: $severity, ')
          ..write('type: $type, ')
          ..write('explanation: $explanation, ')
          ..write('guidance: $guidance, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('dismissedAtMs: $dismissedAtMs, ')
          ..write('markedNotAnomalous: $markedNotAnomalous, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BaselineStatsTable extends BaselineStats
    with TableInfo<$BaselineStatsTable, BaselineStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaselineStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metricMeta = const VerificationMeta('metric');
  @override
  late final GeneratedColumn<String> metric = GeneratedColumn<String>(
    'metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bucketTodMeta = const VerificationMeta(
    'bucketTod',
  );
  @override
  late final GeneratedColumn<int> bucketTod = GeneratedColumn<int>(
    'bucket_tod',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bucketActivityMeta = const VerificationMeta(
    'bucketActivity',
  );
  @override
  late final GeneratedColumn<int> bucketActivity = GeneratedColumn<int>(
    'bucket_activity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nMeta = const VerificationMeta('n');
  @override
  late final GeneratedColumn<int> n = GeneratedColumn<int>(
    'n',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _meanMeta = const VerificationMeta('mean');
  @override
  late final GeneratedColumn<double> mean = GeneratedColumn<double>(
    'mean',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _m2Meta = const VerificationMeta('m2');
  @override
  late final GeneratedColumn<double> m2 = GeneratedColumn<double>(
    'm2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minValMeta = const VerificationMeta('minVal');
  @override
  late final GeneratedColumn<double> minVal = GeneratedColumn<double>(
    'min_val',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxValMeta = const VerificationMeta('maxVal');
  @override
  late final GeneratedColumn<double> maxVal = GeneratedColumn<double>(
    'max_val',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    metric,
    bucketTod,
    bucketActivity,
    n,
    mean,
    m2,
    minVal,
    maxVal,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'baseline_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<BaselineStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('metric')) {
      context.handle(
        _metricMeta,
        metric.isAcceptableOrUnknown(data['metric']!, _metricMeta),
      );
    } else if (isInserting) {
      context.missing(_metricMeta);
    }
    if (data.containsKey('bucket_tod')) {
      context.handle(
        _bucketTodMeta,
        bucketTod.isAcceptableOrUnknown(data['bucket_tod']!, _bucketTodMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketTodMeta);
    }
    if (data.containsKey('bucket_activity')) {
      context.handle(
        _bucketActivityMeta,
        bucketActivity.isAcceptableOrUnknown(
          data['bucket_activity']!,
          _bucketActivityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bucketActivityMeta);
    }
    if (data.containsKey('n')) {
      context.handle(_nMeta, n.isAcceptableOrUnknown(data['n']!, _nMeta));
    }
    if (data.containsKey('mean')) {
      context.handle(
        _meanMeta,
        mean.isAcceptableOrUnknown(data['mean']!, _meanMeta),
      );
    }
    if (data.containsKey('m2')) {
      context.handle(_m2Meta, m2.isAcceptableOrUnknown(data['m2']!, _m2Meta));
    }
    if (data.containsKey('min_val')) {
      context.handle(
        _minValMeta,
        minVal.isAcceptableOrUnknown(data['min_val']!, _minValMeta),
      );
    } else if (isInserting) {
      context.missing(_minValMeta);
    }
    if (data.containsKey('max_val')) {
      context.handle(
        _maxValMeta,
        maxVal.isAcceptableOrUnknown(data['max_val']!, _maxValMeta),
      );
    } else if (isInserting) {
      context.missing(_maxValMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metric, bucketTod, bucketActivity};
  @override
  BaselineStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaselineStat(
      metric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric'],
      )!,
      bucketTod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bucket_tod'],
      )!,
      bucketActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bucket_activity'],
      )!,
      n: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}n'],
      )!,
      mean: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean'],
      )!,
      m2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}m2'],
      )!,
      minVal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_val'],
      )!,
      maxVal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_val'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $BaselineStatsTable createAlias(String alias) {
    return $BaselineStatsTable(attachedDatabase, alias);
  }
}

class BaselineStat extends DataClass implements Insertable<BaselineStat> {
  final String metric;
  final int bucketTod;
  final int bucketActivity;
  final int n;
  final double mean;
  final double m2;
  final double minVal;
  final double maxVal;
  final int updatedAtMs;
  const BaselineStat({
    required this.metric,
    required this.bucketTod,
    required this.bucketActivity,
    required this.n,
    required this.mean,
    required this.m2,
    required this.minVal,
    required this.maxVal,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['metric'] = Variable<String>(metric);
    map['bucket_tod'] = Variable<int>(bucketTod);
    map['bucket_activity'] = Variable<int>(bucketActivity);
    map['n'] = Variable<int>(n);
    map['mean'] = Variable<double>(mean);
    map['m2'] = Variable<double>(m2);
    map['min_val'] = Variable<double>(minVal);
    map['max_val'] = Variable<double>(maxVal);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  BaselineStatsCompanion toCompanion(bool nullToAbsent) {
    return BaselineStatsCompanion(
      metric: Value(metric),
      bucketTod: Value(bucketTod),
      bucketActivity: Value(bucketActivity),
      n: Value(n),
      mean: Value(mean),
      m2: Value(m2),
      minVal: Value(minVal),
      maxVal: Value(maxVal),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory BaselineStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaselineStat(
      metric: serializer.fromJson<String>(json['metric']),
      bucketTod: serializer.fromJson<int>(json['bucketTod']),
      bucketActivity: serializer.fromJson<int>(json['bucketActivity']),
      n: serializer.fromJson<int>(json['n']),
      mean: serializer.fromJson<double>(json['mean']),
      m2: serializer.fromJson<double>(json['m2']),
      minVal: serializer.fromJson<double>(json['minVal']),
      maxVal: serializer.fromJson<double>(json['maxVal']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metric': serializer.toJson<String>(metric),
      'bucketTod': serializer.toJson<int>(bucketTod),
      'bucketActivity': serializer.toJson<int>(bucketActivity),
      'n': serializer.toJson<int>(n),
      'mean': serializer.toJson<double>(mean),
      'm2': serializer.toJson<double>(m2),
      'minVal': serializer.toJson<double>(minVal),
      'maxVal': serializer.toJson<double>(maxVal),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  BaselineStat copyWith({
    String? metric,
    int? bucketTod,
    int? bucketActivity,
    int? n,
    double? mean,
    double? m2,
    double? minVal,
    double? maxVal,
    int? updatedAtMs,
  }) => BaselineStat(
    metric: metric ?? this.metric,
    bucketTod: bucketTod ?? this.bucketTod,
    bucketActivity: bucketActivity ?? this.bucketActivity,
    n: n ?? this.n,
    mean: mean ?? this.mean,
    m2: m2 ?? this.m2,
    minVal: minVal ?? this.minVal,
    maxVal: maxVal ?? this.maxVal,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  BaselineStat copyWithCompanion(BaselineStatsCompanion data) {
    return BaselineStat(
      metric: data.metric.present ? data.metric.value : this.metric,
      bucketTod: data.bucketTod.present ? data.bucketTod.value : this.bucketTod,
      bucketActivity: data.bucketActivity.present
          ? data.bucketActivity.value
          : this.bucketActivity,
      n: data.n.present ? data.n.value : this.n,
      mean: data.mean.present ? data.mean.value : this.mean,
      m2: data.m2.present ? data.m2.value : this.m2,
      minVal: data.minVal.present ? data.minVal.value : this.minVal,
      maxVal: data.maxVal.present ? data.maxVal.value : this.maxVal,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaselineStat(')
          ..write('metric: $metric, ')
          ..write('bucketTod: $bucketTod, ')
          ..write('bucketActivity: $bucketActivity, ')
          ..write('n: $n, ')
          ..write('mean: $mean, ')
          ..write('m2: $m2, ')
          ..write('minVal: $minVal, ')
          ..write('maxVal: $maxVal, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    metric,
    bucketTod,
    bucketActivity,
    n,
    mean,
    m2,
    minVal,
    maxVal,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaselineStat &&
          other.metric == this.metric &&
          other.bucketTod == this.bucketTod &&
          other.bucketActivity == this.bucketActivity &&
          other.n == this.n &&
          other.mean == this.mean &&
          other.m2 == this.m2 &&
          other.minVal == this.minVal &&
          other.maxVal == this.maxVal &&
          other.updatedAtMs == this.updatedAtMs);
}

class BaselineStatsCompanion extends UpdateCompanion<BaselineStat> {
  final Value<String> metric;
  final Value<int> bucketTod;
  final Value<int> bucketActivity;
  final Value<int> n;
  final Value<double> mean;
  final Value<double> m2;
  final Value<double> minVal;
  final Value<double> maxVal;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const BaselineStatsCompanion({
    this.metric = const Value.absent(),
    this.bucketTod = const Value.absent(),
    this.bucketActivity = const Value.absent(),
    this.n = const Value.absent(),
    this.mean = const Value.absent(),
    this.m2 = const Value.absent(),
    this.minVal = const Value.absent(),
    this.maxVal = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BaselineStatsCompanion.insert({
    required String metric,
    required int bucketTod,
    required int bucketActivity,
    this.n = const Value.absent(),
    this.mean = const Value.absent(),
    this.m2 = const Value.absent(),
    required double minVal,
    required double maxVal,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : metric = Value(metric),
       bucketTod = Value(bucketTod),
       bucketActivity = Value(bucketActivity),
       minVal = Value(minVal),
       maxVal = Value(maxVal),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<BaselineStat> custom({
    Expression<String>? metric,
    Expression<int>? bucketTod,
    Expression<int>? bucketActivity,
    Expression<int>? n,
    Expression<double>? mean,
    Expression<double>? m2,
    Expression<double>? minVal,
    Expression<double>? maxVal,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (metric != null) 'metric': metric,
      if (bucketTod != null) 'bucket_tod': bucketTod,
      if (bucketActivity != null) 'bucket_activity': bucketActivity,
      if (n != null) 'n': n,
      if (mean != null) 'mean': mean,
      if (m2 != null) 'm2': m2,
      if (minVal != null) 'min_val': minVal,
      if (maxVal != null) 'max_val': maxVal,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BaselineStatsCompanion copyWith({
    Value<String>? metric,
    Value<int>? bucketTod,
    Value<int>? bucketActivity,
    Value<int>? n,
    Value<double>? mean,
    Value<double>? m2,
    Value<double>? minVal,
    Value<double>? maxVal,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return BaselineStatsCompanion(
      metric: metric ?? this.metric,
      bucketTod: bucketTod ?? this.bucketTod,
      bucketActivity: bucketActivity ?? this.bucketActivity,
      n: n ?? this.n,
      mean: mean ?? this.mean,
      m2: m2 ?? this.m2,
      minVal: minVal ?? this.minVal,
      maxVal: maxVal ?? this.maxVal,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metric.present) {
      map['metric'] = Variable<String>(metric.value);
    }
    if (bucketTod.present) {
      map['bucket_tod'] = Variable<int>(bucketTod.value);
    }
    if (bucketActivity.present) {
      map['bucket_activity'] = Variable<int>(bucketActivity.value);
    }
    if (n.present) {
      map['n'] = Variable<int>(n.value);
    }
    if (mean.present) {
      map['mean'] = Variable<double>(mean.value);
    }
    if (m2.present) {
      map['m2'] = Variable<double>(m2.value);
    }
    if (minVal.present) {
      map['min_val'] = Variable<double>(minVal.value);
    }
    if (maxVal.present) {
      map['max_val'] = Variable<double>(maxVal.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaselineStatsCompanion(')
          ..write('metric: $metric, ')
          ..write('bucketTod: $bucketTod, ')
          ..write('bucketActivity: $bucketActivity, ')
          ..write('n: $n, ')
          ..write('mean: $mean, ')
          ..write('m2: $m2, ')
          ..write('minVal: $minVal, ')
          ..write('maxVal: $maxVal, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tsMsMeta = const VerificationMeta('tsMs');
  @override
  late final GeneratedColumn<int> tsMs = GeneratedColumn<int>(
    'ts_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anomalyIdMeta = const VerificationMeta(
    'anomalyId',
  );
  @override
  late final GeneratedColumn<String> anomalyId = GeneratedColumn<String>(
    'anomaly_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    tsMs,
    role,
    content,
    anomalyId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('ts_ms')) {
      context.handle(
        _tsMsMeta,
        tsMs.isAcceptableOrUnknown(data['ts_ms']!, _tsMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tsMsMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('anomaly_id')) {
      context.handle(
        _anomalyIdMeta,
        anomalyId.isAcceptableOrUnknown(data['anomaly_id']!, _anomalyIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      tsMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ts_ms'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      anomalyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anomaly_id'],
      ),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String sessionId;
  final int tsMs;
  final int role;
  final String content;

  /// Anomaly id this message is contextually about, if any (for "explain" flow).
  final String? anomalyId;
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.tsMs,
    required this.role,
    required this.content,
    this.anomalyId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['ts_ms'] = Variable<int>(tsMs);
    map['role'] = Variable<int>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || anomalyId != null) {
      map['anomaly_id'] = Variable<String>(anomalyId);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      tsMs: Value(tsMs),
      role: Value(role),
      content: Value(content),
      anomalyId: anomalyId == null && nullToAbsent
          ? const Value.absent()
          : Value(anomalyId),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      tsMs: serializer.fromJson<int>(json['tsMs']),
      role: serializer.fromJson<int>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      anomalyId: serializer.fromJson<String?>(json['anomalyId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'tsMs': serializer.toJson<int>(tsMs),
      'role': serializer.toJson<int>(role),
      'content': serializer.toJson<String>(content),
      'anomalyId': serializer.toJson<String?>(anomalyId),
    };
  }

  ChatMessage copyWith({
    int? id,
    String? sessionId,
    int? tsMs,
    int? role,
    String? content,
    Value<String?> anomalyId = const Value.absent(),
  }) => ChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    tsMs: tsMs ?? this.tsMs,
    role: role ?? this.role,
    content: content ?? this.content,
    anomalyId: anomalyId.present ? anomalyId.value : this.anomalyId,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      tsMs: data.tsMs.present ? data.tsMs.value : this.tsMs,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      anomalyId: data.anomalyId.present ? data.anomalyId.value : this.anomalyId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('tsMs: $tsMs, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('anomalyId: $anomalyId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, tsMs, role, content, anomalyId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.tsMs == this.tsMs &&
          other.role == this.role &&
          other.content == this.content &&
          other.anomalyId == this.anomalyId);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> tsMs;
  final Value<int> role;
  final Value<String> content;
  final Value<String?> anomalyId;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.tsMs = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.anomalyId = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int tsMs,
    required int role,
    required String content,
    this.anomalyId = const Value.absent(),
  }) : sessionId = Value(sessionId),
       tsMs = Value(tsMs),
       role = Value(role),
       content = Value(content);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? tsMs,
    Expression<int>? role,
    Expression<String>? content,
    Expression<String>? anomalyId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (tsMs != null) 'ts_ms': tsMs,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (anomalyId != null) 'anomaly_id': anomalyId,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? tsMs,
    Value<int>? role,
    Value<String>? content,
    Value<String?>? anomalyId,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      tsMs: tsMs ?? this.tsMs,
      role: role ?? this.role,
      content: content ?? this.content,
      anomalyId: anomalyId ?? this.anomalyId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (tsMs.present) {
      map['ts_ms'] = Variable<int>(tsMs.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (anomalyId.present) {
      map['anomaly_id'] = Variable<String>(anomalyId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('tsMs: $tsMs, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('anomalyId: $anomalyId')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<int> sex = GeneratedColumn<int>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionsJsonMeta = const VerificationMeta(
    'conditionsJson',
  );
  @override
  late final GeneratedColumn<String> conditionsJson = GeneratedColumn<String>(
    'conditions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    username,
    sex,
    birthYear,
    heightCm,
    weightKg,
    conditionsJson,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    } else if (isInserting) {
      context.missing(_birthYearMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('conditions_json')) {
      context.handle(
        _conditionsJsonMeta,
        conditionsJson.isAcceptableOrUnknown(
          data['conditions_json']!,
          _conditionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sex'],
      )!,
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      conditionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conditions_json'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String name;
  final String? username;
  final int sex;
  final int birthYear;
  final double? heightCm;
  final double? weightKg;
  final String conditionsJson;
  final int createdAtMs;
  const Profile({
    required this.id,
    required this.name,
    this.username,
    required this.sex,
    required this.birthYear,
    this.heightCm,
    this.weightKg,
    required this.conditionsJson,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    map['sex'] = Variable<int>(sex);
    map['birth_year'] = Variable<int>(birthYear);
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    map['conditions_json'] = Variable<String>(conditionsJson);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      sex: Value(sex),
      birthYear: Value(birthYear),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      conditionsJson: Value(conditionsJson),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      username: serializer.fromJson<String?>(json['username']),
      sex: serializer.fromJson<int>(json['sex']),
      birthYear: serializer.fromJson<int>(json['birthYear']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      conditionsJson: serializer.fromJson<String>(json['conditionsJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'username': serializer.toJson<String?>(username),
      'sex': serializer.toJson<int>(sex),
      'birthYear': serializer.toJson<int>(birthYear),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'conditionsJson': serializer.toJson<String>(conditionsJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  Profile copyWith({
    int? id,
    String? name,
    Value<String?> username = const Value.absent(),
    int? sex,
    int? birthYear,
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    String? conditionsJson,
    int? createdAtMs,
  }) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    username: username.present ? username.value : this.username,
    sex: sex ?? this.sex,
    birthYear: birthYear ?? this.birthYear,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    conditionsJson: conditionsJson ?? this.conditionsJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      username: data.username.present ? data.username.value : this.username,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      conditionsJson: data.conditionsJson.present
          ? data.conditionsJson.value
          : this.conditionsJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('username: $username, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    username,
    sex,
    birthYear,
    heightCm,
    weightKg,
    conditionsJson,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.name == this.name &&
          other.username == this.username &&
          other.sex == this.sex &&
          other.birthYear == this.birthYear &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.conditionsJson == this.conditionsJson &&
          other.createdAtMs == this.createdAtMs);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> username;
  final Value<int> sex;
  final Value<int> birthYear;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String> conditionsJson;
  final Value<int> createdAtMs;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.username = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.username = const Value.absent(),
    required int sex,
    required int birthYear,
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    required int createdAtMs,
  }) : name = Value(name),
       sex = Value(sex),
       birthYear = Value(birthYear),
       createdAtMs = Value(createdAtMs);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? username,
    Expression<int>? sex,
    Expression<int>? birthYear,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? conditionsJson,
    Expression<int>? createdAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (username != null) 'username': username,
      if (sex != null) 'sex': sex,
      if (birthYear != null) 'birth_year': birthYear,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (conditionsJson != null) 'conditions_json': conditionsJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? username,
    Value<int>? sex,
    Value<int>? birthYear,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<String>? conditionsJson,
    Value<int>? createdAtMs,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      conditionsJson: conditionsJson ?? this.conditionsJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>(sex.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (conditionsJson.present) {
      map['conditions_json'] = Variable<String>(conditionsJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('username: $username, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $PpgSamplesTable ppgSamples = $PpgSamplesTable(this);
  late final $TempSamplesTable tempSamples = $TempSamplesTable(this);
  late final $ImuSamplesTable imuSamples = $ImuSamplesTable(this);
  late final $FeatureRowsTable featureRows = $FeatureRowsTable(this);
  late final $AnomaliesTable anomalies = $AnomaliesTable(this);
  late final $BaselineStatsTable baselineStats = $BaselineStatsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    ppgSamples,
    tempSamples,
    imuSamples,
    featureRows,
    anomalies,
    baselineStats,
    chatMessages,
    profiles,
  ];
}

typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      required String id,
      required String name,
      required String hardwareId,
      required int pairedAtMs,
      Value<int?> lastSeenMs,
      Value<String?> firmwareVersion,
      Value<int> rowid,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> hardwareId,
      Value<int> pairedAtMs,
      Value<int?> lastSeenMs,
      Value<String?> firmwareVersion,
      Value<int> rowid,
    });

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDb, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PpgSamplesTable, List<PpgSample>>
  _ppgSamplesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.ppgSamples,
    aliasName: $_aliasNameGenerator(db.devices.id, db.ppgSamples.deviceId),
  );

  $$PpgSamplesTableProcessedTableManager get ppgSamplesRefs {
    final manager = $$PpgSamplesTableTableManager(
      $_db,
      $_db.ppgSamples,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ppgSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TempSamplesTable, List<TempSample>>
  _tempSamplesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.tempSamples,
    aliasName: $_aliasNameGenerator(db.devices.id, db.tempSamples.deviceId),
  );

  $$TempSamplesTableProcessedTableManager get tempSamplesRefs {
    final manager = $$TempSamplesTableTableManager(
      $_db,
      $_db.tempSamples,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tempSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImuSamplesTable, List<ImuSample>>
  _imuSamplesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.imuSamples,
    aliasName: $_aliasNameGenerator(db.devices.id, db.imuSamples.deviceId),
  );

  $$ImuSamplesTableProcessedTableManager get imuSamplesRefs {
    final manager = $$ImuSamplesTableTableManager(
      $_db,
      $_db.imuSamples,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imuSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesTableFilterComposer extends Composer<_$AppDb, $DevicesTable> {
  $$DevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hardwareId => $composableBuilder(
    column: $table.hardwareId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pairedAtMs => $composableBuilder(
    column: $table.pairedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenMs => $composableBuilder(
    column: $table.lastSeenMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ppgSamplesRefs(
    Expression<bool> Function($$PpgSamplesTableFilterComposer f) f,
  ) {
    final $$PpgSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ppgSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PpgSamplesTableFilterComposer(
            $db: $db,
            $table: $db.ppgSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tempSamplesRefs(
    Expression<bool> Function($$TempSamplesTableFilterComposer f) f,
  ) {
    final $$TempSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tempSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TempSamplesTableFilterComposer(
            $db: $db,
            $table: $db.tempSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imuSamplesRefs(
    Expression<bool> Function($$ImuSamplesTableFilterComposer f) f,
  ) {
    final $$ImuSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imuSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImuSamplesTableFilterComposer(
            $db: $db,
            $table: $db.imuSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer extends Composer<_$AppDb, $DevicesTable> {
  $$DevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hardwareId => $composableBuilder(
    column: $table.hardwareId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pairedAtMs => $composableBuilder(
    column: $table.pairedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenMs => $composableBuilder(
    column: $table.lastSeenMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDb, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get hardwareId => $composableBuilder(
    column: $table.hardwareId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pairedAtMs => $composableBuilder(
    column: $table.pairedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenMs => $composableBuilder(
    column: $table.lastSeenMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => column,
  );

  Expression<T> ppgSamplesRefs<T extends Object>(
    Expression<T> Function($$PpgSamplesTableAnnotationComposer a) f,
  ) {
    final $$PpgSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ppgSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PpgSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.ppgSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tempSamplesRefs<T extends Object>(
    Expression<T> Function($$TempSamplesTableAnnotationComposer a) f,
  ) {
    final $$TempSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tempSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TempSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.tempSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> imuSamplesRefs<T extends Object>(
    Expression<T> Function($$ImuSamplesTableAnnotationComposer a) f,
  ) {
    final $$ImuSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imuSamples,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImuSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.imuSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, $$DevicesTableReferences),
          Device,
          PrefetchHooks Function({
            bool ppgSamplesRefs,
            bool tempSamplesRefs,
            bool imuSamplesRefs,
          })
        > {
  $$DevicesTableTableManager(_$AppDb db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> hardwareId = const Value.absent(),
                Value<int> pairedAtMs = const Value.absent(),
                Value<int?> lastSeenMs = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                name: name,
                hardwareId: hardwareId,
                pairedAtMs: pairedAtMs,
                lastSeenMs: lastSeenMs,
                firmwareVersion: firmwareVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String hardwareId,
                required int pairedAtMs,
                Value<int?> lastSeenMs = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                name: name,
                hardwareId: hardwareId,
                pairedAtMs: pairedAtMs,
                lastSeenMs: lastSeenMs,
                firmwareVersion: firmwareVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ppgSamplesRefs = false,
                tempSamplesRefs = false,
                imuSamplesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ppgSamplesRefs) db.ppgSamples,
                    if (tempSamplesRefs) db.tempSamples,
                    if (imuSamplesRefs) db.imuSamples,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ppgSamplesRefs)
                        await $_getPrefetchedData<
                          Device,
                          $DevicesTable,
                          PpgSample
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._ppgSamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).ppgSamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tempSamplesRefs)
                        await $_getPrefetchedData<
                          Device,
                          $DevicesTable,
                          TempSample
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._tempSamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).tempSamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imuSamplesRefs)
                        await $_getPrefetchedData<
                          Device,
                          $DevicesTable,
                          ImuSample
                        >(
                          currentTable: table,
                          referencedTable: $$DevicesTableReferences
                              ._imuSamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevicesTableReferences(
                                db,
                                table,
                                p0,
                              ).imuSamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deviceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, $$DevicesTableReferences),
      Device,
      PrefetchHooks Function({
        bool ppgSamplesRefs,
        bool tempSamplesRefs,
        bool imuSamplesRefs,
      })
    >;
typedef $$PpgSamplesTableCreateCompanionBuilder =
    PpgSamplesCompanion Function({
      Value<int> id,
      required String deviceId,
      required int tsMs,
      required double hrBpm,
      Value<double?> spo2,
      Value<Uint8List?> rawWindow,
    });
typedef $$PpgSamplesTableUpdateCompanionBuilder =
    PpgSamplesCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<int> tsMs,
      Value<double> hrBpm,
      Value<double?> spo2,
      Value<Uint8List?> rawWindow,
    });

final class $$PpgSamplesTableReferences
    extends BaseReferences<_$AppDb, $PpgSamplesTable, PpgSample> {
  $$PpgSamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$AppDb db) => db.devices.createAlias(
    $_aliasNameGenerator(db.ppgSamples.deviceId, db.devices.id),
  );

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PpgSamplesTableFilterComposer
    extends Composer<_$AppDb, $PpgSamplesTable> {
  $$PpgSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrBpm => $composableBuilder(
    column: $table.hrBpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get rawWindow => $composableBuilder(
    column: $table.rawWindow,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PpgSamplesTableOrderingComposer
    extends Composer<_$AppDb, $PpgSamplesTable> {
  $$PpgSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrBpm => $composableBuilder(
    column: $table.hrBpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spo2 => $composableBuilder(
    column: $table.spo2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get rawWindow => $composableBuilder(
    column: $table.rawWindow,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PpgSamplesTableAnnotationComposer
    extends Composer<_$AppDb, $PpgSamplesTable> {
  $$PpgSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tsMs =>
      $composableBuilder(column: $table.tsMs, builder: (column) => column);

  GeneratedColumn<double> get hrBpm =>
      $composableBuilder(column: $table.hrBpm, builder: (column) => column);

  GeneratedColumn<double> get spo2 =>
      $composableBuilder(column: $table.spo2, builder: (column) => column);

  GeneratedColumn<Uint8List> get rawWindow =>
      $composableBuilder(column: $table.rawWindow, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PpgSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $PpgSamplesTable,
          PpgSample,
          $$PpgSamplesTableFilterComposer,
          $$PpgSamplesTableOrderingComposer,
          $$PpgSamplesTableAnnotationComposer,
          $$PpgSamplesTableCreateCompanionBuilder,
          $$PpgSamplesTableUpdateCompanionBuilder,
          (PpgSample, $$PpgSamplesTableReferences),
          PpgSample,
          PrefetchHooks Function({bool deviceId})
        > {
  $$PpgSamplesTableTableManager(_$AppDb db, $PpgSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PpgSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PpgSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PpgSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> tsMs = const Value.absent(),
                Value<double> hrBpm = const Value.absent(),
                Value<double?> spo2 = const Value.absent(),
                Value<Uint8List?> rawWindow = const Value.absent(),
              }) => PpgSamplesCompanion(
                id: id,
                deviceId: deviceId,
                tsMs: tsMs,
                hrBpm: hrBpm,
                spo2: spo2,
                rawWindow: rawWindow,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required int tsMs,
                required double hrBpm,
                Value<double?> spo2 = const Value.absent(),
                Value<Uint8List?> rawWindow = const Value.absent(),
              }) => PpgSamplesCompanion.insert(
                id: id,
                deviceId: deviceId,
                tsMs: tsMs,
                hrBpm: hrBpm,
                spo2: spo2,
                rawWindow: rawWindow,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PpgSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable: $$PpgSamplesTableReferences
                                    ._deviceIdTable(db),
                                referencedColumn: $$PpgSamplesTableReferences
                                    ._deviceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PpgSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $PpgSamplesTable,
      PpgSample,
      $$PpgSamplesTableFilterComposer,
      $$PpgSamplesTableOrderingComposer,
      $$PpgSamplesTableAnnotationComposer,
      $$PpgSamplesTableCreateCompanionBuilder,
      $$PpgSamplesTableUpdateCompanionBuilder,
      (PpgSample, $$PpgSamplesTableReferences),
      PpgSample,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$TempSamplesTableCreateCompanionBuilder =
    TempSamplesCompanion Function({
      Value<int> id,
      required String deviceId,
      required int tsMs,
      required double celsius,
    });
typedef $$TempSamplesTableUpdateCompanionBuilder =
    TempSamplesCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<int> tsMs,
      Value<double> celsius,
    });

final class $$TempSamplesTableReferences
    extends BaseReferences<_$AppDb, $TempSamplesTable, TempSample> {
  $$TempSamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$AppDb db) => db.devices.createAlias(
    $_aliasNameGenerator(db.tempSamples.deviceId, db.devices.id),
  );

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TempSamplesTableFilterComposer
    extends Composer<_$AppDb, $TempSamplesTable> {
  $$TempSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get celsius => $composableBuilder(
    column: $table.celsius,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TempSamplesTableOrderingComposer
    extends Composer<_$AppDb, $TempSamplesTable> {
  $$TempSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get celsius => $composableBuilder(
    column: $table.celsius,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TempSamplesTableAnnotationComposer
    extends Composer<_$AppDb, $TempSamplesTable> {
  $$TempSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tsMs =>
      $composableBuilder(column: $table.tsMs, builder: (column) => column);

  GeneratedColumn<double> get celsius =>
      $composableBuilder(column: $table.celsius, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TempSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TempSamplesTable,
          TempSample,
          $$TempSamplesTableFilterComposer,
          $$TempSamplesTableOrderingComposer,
          $$TempSamplesTableAnnotationComposer,
          $$TempSamplesTableCreateCompanionBuilder,
          $$TempSamplesTableUpdateCompanionBuilder,
          (TempSample, $$TempSamplesTableReferences),
          TempSample,
          PrefetchHooks Function({bool deviceId})
        > {
  $$TempSamplesTableTableManager(_$AppDb db, $TempSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TempSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TempSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TempSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> tsMs = const Value.absent(),
                Value<double> celsius = const Value.absent(),
              }) => TempSamplesCompanion(
                id: id,
                deviceId: deviceId,
                tsMs: tsMs,
                celsius: celsius,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required int tsMs,
                required double celsius,
              }) => TempSamplesCompanion.insert(
                id: id,
                deviceId: deviceId,
                tsMs: tsMs,
                celsius: celsius,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TempSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable: $$TempSamplesTableReferences
                                    ._deviceIdTable(db),
                                referencedColumn: $$TempSamplesTableReferences
                                    ._deviceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TempSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TempSamplesTable,
      TempSample,
      $$TempSamplesTableFilterComposer,
      $$TempSamplesTableOrderingComposer,
      $$TempSamplesTableAnnotationComposer,
      $$TempSamplesTableCreateCompanionBuilder,
      $$TempSamplesTableUpdateCompanionBuilder,
      (TempSample, $$TempSamplesTableReferences),
      TempSample,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$ImuSamplesTableCreateCompanionBuilder =
    ImuSamplesCompanion Function({
      Value<int> id,
      required String deviceId,
      required int tsMs,
      required double ax,
      required double ay,
      required double az,
      required double gx,
      required double gy,
      required double gz,
      Value<int> activity,
    });
typedef $$ImuSamplesTableUpdateCompanionBuilder =
    ImuSamplesCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<int> tsMs,
      Value<double> ax,
      Value<double> ay,
      Value<double> az,
      Value<double> gx,
      Value<double> gy,
      Value<double> gz,
      Value<int> activity,
    });

final class $$ImuSamplesTableReferences
    extends BaseReferences<_$AppDb, $ImuSamplesTable, ImuSample> {
  $$ImuSamplesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DevicesTable _deviceIdTable(_$AppDb db) => db.devices.createAlias(
    $_aliasNameGenerator(db.imuSamples.deviceId, db.devices.id),
  );

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImuSamplesTableFilterComposer
    extends Composer<_$AppDb, $ImuSamplesTable> {
  $$ImuSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ax => $composableBuilder(
    column: $table.ax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ay => $composableBuilder(
    column: $table.ay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get az => $composableBuilder(
    column: $table.az,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gx => $composableBuilder(
    column: $table.gx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gy => $composableBuilder(
    column: $table.gy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gz => $composableBuilder(
    column: $table.gz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImuSamplesTableOrderingComposer
    extends Composer<_$AppDb, $ImuSamplesTable> {
  $$ImuSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ax => $composableBuilder(
    column: $table.ax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ay => $composableBuilder(
    column: $table.ay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get az => $composableBuilder(
    column: $table.az,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gx => $composableBuilder(
    column: $table.gx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gy => $composableBuilder(
    column: $table.gy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gz => $composableBuilder(
    column: $table.gz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImuSamplesTableAnnotationComposer
    extends Composer<_$AppDb, $ImuSamplesTable> {
  $$ImuSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tsMs =>
      $composableBuilder(column: $table.tsMs, builder: (column) => column);

  GeneratedColumn<double> get ax =>
      $composableBuilder(column: $table.ax, builder: (column) => column);

  GeneratedColumn<double> get ay =>
      $composableBuilder(column: $table.ay, builder: (column) => column);

  GeneratedColumn<double> get az =>
      $composableBuilder(column: $table.az, builder: (column) => column);

  GeneratedColumn<double> get gx =>
      $composableBuilder(column: $table.gx, builder: (column) => column);

  GeneratedColumn<double> get gy =>
      $composableBuilder(column: $table.gy, builder: (column) => column);

  GeneratedColumn<double> get gz =>
      $composableBuilder(column: $table.gz, builder: (column) => column);

  GeneratedColumn<int> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImuSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ImuSamplesTable,
          ImuSample,
          $$ImuSamplesTableFilterComposer,
          $$ImuSamplesTableOrderingComposer,
          $$ImuSamplesTableAnnotationComposer,
          $$ImuSamplesTableCreateCompanionBuilder,
          $$ImuSamplesTableUpdateCompanionBuilder,
          (ImuSample, $$ImuSamplesTableReferences),
          ImuSample,
          PrefetchHooks Function({bool deviceId})
        > {
  $$ImuSamplesTableTableManager(_$AppDb db, $ImuSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImuSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImuSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImuSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> tsMs = const Value.absent(),
                Value<double> ax = const Value.absent(),
                Value<double> ay = const Value.absent(),
                Value<double> az = const Value.absent(),
                Value<double> gx = const Value.absent(),
                Value<double> gy = const Value.absent(),
                Value<double> gz = const Value.absent(),
                Value<int> activity = const Value.absent(),
              }) => ImuSamplesCompanion(
                id: id,
                deviceId: deviceId,
                tsMs: tsMs,
                ax: ax,
                ay: ay,
                az: az,
                gx: gx,
                gy: gy,
                gz: gz,
                activity: activity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required int tsMs,
                required double ax,
                required double ay,
                required double az,
                required double gx,
                required double gy,
                required double gz,
                Value<int> activity = const Value.absent(),
              }) => ImuSamplesCompanion.insert(
                id: id,
                deviceId: deviceId,
                tsMs: tsMs,
                ax: ax,
                ay: ay,
                az: az,
                gx: gx,
                gy: gy,
                gz: gz,
                activity: activity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImuSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable: $$ImuSamplesTableReferences
                                    ._deviceIdTable(db),
                                referencedColumn: $$ImuSamplesTableReferences
                                    ._deviceIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImuSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ImuSamplesTable,
      ImuSample,
      $$ImuSamplesTableFilterComposer,
      $$ImuSamplesTableOrderingComposer,
      $$ImuSamplesTableAnnotationComposer,
      $$ImuSamplesTableCreateCompanionBuilder,
      $$ImuSamplesTableUpdateCompanionBuilder,
      (ImuSample, $$ImuSamplesTableReferences),
      ImuSample,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$FeatureRowsTableCreateCompanionBuilder =
    FeatureRowsCompanion Function({
      Value<int> id,
      required int tsMs,
      Value<int> windowS,
      required double hrMean,
      required double hrStd,
      required double hrMin,
      required double hrMax,
      required double rmssd,
      required double pnn50,
      Value<double?> spo2Mean,
      required double tempMean,
      required double tempSlope,
      required double accelMean,
      required double accelStd,
      required int activity,
      Value<double?> anomalyP,
    });
typedef $$FeatureRowsTableUpdateCompanionBuilder =
    FeatureRowsCompanion Function({
      Value<int> id,
      Value<int> tsMs,
      Value<int> windowS,
      Value<double> hrMean,
      Value<double> hrStd,
      Value<double> hrMin,
      Value<double> hrMax,
      Value<double> rmssd,
      Value<double> pnn50,
      Value<double?> spo2Mean,
      Value<double> tempMean,
      Value<double> tempSlope,
      Value<double> accelMean,
      Value<double> accelStd,
      Value<int> activity,
      Value<double?> anomalyP,
    });

class $$FeatureRowsTableFilterComposer
    extends Composer<_$AppDb, $FeatureRowsTable> {
  $$FeatureRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windowS => $composableBuilder(
    column: $table.windowS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrMean => $composableBuilder(
    column: $table.hrMean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrStd => $composableBuilder(
    column: $table.hrStd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrMin => $composableBuilder(
    column: $table.hrMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrMax => $composableBuilder(
    column: $table.hrMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rmssd => $composableBuilder(
    column: $table.rmssd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pnn50 => $composableBuilder(
    column: $table.pnn50,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spo2Mean => $composableBuilder(
    column: $table.spo2Mean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempMean => $composableBuilder(
    column: $table.tempMean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tempSlope => $composableBuilder(
    column: $table.tempSlope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelMean => $composableBuilder(
    column: $table.accelMean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelStd => $composableBuilder(
    column: $table.accelStd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get anomalyP => $composableBuilder(
    column: $table.anomalyP,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FeatureRowsTableOrderingComposer
    extends Composer<_$AppDb, $FeatureRowsTable> {
  $$FeatureRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windowS => $composableBuilder(
    column: $table.windowS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrMean => $composableBuilder(
    column: $table.hrMean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrStd => $composableBuilder(
    column: $table.hrStd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrMin => $composableBuilder(
    column: $table.hrMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrMax => $composableBuilder(
    column: $table.hrMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rmssd => $composableBuilder(
    column: $table.rmssd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pnn50 => $composableBuilder(
    column: $table.pnn50,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spo2Mean => $composableBuilder(
    column: $table.spo2Mean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempMean => $composableBuilder(
    column: $table.tempMean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tempSlope => $composableBuilder(
    column: $table.tempSlope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelMean => $composableBuilder(
    column: $table.accelMean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelStd => $composableBuilder(
    column: $table.accelStd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get anomalyP => $composableBuilder(
    column: $table.anomalyP,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FeatureRowsTableAnnotationComposer
    extends Composer<_$AppDb, $FeatureRowsTable> {
  $$FeatureRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tsMs =>
      $composableBuilder(column: $table.tsMs, builder: (column) => column);

  GeneratedColumn<int> get windowS =>
      $composableBuilder(column: $table.windowS, builder: (column) => column);

  GeneratedColumn<double> get hrMean =>
      $composableBuilder(column: $table.hrMean, builder: (column) => column);

  GeneratedColumn<double> get hrStd =>
      $composableBuilder(column: $table.hrStd, builder: (column) => column);

  GeneratedColumn<double> get hrMin =>
      $composableBuilder(column: $table.hrMin, builder: (column) => column);

  GeneratedColumn<double> get hrMax =>
      $composableBuilder(column: $table.hrMax, builder: (column) => column);

  GeneratedColumn<double> get rmssd =>
      $composableBuilder(column: $table.rmssd, builder: (column) => column);

  GeneratedColumn<double> get pnn50 =>
      $composableBuilder(column: $table.pnn50, builder: (column) => column);

  GeneratedColumn<double> get spo2Mean =>
      $composableBuilder(column: $table.spo2Mean, builder: (column) => column);

  GeneratedColumn<double> get tempMean =>
      $composableBuilder(column: $table.tempMean, builder: (column) => column);

  GeneratedColumn<double> get tempSlope =>
      $composableBuilder(column: $table.tempSlope, builder: (column) => column);

  GeneratedColumn<double> get accelMean =>
      $composableBuilder(column: $table.accelMean, builder: (column) => column);

  GeneratedColumn<double> get accelStd =>
      $composableBuilder(column: $table.accelStd, builder: (column) => column);

  GeneratedColumn<int> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<double> get anomalyP =>
      $composableBuilder(column: $table.anomalyP, builder: (column) => column);
}

class $$FeatureRowsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $FeatureRowsTable,
          FeatureRow,
          $$FeatureRowsTableFilterComposer,
          $$FeatureRowsTableOrderingComposer,
          $$FeatureRowsTableAnnotationComposer,
          $$FeatureRowsTableCreateCompanionBuilder,
          $$FeatureRowsTableUpdateCompanionBuilder,
          (FeatureRow, BaseReferences<_$AppDb, $FeatureRowsTable, FeatureRow>),
          FeatureRow,
          PrefetchHooks Function()
        > {
  $$FeatureRowsTableTableManager(_$AppDb db, $FeatureRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeatureRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeatureRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeatureRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> tsMs = const Value.absent(),
                Value<int> windowS = const Value.absent(),
                Value<double> hrMean = const Value.absent(),
                Value<double> hrStd = const Value.absent(),
                Value<double> hrMin = const Value.absent(),
                Value<double> hrMax = const Value.absent(),
                Value<double> rmssd = const Value.absent(),
                Value<double> pnn50 = const Value.absent(),
                Value<double?> spo2Mean = const Value.absent(),
                Value<double> tempMean = const Value.absent(),
                Value<double> tempSlope = const Value.absent(),
                Value<double> accelMean = const Value.absent(),
                Value<double> accelStd = const Value.absent(),
                Value<int> activity = const Value.absent(),
                Value<double?> anomalyP = const Value.absent(),
              }) => FeatureRowsCompanion(
                id: id,
                tsMs: tsMs,
                windowS: windowS,
                hrMean: hrMean,
                hrStd: hrStd,
                hrMin: hrMin,
                hrMax: hrMax,
                rmssd: rmssd,
                pnn50: pnn50,
                spo2Mean: spo2Mean,
                tempMean: tempMean,
                tempSlope: tempSlope,
                accelMean: accelMean,
                accelStd: accelStd,
                activity: activity,
                anomalyP: anomalyP,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int tsMs,
                Value<int> windowS = const Value.absent(),
                required double hrMean,
                required double hrStd,
                required double hrMin,
                required double hrMax,
                required double rmssd,
                required double pnn50,
                Value<double?> spo2Mean = const Value.absent(),
                required double tempMean,
                required double tempSlope,
                required double accelMean,
                required double accelStd,
                required int activity,
                Value<double?> anomalyP = const Value.absent(),
              }) => FeatureRowsCompanion.insert(
                id: id,
                tsMs: tsMs,
                windowS: windowS,
                hrMean: hrMean,
                hrStd: hrStd,
                hrMin: hrMin,
                hrMax: hrMax,
                rmssd: rmssd,
                pnn50: pnn50,
                spo2Mean: spo2Mean,
                tempMean: tempMean,
                tempSlope: tempSlope,
                accelMean: accelMean,
                accelStd: accelStd,
                activity: activity,
                anomalyP: anomalyP,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FeatureRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $FeatureRowsTable,
      FeatureRow,
      $$FeatureRowsTableFilterComposer,
      $$FeatureRowsTableOrderingComposer,
      $$FeatureRowsTableAnnotationComposer,
      $$FeatureRowsTableCreateCompanionBuilder,
      $$FeatureRowsTableUpdateCompanionBuilder,
      (FeatureRow, BaseReferences<_$AppDb, $FeatureRowsTable, FeatureRow>),
      FeatureRow,
      PrefetchHooks Function()
    >;
typedef $$AnomaliesTableCreateCompanionBuilder =
    AnomaliesCompanion Function({
      required String id,
      required int tsMs,
      required int severity,
      required String type,
      Value<String?> explanation,
      Value<String?> guidance,
      required String metricsJson,
      Value<int?> dismissedAtMs,
      Value<bool> markedNotAnomalous,
      Value<int> rowid,
    });
typedef $$AnomaliesTableUpdateCompanionBuilder =
    AnomaliesCompanion Function({
      Value<String> id,
      Value<int> tsMs,
      Value<int> severity,
      Value<String> type,
      Value<String?> explanation,
      Value<String?> guidance,
      Value<String> metricsJson,
      Value<int?> dismissedAtMs,
      Value<bool> markedNotAnomalous,
      Value<int> rowid,
    });

class $$AnomaliesTableFilterComposer
    extends Composer<_$AppDb, $AnomaliesTable> {
  $$AnomaliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guidance => $composableBuilder(
    column: $table.guidance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dismissedAtMs => $composableBuilder(
    column: $table.dismissedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get markedNotAnomalous => $composableBuilder(
    column: $table.markedNotAnomalous,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnomaliesTableOrderingComposer
    extends Composer<_$AppDb, $AnomaliesTable> {
  $$AnomaliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guidance => $composableBuilder(
    column: $table.guidance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dismissedAtMs => $composableBuilder(
    column: $table.dismissedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get markedNotAnomalous => $composableBuilder(
    column: $table.markedNotAnomalous,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnomaliesTableAnnotationComposer
    extends Composer<_$AppDb, $AnomaliesTable> {
  $$AnomaliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tsMs =>
      $composableBuilder(column: $table.tsMs, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guidance =>
      $composableBuilder(column: $table.guidance, builder: (column) => column);

  GeneratedColumn<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dismissedAtMs => $composableBuilder(
    column: $table.dismissedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get markedNotAnomalous => $composableBuilder(
    column: $table.markedNotAnomalous,
    builder: (column) => column,
  );
}

class $$AnomaliesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $AnomaliesTable,
          AnomalyRow,
          $$AnomaliesTableFilterComposer,
          $$AnomaliesTableOrderingComposer,
          $$AnomaliesTableAnnotationComposer,
          $$AnomaliesTableCreateCompanionBuilder,
          $$AnomaliesTableUpdateCompanionBuilder,
          (AnomalyRow, BaseReferences<_$AppDb, $AnomaliesTable, AnomalyRow>),
          AnomalyRow,
          PrefetchHooks Function()
        > {
  $$AnomaliesTableTableManager(_$AppDb db, $AnomaliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnomaliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnomaliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnomaliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> tsMs = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<String?> guidance = const Value.absent(),
                Value<String> metricsJson = const Value.absent(),
                Value<int?> dismissedAtMs = const Value.absent(),
                Value<bool> markedNotAnomalous = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnomaliesCompanion(
                id: id,
                tsMs: tsMs,
                severity: severity,
                type: type,
                explanation: explanation,
                guidance: guidance,
                metricsJson: metricsJson,
                dismissedAtMs: dismissedAtMs,
                markedNotAnomalous: markedNotAnomalous,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int tsMs,
                required int severity,
                required String type,
                Value<String?> explanation = const Value.absent(),
                Value<String?> guidance = const Value.absent(),
                required String metricsJson,
                Value<int?> dismissedAtMs = const Value.absent(),
                Value<bool> markedNotAnomalous = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnomaliesCompanion.insert(
                id: id,
                tsMs: tsMs,
                severity: severity,
                type: type,
                explanation: explanation,
                guidance: guidance,
                metricsJson: metricsJson,
                dismissedAtMs: dismissedAtMs,
                markedNotAnomalous: markedNotAnomalous,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnomaliesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $AnomaliesTable,
      AnomalyRow,
      $$AnomaliesTableFilterComposer,
      $$AnomaliesTableOrderingComposer,
      $$AnomaliesTableAnnotationComposer,
      $$AnomaliesTableCreateCompanionBuilder,
      $$AnomaliesTableUpdateCompanionBuilder,
      (AnomalyRow, BaseReferences<_$AppDb, $AnomaliesTable, AnomalyRow>),
      AnomalyRow,
      PrefetchHooks Function()
    >;
typedef $$BaselineStatsTableCreateCompanionBuilder =
    BaselineStatsCompanion Function({
      required String metric,
      required int bucketTod,
      required int bucketActivity,
      Value<int> n,
      Value<double> mean,
      Value<double> m2,
      required double minVal,
      required double maxVal,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$BaselineStatsTableUpdateCompanionBuilder =
    BaselineStatsCompanion Function({
      Value<String> metric,
      Value<int> bucketTod,
      Value<int> bucketActivity,
      Value<int> n,
      Value<double> mean,
      Value<double> m2,
      Value<double> minVal,
      Value<double> maxVal,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$BaselineStatsTableFilterComposer
    extends Composer<_$AppDb, $BaselineStatsTable> {
  $$BaselineStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bucketTod => $composableBuilder(
    column: $table.bucketTod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bucketActivity => $composableBuilder(
    column: $table.bucketActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get n => $composableBuilder(
    column: $table.n,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mean => $composableBuilder(
    column: $table.mean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get m2 => $composableBuilder(
    column: $table.m2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minVal => $composableBuilder(
    column: $table.minVal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxVal => $composableBuilder(
    column: $table.maxVal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BaselineStatsTableOrderingComposer
    extends Composer<_$AppDb, $BaselineStatsTable> {
  $$BaselineStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bucketTod => $composableBuilder(
    column: $table.bucketTod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bucketActivity => $composableBuilder(
    column: $table.bucketActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get n => $composableBuilder(
    column: $table.n,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mean => $composableBuilder(
    column: $table.mean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get m2 => $composableBuilder(
    column: $table.m2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minVal => $composableBuilder(
    column: $table.minVal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxVal => $composableBuilder(
    column: $table.maxVal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BaselineStatsTableAnnotationComposer
    extends Composer<_$AppDb, $BaselineStatsTable> {
  $$BaselineStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metric =>
      $composableBuilder(column: $table.metric, builder: (column) => column);

  GeneratedColumn<int> get bucketTod =>
      $composableBuilder(column: $table.bucketTod, builder: (column) => column);

  GeneratedColumn<int> get bucketActivity => $composableBuilder(
    column: $table.bucketActivity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get n =>
      $composableBuilder(column: $table.n, builder: (column) => column);

  GeneratedColumn<double> get mean =>
      $composableBuilder(column: $table.mean, builder: (column) => column);

  GeneratedColumn<double> get m2 =>
      $composableBuilder(column: $table.m2, builder: (column) => column);

  GeneratedColumn<double> get minVal =>
      $composableBuilder(column: $table.minVal, builder: (column) => column);

  GeneratedColumn<double> get maxVal =>
      $composableBuilder(column: $table.maxVal, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$BaselineStatsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BaselineStatsTable,
          BaselineStat,
          $$BaselineStatsTableFilterComposer,
          $$BaselineStatsTableOrderingComposer,
          $$BaselineStatsTableAnnotationComposer,
          $$BaselineStatsTableCreateCompanionBuilder,
          $$BaselineStatsTableUpdateCompanionBuilder,
          (
            BaselineStat,
            BaseReferences<_$AppDb, $BaselineStatsTable, BaselineStat>,
          ),
          BaselineStat,
          PrefetchHooks Function()
        > {
  $$BaselineStatsTableTableManager(_$AppDb db, $BaselineStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaselineStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaselineStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaselineStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> metric = const Value.absent(),
                Value<int> bucketTod = const Value.absent(),
                Value<int> bucketActivity = const Value.absent(),
                Value<int> n = const Value.absent(),
                Value<double> mean = const Value.absent(),
                Value<double> m2 = const Value.absent(),
                Value<double> minVal = const Value.absent(),
                Value<double> maxVal = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BaselineStatsCompanion(
                metric: metric,
                bucketTod: bucketTod,
                bucketActivity: bucketActivity,
                n: n,
                mean: mean,
                m2: m2,
                minVal: minVal,
                maxVal: maxVal,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String metric,
                required int bucketTod,
                required int bucketActivity,
                Value<int> n = const Value.absent(),
                Value<double> mean = const Value.absent(),
                Value<double> m2 = const Value.absent(),
                required double minVal,
                required double maxVal,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => BaselineStatsCompanion.insert(
                metric: metric,
                bucketTod: bucketTod,
                bucketActivity: bucketActivity,
                n: n,
                mean: mean,
                m2: m2,
                minVal: minVal,
                maxVal: maxVal,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BaselineStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BaselineStatsTable,
      BaselineStat,
      $$BaselineStatsTableFilterComposer,
      $$BaselineStatsTableOrderingComposer,
      $$BaselineStatsTableAnnotationComposer,
      $$BaselineStatsTableCreateCompanionBuilder,
      $$BaselineStatsTableUpdateCompanionBuilder,
      (
        BaselineStat,
        BaseReferences<_$AppDb, $BaselineStatsTable, BaselineStat>,
      ),
      BaselineStat,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      required String sessionId,
      required int tsMs,
      required int role,
      required String content,
      Value<String?> anomalyId,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> tsMs,
      Value<int> role,
      Value<String> content,
      Value<String?> anomalyId,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDb, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anomalyId => $composableBuilder(
    column: $table.anomalyId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDb, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tsMs => $composableBuilder(
    column: $table.tsMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anomalyId => $composableBuilder(
    column: $table.anomalyId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDb, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get tsMs =>
      $composableBuilder(column: $table.tsMs, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get anomalyId =>
      $composableBuilder(column: $table.anomalyId, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDb, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDb db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> tsMs = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> anomalyId = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                tsMs: tsMs,
                role: role,
                content: content,
                anomalyId: anomalyId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int tsMs,
                required int role,
                required String content,
                Value<String?> anomalyId = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                tsMs: tsMs,
                role: role,
                content: content,
                anomalyId: anomalyId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, BaseReferences<_$AppDb, $ChatMessagesTable, ChatMessage>),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> username,
      required int sex,
      required int birthYear,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String> conditionsJson,
      required int createdAtMs,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> username,
      Value<int> sex,
      Value<int> birthYear,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String> conditionsJson,
      Value<int> createdAtMs,
    });

class $$ProfilesTableFilterComposer extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDb, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDb, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDb db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> username = const Value.absent(),
                Value<int> sex = const Value.absent(),
                Value<int> birthYear = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> conditionsJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                username: username,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                weightKg: weightKg,
                conditionsJson: conditionsJson,
                createdAtMs: createdAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> username = const Value.absent(),
                required int sex,
                required int birthYear,
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String> conditionsJson = const Value.absent(),
                required int createdAtMs,
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                username: username,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                weightKg: weightKg,
                conditionsJson: conditionsJson,
                createdAtMs: createdAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDb, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$PpgSamplesTableTableManager get ppgSamples =>
      $$PpgSamplesTableTableManager(_db, _db.ppgSamples);
  $$TempSamplesTableTableManager get tempSamples =>
      $$TempSamplesTableTableManager(_db, _db.tempSamples);
  $$ImuSamplesTableTableManager get imuSamples =>
      $$ImuSamplesTableTableManager(_db, _db.imuSamples);
  $$FeatureRowsTableTableManager get featureRows =>
      $$FeatureRowsTableTableManager(_db, _db.featureRows);
  $$AnomaliesTableTableManager get anomalies =>
      $$AnomaliesTableTableManager(_db, _db.anomalies);
  $$BaselineStatsTableTableManager get baselineStats =>
      $$BaselineStatsTableTableManager(_db, _db.baselineStats);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
}
