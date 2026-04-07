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
  static const VerificationMeta _sleepOnsetLatencyMinMeta =
      const VerificationMeta('sleepOnsetLatencyMin');
  @override
  late final GeneratedColumn<int> sleepOnsetLatencyMin = GeneratedColumn<int>(
    'sleep_onset_latency_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awakeningsCountMeta = const VerificationMeta(
    'awakeningsCount',
  );
  @override
  late final GeneratedColumn<int> awakeningsCount = GeneratedColumn<int>(
    'awakenings_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wasoMinMeta = const VerificationMeta(
    'wasoMin',
  );
  @override
  late final GeneratedColumn<int> wasoMin = GeneratedColumn<int>(
    'waso_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalAwakeningMeta = const VerificationMeta(
    'finalAwakening',
  );
  @override
  late final GeneratedColumn<String> finalAwakening = GeneratedColumn<String>(
    'final_awakening',
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
  static const VerificationMeta _totalSleepTimeMinMeta = const VerificationMeta(
    'totalSleepTimeMin',
  );
  @override
  late final GeneratedColumn<int> totalSleepTimeMin = GeneratedColumn<int>(
    'total_sleep_time_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeInBedMinMeta = const VerificationMeta(
    'timeInBedMin',
  );
  @override
  late final GeneratedColumn<int> timeInBedMin = GeneratedColumn<int>(
    'time_in_bed_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepEfficiencyMeta = const VerificationMeta(
    'sleepEfficiency',
  );
  @override
  late final GeneratedColumn<double> sleepEfficiency = GeneratedColumn<double>(
    'sleep_efficiency',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepQualityMeta = const VerificationMeta(
    'sleepQuality',
  );
  @override
  late final GeneratedColumn<int> sleepQuality = GeneratedColumn<int>(
    'sleep_quality',
    aliasedName,
    false,
    check: () => sleepQuality.between(const Constant(1), const Constant(5)),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    date,
    bedtime,
    tryToSleep,
    sleepOnsetLatencyMin,
    awakeningsCount,
    wasoMin,
    finalAwakening,
    outOfBed,
    totalSleepTimeMin,
    timeInBedMin,
    sleepEfficiency,
    sleepQuality,
    medicationTaken,
    medications,
    tags,
    memo,
    createdAt,
    updatedAt,
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
    if (data.containsKey('bedtime')) {
      context.handle(
        _bedtimeMeta,
        bedtime.isAcceptableOrUnknown(data['bedtime']!, _bedtimeMeta),
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
    if (data.containsKey('sleep_onset_latency_min')) {
      context.handle(
        _sleepOnsetLatencyMinMeta,
        sleepOnsetLatencyMin.isAcceptableOrUnknown(
          data['sleep_onset_latency_min']!,
          _sleepOnsetLatencyMinMeta,
        ),
      );
    }
    if (data.containsKey('awakenings_count')) {
      context.handle(
        _awakeningsCountMeta,
        awakeningsCount.isAcceptableOrUnknown(
          data['awakenings_count']!,
          _awakeningsCountMeta,
        ),
      );
    }
    if (data.containsKey('waso_min')) {
      context.handle(
        _wasoMinMeta,
        wasoMin.isAcceptableOrUnknown(data['waso_min']!, _wasoMinMeta),
      );
    }
    if (data.containsKey('final_awakening')) {
      context.handle(
        _finalAwakeningMeta,
        finalAwakening.isAcceptableOrUnknown(
          data['final_awakening']!,
          _finalAwakeningMeta,
        ),
      );
    }
    if (data.containsKey('out_of_bed')) {
      context.handle(
        _outOfBedMeta,
        outOfBed.isAcceptableOrUnknown(data['out_of_bed']!, _outOfBedMeta),
      );
    }
    if (data.containsKey('total_sleep_time_min')) {
      context.handle(
        _totalSleepTimeMinMeta,
        totalSleepTimeMin.isAcceptableOrUnknown(
          data['total_sleep_time_min']!,
          _totalSleepTimeMinMeta,
        ),
      );
    }
    if (data.containsKey('time_in_bed_min')) {
      context.handle(
        _timeInBedMinMeta,
        timeInBedMin.isAcceptableOrUnknown(
          data['time_in_bed_min']!,
          _timeInBedMinMeta,
        ),
      );
    }
    if (data.containsKey('sleep_efficiency')) {
      context.handle(
        _sleepEfficiencyMeta,
        sleepEfficiency.isAcceptableOrUnknown(
          data['sleep_efficiency']!,
          _sleepEfficiencyMeta,
        ),
      );
    }
    if (data.containsKey('sleep_quality')) {
      context.handle(
        _sleepQualityMeta,
        sleepQuality.isAcceptableOrUnknown(
          data['sleep_quality']!,
          _sleepQualityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sleepQualityMeta);
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
      bedtime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bedtime'],
      ),
      tryToSleep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}try_to_sleep'],
      ),
      sleepOnsetLatencyMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_onset_latency_min'],
      ),
      awakeningsCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}awakenings_count'],
          )!,
      wasoMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}waso_min'],
      ),
      finalAwakening: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_awakening'],
      ),
      outOfBed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}out_of_bed'],
      ),
      totalSleepTimeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sleep_time_min'],
      ),
      timeInBedMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_in_bed_min'],
      ),
      sleepEfficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_efficiency'],
      ),
      sleepQuality:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sleep_quality'],
          )!,
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
  final String? bedtime;
  final String? tryToSleep;
  final int? sleepOnsetLatencyMin;
  final int awakeningsCount;
  final int? wasoMin;
  final String? finalAwakening;
  final String? outOfBed;
  final int? totalSleepTimeMin;
  final int? timeInBedMin;
  final double? sleepEfficiency;
  final int sleepQuality;
  final bool medicationTaken;
  final List<dynamic>? medications;
  final List<dynamic>? tags;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailySleepRecord({
    required this.date,
    this.bedtime,
    this.tryToSleep,
    this.sleepOnsetLatencyMin,
    required this.awakeningsCount,
    this.wasoMin,
    this.finalAwakening,
    this.outOfBed,
    this.totalSleepTimeMin,
    this.timeInBedMin,
    this.sleepEfficiency,
    required this.sleepQuality,
    required this.medicationTaken,
    this.medications,
    this.tags,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || bedtime != null) {
      map['bedtime'] = Variable<String>(bedtime);
    }
    if (!nullToAbsent || tryToSleep != null) {
      map['try_to_sleep'] = Variable<String>(tryToSleep);
    }
    if (!nullToAbsent || sleepOnsetLatencyMin != null) {
      map['sleep_onset_latency_min'] = Variable<int>(sleepOnsetLatencyMin);
    }
    map['awakenings_count'] = Variable<int>(awakeningsCount);
    if (!nullToAbsent || wasoMin != null) {
      map['waso_min'] = Variable<int>(wasoMin);
    }
    if (!nullToAbsent || finalAwakening != null) {
      map['final_awakening'] = Variable<String>(finalAwakening);
    }
    if (!nullToAbsent || outOfBed != null) {
      map['out_of_bed'] = Variable<String>(outOfBed);
    }
    if (!nullToAbsent || totalSleepTimeMin != null) {
      map['total_sleep_time_min'] = Variable<int>(totalSleepTimeMin);
    }
    if (!nullToAbsent || timeInBedMin != null) {
      map['time_in_bed_min'] = Variable<int>(timeInBedMin);
    }
    if (!nullToAbsent || sleepEfficiency != null) {
      map['sleep_efficiency'] = Variable<double>(sleepEfficiency);
    }
    map['sleep_quality'] = Variable<int>(sleepQuality);
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
    return map;
  }

  DailySleepRecordsCompanion toCompanion(bool nullToAbsent) {
    return DailySleepRecordsCompanion(
      date: Value(date),
      bedtime:
          bedtime == null && nullToAbsent
              ? const Value.absent()
              : Value(bedtime),
      tryToSleep:
          tryToSleep == null && nullToAbsent
              ? const Value.absent()
              : Value(tryToSleep),
      sleepOnsetLatencyMin:
          sleepOnsetLatencyMin == null && nullToAbsent
              ? const Value.absent()
              : Value(sleepOnsetLatencyMin),
      awakeningsCount: Value(awakeningsCount),
      wasoMin:
          wasoMin == null && nullToAbsent
              ? const Value.absent()
              : Value(wasoMin),
      finalAwakening:
          finalAwakening == null && nullToAbsent
              ? const Value.absent()
              : Value(finalAwakening),
      outOfBed:
          outOfBed == null && nullToAbsent
              ? const Value.absent()
              : Value(outOfBed),
      totalSleepTimeMin:
          totalSleepTimeMin == null && nullToAbsent
              ? const Value.absent()
              : Value(totalSleepTimeMin),
      timeInBedMin:
          timeInBedMin == null && nullToAbsent
              ? const Value.absent()
              : Value(timeInBedMin),
      sleepEfficiency:
          sleepEfficiency == null && nullToAbsent
              ? const Value.absent()
              : Value(sleepEfficiency),
      sleepQuality: Value(sleepQuality),
      medicationTaken: Value(medicationTaken),
      medications:
          medications == null && nullToAbsent
              ? const Value.absent()
              : Value(medications),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailySleepRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySleepRecord(
      date: serializer.fromJson<String>(json['date']),
      bedtime: serializer.fromJson<String?>(json['bedtime']),
      tryToSleep: serializer.fromJson<String?>(json['tryToSleep']),
      sleepOnsetLatencyMin: serializer.fromJson<int?>(
        json['sleepOnsetLatencyMin'],
      ),
      awakeningsCount: serializer.fromJson<int>(json['awakeningsCount']),
      wasoMin: serializer.fromJson<int?>(json['wasoMin']),
      finalAwakening: serializer.fromJson<String?>(json['finalAwakening']),
      outOfBed: serializer.fromJson<String?>(json['outOfBed']),
      totalSleepTimeMin: serializer.fromJson<int?>(json['totalSleepTimeMin']),
      timeInBedMin: serializer.fromJson<int?>(json['timeInBedMin']),
      sleepEfficiency: serializer.fromJson<double?>(json['sleepEfficiency']),
      sleepQuality: serializer.fromJson<int>(json['sleepQuality']),
      medicationTaken: serializer.fromJson<bool>(json['medicationTaken']),
      medications: serializer.fromJson<List<dynamic>?>(json['medications']),
      tags: serializer.fromJson<List<dynamic>?>(json['tags']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'bedtime': serializer.toJson<String?>(bedtime),
      'tryToSleep': serializer.toJson<String?>(tryToSleep),
      'sleepOnsetLatencyMin': serializer.toJson<int?>(sleepOnsetLatencyMin),
      'awakeningsCount': serializer.toJson<int>(awakeningsCount),
      'wasoMin': serializer.toJson<int?>(wasoMin),
      'finalAwakening': serializer.toJson<String?>(finalAwakening),
      'outOfBed': serializer.toJson<String?>(outOfBed),
      'totalSleepTimeMin': serializer.toJson<int?>(totalSleepTimeMin),
      'timeInBedMin': serializer.toJson<int?>(timeInBedMin),
      'sleepEfficiency': serializer.toJson<double?>(sleepEfficiency),
      'sleepQuality': serializer.toJson<int>(sleepQuality),
      'medicationTaken': serializer.toJson<bool>(medicationTaken),
      'medications': serializer.toJson<List<dynamic>?>(medications),
      'tags': serializer.toJson<List<dynamic>?>(tags),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailySleepRecord copyWith({
    String? date,
    Value<String?> bedtime = const Value.absent(),
    Value<String?> tryToSleep = const Value.absent(),
    Value<int?> sleepOnsetLatencyMin = const Value.absent(),
    int? awakeningsCount,
    Value<int?> wasoMin = const Value.absent(),
    Value<String?> finalAwakening = const Value.absent(),
    Value<String?> outOfBed = const Value.absent(),
    Value<int?> totalSleepTimeMin = const Value.absent(),
    Value<int?> timeInBedMin = const Value.absent(),
    Value<double?> sleepEfficiency = const Value.absent(),
    int? sleepQuality,
    bool? medicationTaken,
    Value<List<dynamic>?> medications = const Value.absent(),
    Value<List<dynamic>?> tags = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailySleepRecord(
    date: date ?? this.date,
    bedtime: bedtime.present ? bedtime.value : this.bedtime,
    tryToSleep: tryToSleep.present ? tryToSleep.value : this.tryToSleep,
    sleepOnsetLatencyMin:
        sleepOnsetLatencyMin.present
            ? sleepOnsetLatencyMin.value
            : this.sleepOnsetLatencyMin,
    awakeningsCount: awakeningsCount ?? this.awakeningsCount,
    wasoMin: wasoMin.present ? wasoMin.value : this.wasoMin,
    finalAwakening:
        finalAwakening.present ? finalAwakening.value : this.finalAwakening,
    outOfBed: outOfBed.present ? outOfBed.value : this.outOfBed,
    totalSleepTimeMin:
        totalSleepTimeMin.present
            ? totalSleepTimeMin.value
            : this.totalSleepTimeMin,
    timeInBedMin: timeInBedMin.present ? timeInBedMin.value : this.timeInBedMin,
    sleepEfficiency:
        sleepEfficiency.present ? sleepEfficiency.value : this.sleepEfficiency,
    sleepQuality: sleepQuality ?? this.sleepQuality,
    medicationTaken: medicationTaken ?? this.medicationTaken,
    medications: medications.present ? medications.value : this.medications,
    tags: tags.present ? tags.value : this.tags,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailySleepRecord copyWithCompanion(DailySleepRecordsCompanion data) {
    return DailySleepRecord(
      date: data.date.present ? data.date.value : this.date,
      bedtime: data.bedtime.present ? data.bedtime.value : this.bedtime,
      tryToSleep:
          data.tryToSleep.present ? data.tryToSleep.value : this.tryToSleep,
      sleepOnsetLatencyMin:
          data.sleepOnsetLatencyMin.present
              ? data.sleepOnsetLatencyMin.value
              : this.sleepOnsetLatencyMin,
      awakeningsCount:
          data.awakeningsCount.present
              ? data.awakeningsCount.value
              : this.awakeningsCount,
      wasoMin: data.wasoMin.present ? data.wasoMin.value : this.wasoMin,
      finalAwakening:
          data.finalAwakening.present
              ? data.finalAwakening.value
              : this.finalAwakening,
      outOfBed: data.outOfBed.present ? data.outOfBed.value : this.outOfBed,
      totalSleepTimeMin:
          data.totalSleepTimeMin.present
              ? data.totalSleepTimeMin.value
              : this.totalSleepTimeMin,
      timeInBedMin:
          data.timeInBedMin.present
              ? data.timeInBedMin.value
              : this.timeInBedMin,
      sleepEfficiency:
          data.sleepEfficiency.present
              ? data.sleepEfficiency.value
              : this.sleepEfficiency,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySleepRecord(')
          ..write('date: $date, ')
          ..write('bedtime: $bedtime, ')
          ..write('tryToSleep: $tryToSleep, ')
          ..write('sleepOnsetLatencyMin: $sleepOnsetLatencyMin, ')
          ..write('awakeningsCount: $awakeningsCount, ')
          ..write('wasoMin: $wasoMin, ')
          ..write('finalAwakening: $finalAwakening, ')
          ..write('outOfBed: $outOfBed, ')
          ..write('totalSleepTimeMin: $totalSleepTimeMin, ')
          ..write('timeInBedMin: $timeInBedMin, ')
          ..write('sleepEfficiency: $sleepEfficiency, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('medicationTaken: $medicationTaken, ')
          ..write('medications: $medications, ')
          ..write('tags: $tags, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    bedtime,
    tryToSleep,
    sleepOnsetLatencyMin,
    awakeningsCount,
    wasoMin,
    finalAwakening,
    outOfBed,
    totalSleepTimeMin,
    timeInBedMin,
    sleepEfficiency,
    sleepQuality,
    medicationTaken,
    medications,
    tags,
    memo,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySleepRecord &&
          other.date == this.date &&
          other.bedtime == this.bedtime &&
          other.tryToSleep == this.tryToSleep &&
          other.sleepOnsetLatencyMin == this.sleepOnsetLatencyMin &&
          other.awakeningsCount == this.awakeningsCount &&
          other.wasoMin == this.wasoMin &&
          other.finalAwakening == this.finalAwakening &&
          other.outOfBed == this.outOfBed &&
          other.totalSleepTimeMin == this.totalSleepTimeMin &&
          other.timeInBedMin == this.timeInBedMin &&
          other.sleepEfficiency == this.sleepEfficiency &&
          other.sleepQuality == this.sleepQuality &&
          other.medicationTaken == this.medicationTaken &&
          other.medications == this.medications &&
          other.tags == this.tags &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailySleepRecordsCompanion extends UpdateCompanion<DailySleepRecord> {
  final Value<String> date;
  final Value<String?> bedtime;
  final Value<String?> tryToSleep;
  final Value<int?> sleepOnsetLatencyMin;
  final Value<int> awakeningsCount;
  final Value<int?> wasoMin;
  final Value<String?> finalAwakening;
  final Value<String?> outOfBed;
  final Value<int?> totalSleepTimeMin;
  final Value<int?> timeInBedMin;
  final Value<double?> sleepEfficiency;
  final Value<int> sleepQuality;
  final Value<bool> medicationTaken;
  final Value<List<dynamic>?> medications;
  final Value<List<dynamic>?> tags;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailySleepRecordsCompanion({
    this.date = const Value.absent(),
    this.bedtime = const Value.absent(),
    this.tryToSleep = const Value.absent(),
    this.sleepOnsetLatencyMin = const Value.absent(),
    this.awakeningsCount = const Value.absent(),
    this.wasoMin = const Value.absent(),
    this.finalAwakening = const Value.absent(),
    this.outOfBed = const Value.absent(),
    this.totalSleepTimeMin = const Value.absent(),
    this.timeInBedMin = const Value.absent(),
    this.sleepEfficiency = const Value.absent(),
    this.sleepQuality = const Value.absent(),
    this.medicationTaken = const Value.absent(),
    this.medications = const Value.absent(),
    this.tags = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySleepRecordsCompanion.insert({
    required String date,
    this.bedtime = const Value.absent(),
    this.tryToSleep = const Value.absent(),
    this.sleepOnsetLatencyMin = const Value.absent(),
    this.awakeningsCount = const Value.absent(),
    this.wasoMin = const Value.absent(),
    this.finalAwakening = const Value.absent(),
    this.outOfBed = const Value.absent(),
    this.totalSleepTimeMin = const Value.absent(),
    this.timeInBedMin = const Value.absent(),
    this.sleepEfficiency = const Value.absent(),
    required int sleepQuality,
    this.medicationTaken = const Value.absent(),
    this.medications = const Value.absent(),
    this.tags = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       sleepQuality = Value(sleepQuality);
  static Insertable<DailySleepRecord> custom({
    Expression<String>? date,
    Expression<String>? bedtime,
    Expression<String>? tryToSleep,
    Expression<int>? sleepOnsetLatencyMin,
    Expression<int>? awakeningsCount,
    Expression<int>? wasoMin,
    Expression<String>? finalAwakening,
    Expression<String>? outOfBed,
    Expression<int>? totalSleepTimeMin,
    Expression<int>? timeInBedMin,
    Expression<double>? sleepEfficiency,
    Expression<int>? sleepQuality,
    Expression<bool>? medicationTaken,
    Expression<String>? medications,
    Expression<String>? tags,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (bedtime != null) 'bedtime': bedtime,
      if (tryToSleep != null) 'try_to_sleep': tryToSleep,
      if (sleepOnsetLatencyMin != null)
        'sleep_onset_latency_min': sleepOnsetLatencyMin,
      if (awakeningsCount != null) 'awakenings_count': awakeningsCount,
      if (wasoMin != null) 'waso_min': wasoMin,
      if (finalAwakening != null) 'final_awakening': finalAwakening,
      if (outOfBed != null) 'out_of_bed': outOfBed,
      if (totalSleepTimeMin != null) 'total_sleep_time_min': totalSleepTimeMin,
      if (timeInBedMin != null) 'time_in_bed_min': timeInBedMin,
      if (sleepEfficiency != null) 'sleep_efficiency': sleepEfficiency,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (medicationTaken != null) 'medication_taken': medicationTaken,
      if (medications != null) 'medications': medications,
      if (tags != null) 'tags': tags,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySleepRecordsCompanion copyWith({
    Value<String>? date,
    Value<String?>? bedtime,
    Value<String?>? tryToSleep,
    Value<int?>? sleepOnsetLatencyMin,
    Value<int>? awakeningsCount,
    Value<int?>? wasoMin,
    Value<String?>? finalAwakening,
    Value<String?>? outOfBed,
    Value<int?>? totalSleepTimeMin,
    Value<int?>? timeInBedMin,
    Value<double?>? sleepEfficiency,
    Value<int>? sleepQuality,
    Value<bool>? medicationTaken,
    Value<List<dynamic>?>? medications,
    Value<List<dynamic>?>? tags,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DailySleepRecordsCompanion(
      date: date ?? this.date,
      bedtime: bedtime ?? this.bedtime,
      tryToSleep: tryToSleep ?? this.tryToSleep,
      sleepOnsetLatencyMin: sleepOnsetLatencyMin ?? this.sleepOnsetLatencyMin,
      awakeningsCount: awakeningsCount ?? this.awakeningsCount,
      wasoMin: wasoMin ?? this.wasoMin,
      finalAwakening: finalAwakening ?? this.finalAwakening,
      outOfBed: outOfBed ?? this.outOfBed,
      totalSleepTimeMin: totalSleepTimeMin ?? this.totalSleepTimeMin,
      timeInBedMin: timeInBedMin ?? this.timeInBedMin,
      sleepEfficiency: sleepEfficiency ?? this.sleepEfficiency,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      medicationTaken: medicationTaken ?? this.medicationTaken,
      medications: medications ?? this.medications,
      tags: tags ?? this.tags,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (bedtime.present) {
      map['bedtime'] = Variable<String>(bedtime.value);
    }
    if (tryToSleep.present) {
      map['try_to_sleep'] = Variable<String>(tryToSleep.value);
    }
    if (sleepOnsetLatencyMin.present) {
      map['sleep_onset_latency_min'] = Variable<int>(
        sleepOnsetLatencyMin.value,
      );
    }
    if (awakeningsCount.present) {
      map['awakenings_count'] = Variable<int>(awakeningsCount.value);
    }
    if (wasoMin.present) {
      map['waso_min'] = Variable<int>(wasoMin.value);
    }
    if (finalAwakening.present) {
      map['final_awakening'] = Variable<String>(finalAwakening.value);
    }
    if (outOfBed.present) {
      map['out_of_bed'] = Variable<String>(outOfBed.value);
    }
    if (totalSleepTimeMin.present) {
      map['total_sleep_time_min'] = Variable<int>(totalSleepTimeMin.value);
    }
    if (timeInBedMin.present) {
      map['time_in_bed_min'] = Variable<int>(timeInBedMin.value);
    }
    if (sleepEfficiency.present) {
      map['sleep_efficiency'] = Variable<double>(sleepEfficiency.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySleepRecordsCompanion(')
          ..write('date: $date, ')
          ..write('bedtime: $bedtime, ')
          ..write('tryToSleep: $tryToSleep, ')
          ..write('sleepOnsetLatencyMin: $sleepOnsetLatencyMin, ')
          ..write('awakeningsCount: $awakeningsCount, ')
          ..write('wasoMin: $wasoMin, ')
          ..write('finalAwakening: $finalAwakening, ')
          ..write('outOfBed: $outOfBed, ')
          ..write('totalSleepTimeMin: $totalSleepTimeMin, ')
          ..write('timeInBedMin: $timeInBedMin, ')
          ..write('sleepEfficiency: $sleepEfficiency, ')
          ..write('sleepQuality: $sleepQuality, ')
          ..write('medicationTaken: $medicationTaken, ')
          ..write('medications: $medications, ')
          ..write('tags: $tags, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  late final $MedicationPresetsTable medicationPresets =
      $MedicationPresetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dailySleepRecords,
    medicationPresets,
  ];
}

typedef $$DailySleepRecordsTableCreateCompanionBuilder =
    DailySleepRecordsCompanion Function({
      required String date,
      Value<String?> bedtime,
      Value<String?> tryToSleep,
      Value<int?> sleepOnsetLatencyMin,
      Value<int> awakeningsCount,
      Value<int?> wasoMin,
      Value<String?> finalAwakening,
      Value<String?> outOfBed,
      Value<int?> totalSleepTimeMin,
      Value<int?> timeInBedMin,
      Value<double?> sleepEfficiency,
      required int sleepQuality,
      Value<bool> medicationTaken,
      Value<List<dynamic>?> medications,
      Value<List<dynamic>?> tags,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$DailySleepRecordsTableUpdateCompanionBuilder =
    DailySleepRecordsCompanion Function({
      Value<String> date,
      Value<String?> bedtime,
      Value<String?> tryToSleep,
      Value<int?> sleepOnsetLatencyMin,
      Value<int> awakeningsCount,
      Value<int?> wasoMin,
      Value<String?> finalAwakening,
      Value<String?> outOfBed,
      Value<int?> totalSleepTimeMin,
      Value<int?> timeInBedMin,
      Value<double?> sleepEfficiency,
      Value<int> sleepQuality,
      Value<bool> medicationTaken,
      Value<List<dynamic>?> medications,
      Value<List<dynamic>?> tags,
      Value<String?> memo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
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

  ColumnFilters<String> get bedtime => $composableBuilder(
    column: $table.bedtime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tryToSleep => $composableBuilder(
    column: $table.tryToSleep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepOnsetLatencyMin => $composableBuilder(
    column: $table.sleepOnsetLatencyMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awakeningsCount => $composableBuilder(
    column: $table.awakeningsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wasoMin => $composableBuilder(
    column: $table.wasoMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalAwakening => $composableBuilder(
    column: $table.finalAwakening,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outOfBed => $composableBuilder(
    column: $table.outOfBed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSleepTimeMin => $composableBuilder(
    column: $table.totalSleepTimeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeInBedMin => $composableBuilder(
    column: $table.timeInBedMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepEfficiency => $composableBuilder(
    column: $table.sleepEfficiency,
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

  ColumnOrderings<String> get bedtime => $composableBuilder(
    column: $table.bedtime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tryToSleep => $composableBuilder(
    column: $table.tryToSleep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepOnsetLatencyMin => $composableBuilder(
    column: $table.sleepOnsetLatencyMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awakeningsCount => $composableBuilder(
    column: $table.awakeningsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wasoMin => $composableBuilder(
    column: $table.wasoMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalAwakening => $composableBuilder(
    column: $table.finalAwakening,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outOfBed => $composableBuilder(
    column: $table.outOfBed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSleepTimeMin => $composableBuilder(
    column: $table.totalSleepTimeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeInBedMin => $composableBuilder(
    column: $table.timeInBedMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepEfficiency => $composableBuilder(
    column: $table.sleepEfficiency,
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

  GeneratedColumn<String> get bedtime =>
      $composableBuilder(column: $table.bedtime, builder: (column) => column);

  GeneratedColumn<String> get tryToSleep => $composableBuilder(
    column: $table.tryToSleep,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepOnsetLatencyMin => $composableBuilder(
    column: $table.sleepOnsetLatencyMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awakeningsCount => $composableBuilder(
    column: $table.awakeningsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wasoMin =>
      $composableBuilder(column: $table.wasoMin, builder: (column) => column);

  GeneratedColumn<String> get finalAwakening => $composableBuilder(
    column: $table.finalAwakening,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outOfBed =>
      $composableBuilder(column: $table.outOfBed, builder: (column) => column);

  GeneratedColumn<int> get totalSleepTimeMin => $composableBuilder(
    column: $table.totalSleepTimeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeInBedMin => $composableBuilder(
    column: $table.timeInBedMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sleepEfficiency => $composableBuilder(
    column: $table.sleepEfficiency,
    builder: (column) => column,
  );

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
                Value<String?> bedtime = const Value.absent(),
                Value<String?> tryToSleep = const Value.absent(),
                Value<int?> sleepOnsetLatencyMin = const Value.absent(),
                Value<int> awakeningsCount = const Value.absent(),
                Value<int?> wasoMin = const Value.absent(),
                Value<String?> finalAwakening = const Value.absent(),
                Value<String?> outOfBed = const Value.absent(),
                Value<int?> totalSleepTimeMin = const Value.absent(),
                Value<int?> timeInBedMin = const Value.absent(),
                Value<double?> sleepEfficiency = const Value.absent(),
                Value<int> sleepQuality = const Value.absent(),
                Value<bool> medicationTaken = const Value.absent(),
                Value<List<dynamic>?> medications = const Value.absent(),
                Value<List<dynamic>?> tags = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySleepRecordsCompanion(
                date: date,
                bedtime: bedtime,
                tryToSleep: tryToSleep,
                sleepOnsetLatencyMin: sleepOnsetLatencyMin,
                awakeningsCount: awakeningsCount,
                wasoMin: wasoMin,
                finalAwakening: finalAwakening,
                outOfBed: outOfBed,
                totalSleepTimeMin: totalSleepTimeMin,
                timeInBedMin: timeInBedMin,
                sleepEfficiency: sleepEfficiency,
                sleepQuality: sleepQuality,
                medicationTaken: medicationTaken,
                medications: medications,
                tags: tags,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<String?> bedtime = const Value.absent(),
                Value<String?> tryToSleep = const Value.absent(),
                Value<int?> sleepOnsetLatencyMin = const Value.absent(),
                Value<int> awakeningsCount = const Value.absent(),
                Value<int?> wasoMin = const Value.absent(),
                Value<String?> finalAwakening = const Value.absent(),
                Value<String?> outOfBed = const Value.absent(),
                Value<int?> totalSleepTimeMin = const Value.absent(),
                Value<int?> timeInBedMin = const Value.absent(),
                Value<double?> sleepEfficiency = const Value.absent(),
                required int sleepQuality,
                Value<bool> medicationTaken = const Value.absent(),
                Value<List<dynamic>?> medications = const Value.absent(),
                Value<List<dynamic>?> tags = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySleepRecordsCompanion.insert(
                date: date,
                bedtime: bedtime,
                tryToSleep: tryToSleep,
                sleepOnsetLatencyMin: sleepOnsetLatencyMin,
                awakeningsCount: awakeningsCount,
                wasoMin: wasoMin,
                finalAwakening: finalAwakening,
                outOfBed: outOfBed,
                totalSleepTimeMin: totalSleepTimeMin,
                timeInBedMin: timeInBedMin,
                sleepEfficiency: sleepEfficiency,
                sleepQuality: sleepQuality,
                medicationTaken: medicationTaken,
                medications: medications,
                tags: tags,
                memo: memo,
                createdAt: createdAt,
                updatedAt: updatedAt,
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
  $$MedicationPresetsTableTableManager get medicationPresets =>
      $$MedicationPresetsTableTableManager(_db, _db.medicationPresets);
}
