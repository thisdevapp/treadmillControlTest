import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// JSON 변환을 위한 컨버터
class JsonListConverter extends TypeConverter<List<dynamic>, String> {
  const JsonListConverter();
  @override
  List<dynamic> fromSql(String fromDb) {
    return json.decode(fromDb) as List<dynamic>;
  }

  @override
  String toSql(List<dynamic> value) {
    return json.encode(value);
  }
}

class DailySleepRecords extends Table {
  TextColumn get date => text().withLength(min: 10, max: 10)(); // YYYY-MM-DD
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
  IntColumn get sleepQuality => integer().check(sleepQuality.between(const Constant(1), const Constant(5)))();
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
  int get schemaVersion => 1;

  // CRUD operations
  Future<List<DailySleepRecord>> getAllRecords() => select(dailySleepRecords).get();
  Future<DailySleepRecord?> getRecordByDate(String date) =>
      (select(dailySleepRecords)..where((t) => t.date.equals(date))).getSingleOrNull();
  Future<int> upsertRecord(DailySleepRecordsCompanion record) =>
      into(dailySleepRecords).insertOnConflictUpdate(record);
  Future<int> deleteRecord(String date) =>
      (delete(dailySleepRecords)..where((t) => t.date.equals(date))).go();

  // Medication Preset operations
  Future<List<MedicationPreset>> getAllPresets() => select(medicationPresets).get();
  Future<int> addPreset(MedicationPresetsCompanion preset) => into(medicationPresets).insert(preset);
  Future<int> deletePreset(int id) => (delete(medicationPresets)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
