// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DailySleepRecordsTable extends DailySleepRecords
    with TableInfo<$DailySleepRecordsTable, DailySleepRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySleepRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
    'sleep_quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _medicationTakenMeta = const VerificationMeta(
    'medicationTaken',
  );
  @override
  late final GeneratedColumn<bool> medicationTaken = GeneratedColumn<bool>(
    'medication_taken',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("medication_taken" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<dynamic>?, String>
  medications = GeneratedColumn<String>(
    'medications',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<dynamic>?>(
    $DailySleepRecordsTable.$convertermedicationsn,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<dynamic>?, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<dynamic>?>($DailySleepRecordsTable.$convertertagsn);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _tryToSleepMeta = const VerificationMeta(
    'tryToSleep',
  );
  @override
  late final GeneratedColumn<String> tryToSleep = GeneratedColumn<String>(
    'try_to_sleep',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outOfBedMeta = const VerificationMeta(
    'outOfBed',
  );
  @override
  late final GeneratedColumn<String> outOfBed = GeneratedColumn<String>(
    'out_of_bed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bedtimeMeta = const VerificationMeta(
    'bedtime',
  );
  @override
  late final GeneratedColumn<String> bedtime = GeneratedColumn<String>(
    'bedtime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    sleepQuality,
    medicationTaken,
    medications,
    tags,
    memo,
    createdAt,
    updatedAt,
    tryToSleep,
    outOfBed,
    bedtime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_sleep_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySleepRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    }
    if (data.containsKey('medication_taken')) {
      context.handle(
        _medicationTakenMeta,
        medicationTaken.isAcceptableOrUnknown(
          data['medication_taken']!,
          _medicationTakenMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('try_to_sleep')) {
      context.handle(
        _tryToSleepMeta,
        tryToSleep.isAcceptableOrUnknown(
          data['try_to_sleep']!,
          _tryToSleepMeta,
        ),
      );
    }
    if (data.containsKey('out_of_bed')) {
      context.handle(
        _outOfBedMeta,
        outOfBed.isAcceptableOrUnknown(data['out_of_bed']!, _outOfBedMeta),
      );
    }
    if (data.containsKey('bedtime')) {
      context.handle(
        _bedtimeMeta,
        bedtime.isAcceptableOrUnknown(data['bedtime']!, _bedtimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailySleepRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySleepRecord(
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}date'],
          )!,
      sleepQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_quality'],
      ),
      medicationTaken:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}medication_taken'],
          )!,
      medications: $DailySleepRecordsTable.$convertermedicationsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}medications'],
        ),
      ),
      tags: $DailySleepRecordsTable.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
      tryToSleep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}try_to_sleep'],
      ),
      outOfBed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}out_of_bed'],
      ),
      bedtime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bedtime'],
      ),
    );
  }

  @override
  $DailySleepRecordsTable createAlias(String alias) {
    return $DailySleepRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<dynamic>, String> $convertermedications =
      const JsonListConverter();
  static TypeConverter<List<dynamic>?, String?> $convertermedicationsn =
      NullAwareTypeConverter.wrap($convertermedications);
  static TypeConverter<List<dynamic>, String> $convertertags =
      const JsonListConverter();
  static TypeConverter<List<dynamic>?, String?> $convertertagsn =
      NullAwareTypeConverter.wrap($convertertags);
}

