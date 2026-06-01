import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

part 'database.g.dart';

class JsonListConverter extends TypeConverter<List<dynamic>, String> {
  const JsonListConverter();
  @override
  List<dynamic> fromSql(String fromDb) => json.decode(fromDb) as List<dynamic>;
  @override
  String toSql(List<dynamic> value) => json.encode(value);
}

@DataClassName('DailySleepRecord')
class DailySleepRecords extends Table {
  TextColumn get date => text().withLength(min: 10, max: 10)(); 
  IntColumn get sleepQuality => integer().nullable().withDefault(const Constant(3))();
  BoolColumn get medicationTaken => boolean().withDefault(const Constant(false))();
  TextColumn get medications => text().map(const JsonListConverter()).nullable()();
  TextColumn get tags => text().map(const JsonListConverter()).nullable()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get tryToSleep => text().nullable()();
  TextColumn get outOfBed => text().nullable()();
  TextColumn get bedtime => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

@DataClassName('SleepSession')
class SleepSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text().withLength(min: 10, max: 10)(); 
  IntColumn get startUnix => integer()(); 
  IntColumn get endUnix => integer().nullable()(); 
  TextColumn get timezone => text().withDefault(const Constant('UTC'))(); 
  IntColumn get offsetSeconds => integer().withDefault(const Constant(0))(); 
  TextColumn get type => text().withDefault(const Constant('sleep'))(); 
}

@DataClassName('MedicationPreset')
class MedicationPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get defaultTime => text().nullable()();
}

@DriftDatabase(tables: [DailySleepRecords, SleepSessions, MedicationPresets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5; 

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 5) {
        await m.createTable(sleepSessions);
        await m.createTable(medicationPresets);
        try { await m.addColumn(dailySleepRecords, dailySleepRecords.tryToSleep); } catch(_) {}
        try { await m.addColumn(dailySleepRecords, dailySleepRecords.outOfBed); } catch(_) {}
      }
    },
  );

  Future<void> migrateOldDataToSessions() async {
    final allDaily = await select(dailySleepRecords).get();
    
    // 1. 복용 기록 마이그레이션 (개별 레코드 단위로 항상 체크)
    for (var record in allDaily) {
      if (record.medications != null) {
        final List<dynamic> meds = List.from(record.medications!);
        bool changed = false;
        for (var i = 0; i < meds.length; i++) {
          final med = Map<String, dynamic>.from(meds[i] as Map);
          // unix 필드가 없는 예전 데이터라면
          if (med['unix'] == null && med['timestamp'] != null) {
            try {
              final ts = DateTime.parse(med['timestamp'] as String);
              med['unix'] = ts.millisecondsSinceEpoch ~/ 1000;
              med['offset'] = ts.timeZoneOffset.inSeconds;
              meds[i] = med;
              changed = true;
            } catch (e) {
              print("[MIGRATION] Med parse error for ${record.date}: $e");
            }
          }
        }
        if (changed) {
          await (update(dailySleepRecords)..where((t) => t.date.equals(record.date))).write(
            DailySleepRecordsCompanion(medications: Value(meds)),
          );
          print("[MIGRATION] Migrated medication for ${record.date}");
        }
      }
    }

    // 2. 수면 세션 마이그레이션 (세션 테이블이 비어있을 때만 수행)
    final existingSessions = await select(sleepSessions).get();
    if (existingSessions.isEmpty) {
      for (var record in allDaily) {
        if (record.tryToSleep != null && record.outOfBed != null) {
          try {
            final partsS = record.tryToSleep!.split(':');
            final partsE = record.outOfBed!.split(':');
            final baseDate = DateTime.parse(record.date);
            final startDT = DateTime(baseDate.year, baseDate.month, baseDate.day, int.parse(partsS[0]), int.parse(partsS[1]));
            var endDT = DateTime(baseDate.year, baseDate.month, baseDate.day, int.parse(partsE[0]), int.parse(partsE[1]));
            if (endDT.isBefore(startDT)) endDT = endDT.add(const Duration(days: 1));
            await addSleepSession(date: record.date, start: startDT, end: endDT);
            print("[MIGRATION] Migrated sleep session for ${record.date}");
          } catch (e) {
            print("[MIGRATION] Sleep migration error for ${record.date}: $e");
          }
        }
      }
    }
  }

  Future<DailySleepRecord?> getRecordByDate(String date) => (select(dailySleepRecords)..where((t) => t.date.equals(date))).getSingleOrNull();

  Stream<List<DailySleepRecord>> watchRecordsInPeriod(DateTime start, DateTime end) {
    final f = DateFormat('yyyy-MM-dd');
    return (select(dailySleepRecords)
          ..where((t) => t.date.isBetweenValues(f.format(start), f.format(end)))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]))
        .watch();
  }

  Stream<List<SleepSession>> watchSessionsInPeriod(DateTime start, DateTime end) {
    final f = DateFormat('yyyy-MM-dd');
    return (select(sleepSessions)
          ..where((t) => t.date.isBetweenValues(f.format(start), f.format(end))))
        .watch();
  }

  Future<void> addSleepSession({required String date, required DateTime start, required DateTime end, String type = 'sleep'}) async {
    await into(sleepSessions).insert(SleepSessionsCompanion.insert(
      date: date,
      startUnix: start.millisecondsSinceEpoch ~/ 1000,
      endUnix: Value(end.millisecondsSinceEpoch ~/ 1000),
      timezone: Value(DateTime.now().timeZoneName),
      offsetSeconds: Value(DateTime.now().timeZoneOffset.inSeconds),
      type: Value(type),
    ));
    await into(dailySleepRecords).insertOnConflictUpdate(DailySleepRecordsCompanion(
      date: Value(date),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteSession(int id) => (delete(sleepSessions)..where((t) => t.id.equals(id))).go();

  Future<void> deleteMedicationIntake(String date, String unixId) async {
    final existing = await getRecordByDate(date);
    if (existing != null && existing.medications != null) {
      final List<dynamic> meds = List.from(existing.medications!);
      meds.removeWhere((m) => m['unix'].toString() == unixId);
      await (update(dailySleepRecords)..where((t) => t.date.equals(date))).write(
        DailySleepRecordsCompanion(
          medications: Value(meds),
          medicationTaken: Value(meds.isNotEmpty),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> logMedicationIntake({DateTime? dateTime}) async {
    final targetTime = dateTime ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(targetTime);
    final existing = await getRecordByDate(dateStr);
    List<dynamic> meds = (existing != null && existing.medications != null) ? List.from(existing.medications!) : [];
    meds.add({
      'time': DateFormat('HH:mm').format(targetTime), 
      'timestamp': targetTime.toIso8601String(),
      'unix': targetTime.millisecondsSinceEpoch ~/ 1000,
      'offset': targetTime.timeZoneOffset.inSeconds,
    });
    await into(dailySleepRecords).insertOnConflictUpdate(DailySleepRecordsCompanion(
      date: Value(dateStr),
      medicationTaken: const Value(true),
      medications: Value(meds),
      updatedAt: Value(DateTime.now()),
    ));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
