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

class DailySleepRecords extends Table {
  TextColumn get date => text().withLength(min: 10, max: 10)(); 
  TextColumn get bedtime => text().nullable()();
  TextColumn get tryToSleep => text().nullable()();
  IntColumn get sleepOnsetLatencyMin => integer().nullable()();
  IntColumn get awakeningsCount => integer().withDefault(const Constant(0))();
  IntColumn get wasoMin => integer().nullable()();
  TextColumn get finalAwakening => text().nullable()();
  TextColumn get outOfBed => text().nullable()();
  IntColumn get totalSleepTimeMin => integer().nullable()();
  IntColumn get timeInBedMin => integer().nullable()();
  RealColumn get sleepEfficiency => real().nullable()();
  
  // nullable()을 설정하고 기본값(Constant(3))을 주어 저장이 거부되지 않게 합니다.
  IntColumn get sleepQuality => integer().nullable().withDefault(const Constant(3))();
  
  BoolColumn get medicationTaken => boolean().withDefault(const Constant(false))();
  TextColumn get medications => text().map(const JsonListConverter()).nullable()();
  TextColumn get tags => text().map(const JsonListConverter()).nullable()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {date};
}

class MedicationPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dosage => text()();
  TextColumn get defaultTime => text().nullable()();
}

@DriftDatabase(tables: [DailySleepRecords, MedicationPresets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4; // 버전을 다시 올립니다.

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // 개발 중에는 스키마가 변경되면 테이블을 완전히 새로 고침 합니다.
      if (from < 4) {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
          await m.createTable(table);
        }
      }
    },
  );

  Future<List<DailySleepRecord>> getAllRecords() => select(dailySleepRecords).get();

  Future<List<DailySleepRecord>> getRecordsInPeriod(DateTime start, DateTime end) {
    final formatter = DateFormat('yyyy-MM-dd');
    return (select(dailySleepRecords)
          ..where((t) => t.date.isBetweenValues(formatter.format(start), formatter.format(end)))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]))
        .get();
  }

  Stream<List<DailySleepRecord>> watchRecordsInPeriod(DateTime start, DateTime end) {
    final formatter = DateFormat('yyyy-MM-dd');
    return (select(dailySleepRecords)
          ..where((t) => t.date.isBetweenValues(formatter.format(start), formatter.format(end)))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<DailySleepRecord?> getRecordByDate(String date) =>
      (select(dailySleepRecords)..where((t) => t.date.equals(date))).getSingleOrNull();

  Future<void> logMedicationIntake() async {
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final timeStr = DateFormat('HH:mm').format(now);

      final existing = await getRecordByDate(todayStr);
      List<dynamic> meds = [];
      
      if (existing != null && existing.medications != null) {
        meds = List.from(existing.medications!);
      }
      
      meds.add({'time': timeStr, 'timestamp': now.toIso8601String()});

      // companion 생성 시 모든 필드에 기본값을 주어 검증 에러를 방지합니다.
      await into(dailySleepRecords).insertOnConflictUpdate(DailySleepRecordsCompanion(
        date: Value(todayStr),
        medicationTaken: const Value(true),
        medications: Value(meds),
        updatedAt: Value(now),
        sleepQuality: const Value(3), // 명시적으로 기본값 할당
        awakeningsCount: const Value(0),
      ));
      print('Medication Log Success: $todayStr $timeStr');
    } catch (e) {
      print('Medication Log Error: $e');
      rethrow;
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