class DailySleepRecord extends DataClass
    implements Insertable<DailySleepRecord> {
  final String date;
  final int? sleepQuality;
  final bool medicationTaken;
  final List<dynamic>? medications;
  final List<dynamic>? tags;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? tryToSleep;
  final String? outOfBed;
  final String? bedtime;
  const DailySleepRecord({
    required this.date,
    this.sleepQuality,
    required this.medicationTaken,
    this.medications,
    this.tags,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
    this.tryToSleep,
    this.outOfBed,
    this.bedtime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || sleepQuality != null) {
      map['sleep_quality'] = Variable<int>(sleepQuality);
    }
    map['medication_taken'] = Variable<bool>(medicationTaken);
    if (!nullToAbsent || medications != null) {
      map['medications'] = Variable<String>(
        $DailySleepRecordsTable.$convertermedicationsn.toSql(medications),
      );
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(
        $DailySleepRecordsTable.$convertertagsn.toSql(tags),
      );
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || tryToSleep != null) {
      map['try_to_sleep'] = Variable<String>(tryToSleep);
    }
    if (!nullToAbsent || outOfBed != null) {
      map['out_of_bed'] = Variable<String>(outOfBed);
    }
    if (!nullToAbsent || bedtime != null) {
      map['bedtime'] = Variable<String>(bedtime);
    }
    return map;
  }

  DailySleepRecordsCompanion toCompanion(bool nullToAbsent) {
    return DailySleepRecordsCompanion(
      date: Value(date),
      sleepQuality:
          sleepQuality == null && nullToAbsent
              ? const Value.absent()
              : Value(sleepQuality),
      medicationTaken: Value(medicationTaken),
      medications:
          medications == null && nullToAbsent
              ? const Value.absent()
              : Value(medications),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tryToSleep:
          tryToSleep == null && nullToAbsent
              ? const Value.absent()
              : Value(tryToSleep),
      outOfBed:
          outOfBed == null && nullToAbsent
              ? const Value.absent()
              : Value(outOfBed),
      bedtime:
          bedtime == null && nullToAbsent
              ? const Value.absent()
              : Value(bedtime),
    );
  }

  factory DailySleepRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySleepRecord(
      date: serializer.fromJson<String>(json['date']),
      sleepQuality: serializer.fromJson<int?>(json['sleepQuality']),
      medicationTaken: serializer.fromJson<bool>(json['medicationTaken']),
      medications: serializer.fromJson<List<dynamic>?>(json['medications']),
      tags: serializer.fromJson<List<dynamic>?>(json['tags']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tryToSleep: serializer.fromJson<String?>(json['tryToSleep']),
      outOfBed: serializer.fromJson<String?>(json['outOfBed']),
      bedtime: serializer.fromJson<String?>(json['bedtime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'sleepQuality': serializer.toJson<int?>(sleepQuality),
      'medicationTaken': serializer.toJson<bool>(medicationTaken),
      'medications': serializer.toJson<List<dynamic>?>(medications),
      'tags': serializer.toJson<List<dynamic>?>(tags),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tryToSleep': serializer.toJson<String?>(tryToSleep),
      'outOfBed': serializer.toJson<String?>(outOfBed),
      'bedtime': serializer.toJson<String?>(bedtime),
    };
  }

  DailySleepRecord copyWith({
    String? date,
    Value<int?> sleepQuality = const Value.absent(),
    bool? medicationTaken,
    Value<List<dynamic>?> medications = const Value.absent(),
    Value<List<dynamic>?> tags = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> tryToSleep = const Value.absent(),
    Value<String?> outOfBed = const Value.absent(),
    Value<String?> bedtime = const Value.absent(),
  }) => DailySleepRecord(
    date: date ?? this.date,
    sleepQuality: sleepQuality.present ? sleepQuality.value : this.sleepQuality,
    medicationTaken: medicationTaken ?? this.medicationTaken,
    medications: medications.present ? medications.value : this.medications,
    tags: tags.present ? tags.value : this.tags,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tryToSleep: tryToSleep.present ? tryToSleep.value : this.tryToSleep,
    outOfBed: outOfBed.present ? outOfBed.value : this.outOfBed,
    bedtime: bedtime.present ? bedtime.value : this.bedtime,
  );
  DailySleepRecord copyWithCompanion(DailySleepRecordsCompanion data) {
    return DailySleepRecord(
      date: data.date.present ? data.date.value : this.date,
      sleepQuality:
          data.sleepQuality.present
              ? data.sleepQuality.value
              : this.sleepQuality,
      medicationTaken:
          data.medicationTaken.present
              ? data.medicationTaken.value
              : this.medicationTaken,
      medications:
          data.medications.present ? data.medications.value : this.medications,
      tags: data.tags.present ? data.tags.value : this.tags,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tryToSleep:
          data.tryToSleep.present ? data.tryToSleep.value : this.tryToSleep,
      outOfBed: data.outOfBed.present ? data.outOfBed.value : this.outOfBed,
      bedtime: data.bedtime.present ? data.bedtime.value : this.bedtime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySleepRecord(')
          ..write('date: $date, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('medicationTaken: $medicationTaken, ')
          ..write('medications: $medications, ')
          ..write('tags: $tags, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tryToSleep: $tryToSleep, ')
          ..write('outOfBed: $outOfBed, ')
          ..write('bedtime: $bedtime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    sleepQuality,
    medicationTaken,
    medications,
    tags,
    memo,
    createdAt,
    updatedAt,
    tryToSleep,
    outOfBed,
    bedtime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySleepRecord &&
          other.date == this.date &&
          other.sleepQuality == this.sleepQuality &&
          other.medicationTaken == this.medicationTaken &&
          other.medications == this.medications &&
          other.tags == this.tags &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tryToSleep == this.tryToSleep &&
          other.outOfBed == this.outOfBed &&
          other.bedtime == this.bedtime);
}

class DailySleepRecordsCompanion extends UpdateCompanion<DailySleepRecord> {
  final Value<String> date;
  final Value<int?> sleepQuality;
  final Value<bool> medicationTaken;
  final Value<List<dynamic>?> medications;
  final Value<List<dynamic>?> tags;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> tryToSleep;
  final Value<String?> outOfBed;
  final Value<String?> bedtime;
  final Value<int> rowid;
  const DailySleepRecordsCompanion({
    this.date = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.medicationTaken = const Value.absent(),
    this.medications = const Value.absent(),
    this.tags = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tryToSleep = const Value.absent(),
    this.outOfBed = const Value.absent(),
    this.bedtime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySleepRecordsCompanion.insert({
    required String date,
    this.sleepQuality = const Value.absent(),
    this.medicationTaken = const Value.absent(),
    this.medications = const Value.absent(),
    this.tags = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tryToSleep = const Value.absent(),
    this.outOfBed = const Value.absent(),
    this.bedtime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailySleepRecord> custom({
    Expression<String>? date,
    Expression<int>? sleepQuality,
    Expression<bool>? medicationTaken,
    Expression<String>? medications,
    Expression<String>? tags,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? tryToSleep,
    Expression<String>? outOfBed,
    Expression<String>? bedtime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (medicationTaken != null) 'medication_taken': medicationTaken,
      if (medications != null) 'medications': medications,
      if (tags != null) 'tags': tags,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tryToSleep != null) 'try_to_sleep': tryToSleep,
      if (outOfBed != null) 'out_of_bed': outOfBed,
      if (bedtime != null) 'bedtime': bedtime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySleepRecordsCompanion copyWith({
    Value<String>? date,
    Value<int?>? sleepQuality,
    Value<bool>? medicationTaken,
    Value<List<dynamic>?>? medications,
    Value<List<dynamic>?>? tags,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? tryToSleep,
    Value<String?>? outOfBed,
    Value<String?>? bedtime,
    Value<int>? rowid,
  }) {
    return DailySleepRecordsCompanion(
      date: date ?? this.date,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      medicationTaken: medicationTaken ?? this.medicationTaken,
      medications: medications ?? this.medications,
      tags: tags ?? this.tags,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tryToSleep: tryToSleep ?? this.tryToSleep,
      outOfBed: outOfBed ?? this.outOfBed,
      bedtime: bedtime ?? this.bedtime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (sleepQuality.present) {
      map['sleep_quality'] = Variable<int>(sleepQuality.value);
    }
    if (medicationTaken.present) {
      map['medication_taken'] = Variable<bool>(medicationTaken.value);
    }
    if (medications.present) {
      map['medications'] = Variable<String>(
        $DailySleepRecordsTable.$convertermedicationsn.toSql(medications.value),
      );
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $DailySleepRecordsTable.$convertertagsn.toSql(tags.value),
      );
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tryToSleep.present) {
      map['try_to_sleep'] = Variable<String>(tryToSleep.value);
    }
    if (outOfBed.present) {
      map['out_of_bed'] = Variable<String>(outOfBed.value);
    }
    if (bedtime.present) {
      map['bedtime'] = Variable<String>(bedtime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySleepRecordsCompanion(')
          ..write('date: $date, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('medicationTaken: $medicationTaken, ')
          ..write('medications: $medications, ')
          ..write('tags: $tags, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tryToSleep: $tryToSleep, ')
          ..write('outOfBed: $outOfBed, ')
          ..write('bedtime: $bedtime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepSessionsTable extends SleepSessions
    with TableInfo<$SleepSessionsTable, SleepSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 10,
      maxTextLength: 10,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startUnixMeta = const VerificationMeta(
    'startUnix',
  );
  @override
  late final GeneratedColumn<int> startUnix = GeneratedColumn<int>(
    'start_unix',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endUnixMeta = const VerificationMeta(
    'endUnix',
  );
  @override
  late final GeneratedColumn<int> endUnix = GeneratedColumn<int>(
    'end_unix',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UTC'),
  );
  static const VerificationMeta _offsetSecondsMeta = const VerificationMeta(
    'offsetSeconds',
  );
  @override
  late final GeneratedColumn<int> offsetSeconds = GeneratedColumn<int>(
    'offset_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sleep'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    startUnix,
    endUnix,
    timezone,
    offsetSeconds,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_unix')) {
      context.handle(
        _startUnixMeta,
        startUnix.isAcceptableOrUnknown(data['start_unix']!, _startUnixMeta),
      );
    } else if (isInserting) {
      context.missing(_startUnixMeta);
    }
    if (data.containsKey('end_unix')) {
      context.handle(
        _endUnixMeta,
        endUnix.isAcceptableOrUnknown(data['end_unix']!, _endUnixMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('offset_seconds')) {
      context.handle(
        _offsetSecondsMeta,
        offsetSeconds.isAcceptableOrUnknown(
          data['offset_seconds']!,
          _offsetSecondsMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepSession(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}date'],
          )!,
      startUnix:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}start_unix'],
          )!,
      endUnix: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_unix'],
      ),
      timezone:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}timezone'],
          )!,
      offsetSeconds:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}offset_seconds'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
    );
  }

  @override
  $SleepSessionsTable createAlias(String alias) {
    return $SleepSessionsTable(attachedDatabase, alias);
  }
}

class SleepSession extends DataClass implements Insertable<SleepSession> {
  final int id;
  final String date;
  final int startUnix;
  final int? endUnix;
  final String timezone;
  final int offsetSeconds;
  final String type;
  const SleepSession({
    required this.id,
    required this.date,
    required this.startUnix,
    this.endUnix,
    required this.timezone,
    required this.offsetSeconds,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['start_unix'] = Variable<int>(startUnix);
    if (!nullToAbsent || endUnix != null) {
      map['end_unix'] = Variable<int>(endUnix);
    }
    map['timezone'] = Variable<String>(timezone);
    map['offset_seconds'] = Variable<int>(offsetSeconds);
    map['type'] = Variable<String>(type);
    return map;
  }

  SleepSessionsCompanion toCompanion(bool nullToAbsent) {
    return SleepSessionsCompanion(
      id: Value(id),
      date: Value(date),
      startUnix: Value(startUnix),
      endUnix:
          endUnix == null && nullToAbsent
              ? const Value.absent()
              : Value(endUnix),
      timezone: Value(timezone),
      offsetSeconds: Value(offsetSeconds),
      type: Value(type),
    );
  }

  factory SleepSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepSession(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      startUnix: serializer.fromJson<int>(json['startUnix']),
      endUnix: serializer.fromJson<int?>(json['endUnix']),
      timezone: serializer.fromJson<String>(json['timezone']),
      offsetSeconds: serializer.fromJson<int>(json['offsetSeconds']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'startUnix': serializer.toJson<int>(startUnix),
      'endUnix': serializer.toJson<int?>(endUnix),
      'timezone': serializer.toJson<String>(timezone),
      'offsetSeconds': serializer.toJson<int>(offsetSeconds),
      'type': serializer.toJson<String>(type),
    };
  }

  SleepSession copyWith({
    int? id,
    String? date,
    int? startUnix,
    Value<int?> endUnix = const Value.absent(),
    String? timezone,
    int? offsetSeconds,
    String? type,
  }) => SleepSession(
    id: id ?? this.id,
    date: date ?? this.date,
    startUnix: startUnix ?? this.startUnix,
    endUnix: endUnix.present ? endUnix.value : this.endUnix,
    timezone: timezone ?? this.timezone,
    offsetSeconds: offsetSeconds ?? this.offsetSeconds,
    type: type ?? this.type,
  );
  SleepSession copyWithCompanion(SleepSessionsCompanion data) {
    return SleepSession(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      startUnix: data.startUnix.present ? data.startUnix.value : this.startUnix,
      endUnix: data.endUnix.present ? data.endUnix.value : this.endUnix,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      offsetSeconds:
          data.offsetSeconds.present
              ? data.offsetSeconds.value
              : this.offsetSeconds,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepSession(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('startUnix: $startUnix, ')
          ..write('endUnix: $endUnix, ')
          ..write('timezone: $timezone, ')
          ..write('offsetSeconds: $offsetSeconds, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, startUnix, endUnix, timezone, offsetSeconds, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepSession &&
          other.id == this.id &&
          other.date == this.date &&
          other.startUnix == this.startUnix &&
          other.endUnix == this.endUnix &&
          other.timezone == this.timezone &&
          other.offsetSeconds == this.offsetSeconds &&
          other.type == this.type);
}

class SleepSessionsCompanion extends UpdateCompanion<SleepSession> {
  final Value<int> id;
  final Value<String> date;
  final Value<int> startUnix;
  final Value<int?> endUnix;
  final Value<String> timezone;
  final Value<int> offsetSeconds;
  final Value<String> type;
  const SleepSessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.startUnix = const Value.absent(),
    this.endUnix = const Value.absent(),
    this.timezone = const Value.absent(),
    this.offsetSeconds = const Value.absent(),
    this.type = const Value.absent(),
  });
  SleepSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required int startUnix,
    this.endUnix = const Value.absent(),
    this.timezone = const Value.absent(),
    this.offsetSeconds = const Value.absent(),
    this.type = const Value.absent(),
  }) : date = Value(date),
       startUnix = Value(startUnix);
  static Insertable<SleepSession> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<int>? startUnix,
    Expression<int>? endUnix,
    Expression<String>? timezone,
    Expression<int>? offsetSeconds,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (startUnix != null) 'start_unix': startUnix,
      if (endUnix != null) 'end_unix': endUnix,
      if (timezone != null) 'timezone': timezone,
      if (offsetSeconds != null) 'offset_seconds': offsetSeconds,
      if (type != null) 'type': type,
    });
  }

  SleepSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<int>? startUnix,
    Value<int?>? endUnix,
    Value<String>? timezone,
    Value<int>? offsetSeconds,
    Value<String>? type,
  }) {
    return SleepSessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      startUnix: startUnix ?? this.startUnix,
      endUnix: endUnix ?? this.endUnix,
      timezone: timezone ?? this.timezone,
      offsetSeconds: offsetSeconds ?? this.offsetSeconds,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (startUnix.present) {
      map['start_unix'] = Variable<int>(startUnix.value);
    }
    if (endUnix.present) {
      map['end_unix'] = Variable<int>(endUnix.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (offsetSeconds.present) {
      map['offset_seconds'] = Variable<int>(offsetSeconds.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepSessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('startUnix: $startUnix, ')
          ..write('endUnix: $endUnix, ')
          ..write('timezone: $timezone, ')
          ..write('offsetSeconds: $offsetSeconds, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $MedicationPresetsTable extends MedicationPresets
    with TableInfo<$MedicationPresetsTable, MedicationPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationPresetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultTimeMeta = const VerificationMeta(
    'defaultTime',
  );
  @override
  late final GeneratedColumn<String> defaultTime = GeneratedColumn<String>(
    'default_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, dosage, defaultTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationPreset> instance, {
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
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('default_time')) {
      context.handle(
        _defaultTimeMeta,
        defaultTime.isAcceptableOrUnknown(
          data['default_time']!,
          _defaultTimeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationPreset(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      dosage:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}dosage'],
          )!,
      defaultTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_time'],
      ),
    );
  }

  @override
  $MedicationPresetsTable createAlias(String alias) {
    return $MedicationPresetsTable(attachedDatabase, alias);
  }
}

class MedicationPreset extends DataClass
    implements Insertable<MedicationPreset> {
  final int id;
  final String name;
  final String dosage;
  final String? defaultTime;
  const MedicationPreset({
    required this.id,
    required this.name,
    required this.dosage,
    this.defaultTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    if (!nullToAbsent || defaultTime != null) {
      map['default_time'] = Variable<String>(defaultTime);
    }
    return map;
  }

  MedicationPresetsCompanion toCompanion(bool nullToAbsent) {
    return MedicationPresetsCompanion(
      id: Value(id),
      name: Value(name),
      dosage: Value(dosage),
      defaultTime:
          defaultTime == null && nullToAbsent
              ? const Value.absent()
              : Value(defaultTime),
    );
  }

  factory MedicationPreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationPreset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      defaultTime: serializer.fromJson<String?>(json['defaultTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'defaultTime': serializer.toJson<String?>(defaultTime),
    };
  }

  MedicationPreset copyWith({
    int? id,
    String? name,
    String? dosage,
    Value<String?> defaultTime = const Value.absent(),
  }) => MedicationPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
    defaultTime: defaultTime.present ? defaultTime.value : this.defaultTime,
  );
  MedicationPreset copyWithCompanion(MedicationPresetsCompanion data) {
    return MedicationPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      defaultTime:
          data.defaultTime.present ? data.defaultTime.value : this.defaultTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('defaultTime: $defaultTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, dosage, defaultTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.defaultTime == this.defaultTime);
}

class MedicationPresetsCompanion extends UpdateCompanion<MedicationPreset> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> dosage;
  final Value<String?> defaultTime;
  const MedicationPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.defaultTime = const Value.absent(),
  });
  MedicationPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String dosage,
    this.defaultTime = const Value.absent(),
  }) : name = Value(name),
       dosage = Value(dosage);
  static Insertable<MedicationPreset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<String>? defaultTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (defaultTime != null) 'default_time': defaultTime,
    });
  }

  MedicationPresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? dosage,
    Value<String?>? defaultTime,
  }) {
    return MedicationPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      defaultTime: defaultTime ?? this.defaultTime,
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
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (defaultTime.present) {
      map['default_time'] = Variable<String>(defaultTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('defaultTime: $defaultTime')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailySleepRecordsTable dailySleepRecords =
      $DailySleepRecordsTable(this);
  late final $SleepSessionsTable sleepSessions = $SleepSessionsTable(this);
  late final $MedicationPresetsTable medicationPresets =
      $MedicationPresetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dailySleepRecords,
    sleepSessions,
    medicationPresets,
  ];
}

typedef $$DailySleepRecordsTableCreateCompanionBuilder =
    DailySleepRecordsCompanion Function({
      required String date,
      Value<int?> sleepQuality,
      Value<bool> medicationTaken,
      Value<List<dynamic>?> medications,
      Value<List<dynamic>?> tags,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> tryToSleep,
      Value<String?> outOfBed,
      Value<String?> bedtime,
      Value<int> rowid,
    });
typedef $$DailySleepRecordsTableUpdateCompanionBuilder =
    DailySleepRecordsCompanion Function({
      Value<String> date,
      Value<int?> sleepQuality,
      Value<bool> medicationTaken,
      Value<List<dynamic>?> medications,
      Value<List<dynamic>?> tags,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> tryToSleep,
      Value<String?> outOfBed,
      Value<String?> bedtime,
      Value<int> rowid,
    });

class $$DailySleepRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DailySleepRecordsTable> {
  $$DailySleepRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get medicationTaken => $composableBuilder(
    column: $table.medicationTaken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<dynamic>?, List<dynamic>, String>
  get medications => $composableBuilder(
    column: $table.medications,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<dynamic>?, List<dynamic>, String>
  get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tryToSleep => $composableBuilder(
    column: $table.tryToSleep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outOfBed => $composableBuilder(
    column: $table.outOfBed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bedtime => $composableBuilder(
    column: $table.bedtime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySleepRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySleepRecordsTable> {
  $$DailySleepRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get medicationTaken => $composableBuilder(
    column: $table.medicationTaken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medications => $composableBuilder(
    column: $table.medications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tryToSleep => $composableBuilder(
    column: $table.tryToSleep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outOfBed => $composableBuilder(
    column: $table.outOfBed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bedtime => $composableBuilder(
    column: $table.bedtime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySleepRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySleepRecordsTable> {
  $$DailySleepRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get sleepQuality => $composableBuilder(
    column: $table.sleepQuality,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get medicationTaken => $composableBuilder(
    column: $table.medicationTaken,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<dynamic>?, String> get medications =>
      $composableBuilder(
        column: $table.medications,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<dynamic>?, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get tryToSleep => $composableBuilder(
    column: $table.tryToSleep,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outOfBed =>
      $composableBuilder(column: $table.outOfBed, builder: (column) => column);

  GeneratedColumn<String> get bedtime =>
      $composableBuilder(column: $table.bedtime, builder: (column) => column);
}

class $$DailySleepRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySleepRecordsTable,
          DailySleepRecord,
          $$DailySleepRecordsTableFilterComposer,
          $$DailySleepRecordsTableOrderingComposer,
          $$DailySleepRecordsTableAnnotationComposer,
          $$DailySleepRecordsTableCreateCompanionBuilder,
          $$DailySleepRecordsTableUpdateCompanionBuilder,
          (
            DailySleepRecord,
            BaseReferences<
              _$AppDatabase,
              $DailySleepRecordsTable,
              DailySleepRecord
            >,
          ),
          DailySleepRecord,
          PrefetchHooks Function()
        > {
  $$DailySleepRecordsTableTableManager(
    _$AppDatabase db,
    $DailySleepRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DailySleepRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$DailySleepRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$DailySleepRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int?> sleepQuality = const Value.absent(),
                Value<bool> medicationTaken = const Value.absent(),
                Value<List<dynamic>?> medications = const Value.absent(),
                Value<List<dynamic>?> tags = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> tryToSleep = const Value.absent(),
                Value<String?> outOfBed = const Value.absent(),
                Value<String?> bedtime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySleepRecordsCompanion(
                date: date,
                sleepQuality: sleepQuality,
                medicationTaken: medicationTaken,
                medications: medications,
                tags: tags,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tryToSleep: tryToSleep,
                outOfBed: outOfBed,
                bedtime: bedtime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int?> sleepQuality = const Value.absent(),
                Value<bool> medicationTaken = const Value.absent(),
                Value<List<dynamic>?> medications = const Value.absent(),
                Value<List<dynamic>?> tags = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> tryToSleep = const Value.absent(),
                Value<String?> outOfBed = const Value.absent(),
                Value<String?> bedtime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySleepRecordsCompanion.insert(
                date: date,
                sleepQuality: sleepQuality,
                medicationTaken: medicationTaken,
                medications: medications,
                tags: tags,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tryToSleep: tryToSleep,
                outOfBed: outOfBed,
                bedtime: bedtime,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySleepRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySleepRecordsTable,
      DailySleepRecord,
      $$DailySleepRecordsTableFilterComposer,
      $$DailySleepRecordsTableOrderingComposer,
      $$DailySleepRecordsTableAnnotationComposer,
      $$DailySleepRecordsTableCreateCompanionBuilder,
      $$DailySleepRecordsTableUpdateCompanionBuilder,
      (
        DailySleepRecord,
        BaseReferences<
          _$AppDatabase,
          $DailySleepRecordsTable,
          DailySleepRecord
        >,
      ),
      DailySleepRecord,
      PrefetchHooks Function()
    >;
typedef $$SleepSessionsTableCreateCompanionBuilder =
    SleepSessionsCompanion Function({
      Value<int> id,
      required String date,
      required int startUnix,
      Value<int?> endUnix,
      Value<String> timezone,
      Value<int> offsetSeconds,
      Value<String> type,
    });
typedef $$SleepSessionsTableUpdateCompanionBuilder =
    SleepSessionsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<int> startUnix,
      Value<int?> endUnix,
      Value<String> timezone,
      Value<int> offsetSeconds,
      Value<String> type,
    });

class $$SleepSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startUnix => $composableBuilder(
    column: $table.startUnix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endUnix => $composableBuilder(
    column: $table.endUnix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get offsetSeconds => $composableBuilder(
    column: $table.offsetSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startUnix => $composableBuilder(
    column: $table.startUnix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endUnix => $composableBuilder(
    column: $table.endUnix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get offsetSeconds => $composableBuilder(
    column: $table.offsetSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepSessionsTable> {
  $$SleepSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get startUnix =>
      $composableBuilder(column: $table.startUnix, builder: (column) => column);

  GeneratedColumn<int> get endUnix =>
      $composableBuilder(column: $table.endUnix, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get offsetSeconds => $composableBuilder(
    column: $table.offsetSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$SleepSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepSessionsTable,
          SleepSession,
          $$SleepSessionsTableFilterComposer,
          $$SleepSessionsTableOrderingComposer,
          $$SleepSessionsTableAnnotationComposer,
          $$SleepSessionsTableCreateCompanionBuilder,
          $$SleepSessionsTableUpdateCompanionBuilder,
          (
            SleepSession,
            BaseReferences<_$AppDatabase, $SleepSessionsTable, SleepSession>,
          ),
          SleepSession,
          PrefetchHooks Function()
        > {
  $$SleepSessionsTableTableManager(_$AppDatabase db, $SleepSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SleepSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SleepSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SleepSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> startUnix = const Value.absent(),
                Value<int?> endUnix = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> offsetSeconds = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => SleepSessionsCompanion(
                id: id,
                date: date,
                startUnix: startUnix,
                endUnix: endUnix,
                timezone: timezone,
                offsetSeconds: offsetSeconds,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required int startUnix,
                Value<int?> endUnix = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> offsetSeconds = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => SleepSessionsCompanion.insert(
                id: id,
                date: date,
                startUnix: startUnix,
                endUnix: endUnix,
                timezone: timezone,
                offsetSeconds: offsetSeconds,
                type: type,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepSessionsTable,
      SleepSession,
      $$SleepSessionsTableFilterComposer,
      $$SleepSessionsTableOrderingComposer,
      $$SleepSessionsTableAnnotationComposer,
      $$SleepSessionsTableCreateCompanionBuilder,
      $$SleepSessionsTableUpdateCompanionBuilder,
      (
        SleepSession,
        BaseReferences<_$AppDatabase, $SleepSessionsTable, SleepSession>,
      ),
      SleepSession,
      PrefetchHooks Function()
    >;
typedef $$MedicationPresetsTableCreateCompanionBuilder =
    MedicationPresetsCompanion Function({
      Value<int> id,
      required String name,
      required String dosage,
      Value<String?> defaultTime,
    });
typedef $$MedicationPresetsTableUpdateCompanionBuilder =
    MedicationPresetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> dosage,
      Value<String?> defaultTime,
    });

class $$MedicationPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationPresetsTable> {
  $$MedicationPresetsTableFilterComposer({
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

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultTime => $composableBuilder(
    column: $table.defaultTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationPresetsTable> {
  $$MedicationPresetsTableOrderingComposer({
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

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultTime => $composableBuilder(
    column: $table.defaultTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationPresetsTable> {
  $$MedicationPresetsTableAnnotationComposer({
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

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get defaultTime => $composableBuilder(
    column: $table.defaultTime,
    builder: (column) => column,
  );
}

class $$MedicationPresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationPresetsTable,
          MedicationPreset,
          $$MedicationPresetsTableFilterComposer,
          $$MedicationPresetsTableOrderingComposer,
          $$MedicationPresetsTableAnnotationComposer,
          $$MedicationPresetsTableCreateCompanionBuilder,
          $$MedicationPresetsTableUpdateCompanionBuilder,
          (
            MedicationPreset,
            BaseReferences<
              _$AppDatabase,
              $MedicationPresetsTable,
              MedicationPreset
            >,
          ),
          MedicationPreset,
          PrefetchHooks Function()
        > {
  $$MedicationPresetsTableTableManager(
    _$AppDatabase db,
    $MedicationPresetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MedicationPresetsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$MedicationPresetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$MedicationPresetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<String?> defaultTime = const Value.absent(),
              }) => MedicationPresetsCompanion(
                id: id,
                name: name,
                dosage: dosage,
                defaultTime: defaultTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String dosage,
                Value<String?> defaultTime = const Value.absent(),
              }) => MedicationPresetsCompanion.insert(
                id: id,
                name: name,
                dosage: dosage,
                defaultTime: defaultTime,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationPresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationPresetsTable,
      MedicationPreset,
      $$MedicationPresetsTableFilterComposer,
      $$MedicationPresetsTableOrderingComposer,
      $$MedicationPresetsTableAnnotationComposer,
      $$MedicationPresetsTableCreateCompanionBuilder,
      $$MedicationPresetsTableUpdateCompanionBuilder,
      (
        MedicationPreset,
        BaseReferences<
          _$AppDatabase,
          $MedicationPresetsTable,
          MedicationPreset
        >,
      ),
      MedicationPreset,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailySleepRecordsTableTableManager get dailySleepRecords =>
      $$DailySleepRecordsTableTableManager(_db, _db.dailySleepRecords);
  $$SleepSessionsTableTableManager get sleepSessions =>
      $$SleepSessionsTableTableManager(_db, _db.sleepSessions);
  $$MedicationPresetsTableTableManager get medicationPresets =>
      $$MedicationPresetsTableTableManager(_db, _db.medicationPresets);
}
