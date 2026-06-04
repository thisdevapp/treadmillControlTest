import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

part 'database.g.dart';

@DataClassName('CustomDataType')
class CustomDataTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get iconName => text().nullable()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isPreset => boolean().withDefault(const Constant(false))();
}

@DataClassName('CustomDataRecord')
class CustomDataRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get typeId => integer().references(CustomDataTypes, #id)();
  IntColumn get unixTimestamp => integer()();
  TextColumn get value => text().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();
  IntColumn get offsetSeconds => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [CustomDataTypes, CustomDataRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9; 

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      print("🚀 [MIGRATION] Upgrade started: $from -> $to");
      
      if (from < 9) {
        // Step 1: 새로운 테이블 생성 (이미 있으면 무시됨)
        await m.createTable(customDataTypes);
        await m.createTable(customDataRecords);

        // Step 2: 프리셋 타입 확보
        final types = await select(customDataTypes).get();
        int sleepId = types.where((t) => t.name == '수면').firstOrNull?.id ?? 
                      await into(customDataTypes).insert(CustomDataTypesCompanion.insert(name: '수면', iconName: const Value('hotel'), colorValue: const Value(0xFF4CAF50), isPreset: const Value(true)));
        int medId = types.where((t) => t.name == '약 복용').firstOrNull?.id ?? 
                    await into(customDataTypes).insert(CustomDataTypesCompanion.insert(name: '약 복용', iconName: const Value('medication'), colorValue: const Value(0xFF3F51B5), isPreset: const Value(true)));

        // Step 3: 물리적 테이블 목록 조회
        final tablesResult = await customSelect("SELECT name FROM sqlite_master WHERE type='table';").get();
        final physicalTables = tablesResult.map((t) => t.read<String>('name')).toList();
        print("📋 [MIGRATION] Current tables: $physicalTables");

        // Step 4: 데이터 복사 및 테이블 백업 (삭제 안함)
        // 4-1. 수면 세션 이전
        if (physicalTables.contains('sleep_sessions')) {
          try {
            final oldSessions = await customSelect('SELECT * FROM sleep_sessions;').get();
            for (final row in oldSessions) {
              await into(customDataRecords).insert(CustomDataRecordsCompanion.insert(
                typeId: sleepId,
                unixTimestamp: row.read<int>('start_unix'),
                value: Value(row.read<int?>('end_unix') != null ? jsonEncode({'endUnix': row.read<int?>('end_unix'), 'quality': 3, 'memo': '이전 기록'}) : null),
                timezone: Value(row.read<String>('timezone')),
                offsetSeconds: Value(row.read<int>('offset_seconds')),
              ));
            }
            print("✅ [MIGRATION] Migrated ${oldSessions.length} sessions. Renaming table to backup...");
            await customStatement('ALTER TABLE sleep_sessions RENAME TO backup_v5_sleep_sessions;');
          } catch (e) { print("❌ [MIGRATION] Sleep migration error: $e"); }
        }

        // 4-2. 복용 기록 이전
        if (physicalTables.contains('daily_sleep_records')) {
          try {
            final oldDaily = await customSelect('SELECT * FROM daily_sleep_records WHERE medications IS NOT NULL;').get();
            int count = 0;
            for (final row in oldDaily) {
              final List meds = jsonDecode(row.read<String>('medications'));
              for (final med in meds) {
                if (med['unix'] != null) {
                  await into(customDataRecords).insert(CustomDataRecordsCompanion.insert(
                    typeId: medId,
                    unixTimestamp: med['unix'],
                    value: Value(med['name'] ?? '이전 약물'),
                    timezone: const Value('UTC'),
                    offsetSeconds: Value(med['offset'] ?? 0),
                  ));
                  count++;
                }
              }
            }
            print("✅ [MIGRATION] Migrated $count meds. Renaming table to backup...");
            await customStatement('ALTER TABLE daily_sleep_records RENAME TO backup_v5_daily_sleep_records;');
          } catch (e) { print("❌ [MIGRATION] Med migration error: $e"); }
        }
      }
      print("🚀 [MIGRATION] Upgrade completed.");
    },
    onCreate: (m) async {
      await m.createAll();
      await into(customDataTypes).insert(CustomDataTypesCompanion.insert(name: '수면', iconName: const Value('hotel'), colorValue: const Value(0xFF4CAF50), isPreset: const Value(true)));
      await into(customDataTypes).insert(CustomDataTypesCompanion.insert(name: '약 복용', iconName: const Value('medication'), colorValue: const Value(0xFF3F51B5), isPreset: const Value(true)));
    },
  );

  // === CustomDataType CRUD ===
  Stream<List<CustomDataType>> watchCustomDataTypes() => select(customDataTypes).watch();
  Future<List<CustomDataType>> getCustomDataTypes() => select(customDataTypes).get();
  
  Future<int> addCustomDataType({required String name, String? iconName, int? colorValue, bool isPreset = false}) {
    return into(customDataTypes).insert(CustomDataTypesCompanion.insert(
      name: name, iconName: Value(iconName), colorValue: Value(colorValue), isPreset: Value(isPreset),
    ));
  }

  Future<void> updateCustomDataType(int id, String name, String? iconName, int? colorValue) {
    return (update(customDataTypes)..where((t) => t.id.equals(id))).write(
      CustomDataTypesCompanion(name: Value(name), iconName: Value(iconName), colorValue: Value(colorValue)),
    );
  }

  Future<void> deleteCustomDataType(int id) async {
    await transaction(() async {
      await (delete(customDataRecords)..where((t) => t.typeId.equals(id))).go();
      await (delete(customDataTypes)..where((t) => t.id.equals(id))).go();
    });
  }

  // === CustomDataRecord CRUD ===
  Stream<List<CustomDataRecord>> watchRecordsInPeriod(DateTime start, DateTime end) {
    final startUnix = start.millisecondsSinceEpoch ~/ 1000;
    final endUnix = end.millisecondsSinceEpoch ~/ 1000;
    return (select(customDataRecords)
          ..where((t) => t.unixTimestamp.isBetweenValues(startUnix, endUnix))
          ..orderBy([(t) => OrderingTerm(expression: t.unixTimestamp, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<int> addCustomDataRecord({required int typeId, required DateTime timestamp, String? value}) {
    return into(customDataRecords).insert(CustomDataRecordsCompanion.insert(
      typeId: typeId,
      unixTimestamp: timestamp.millisecondsSinceEpoch ~/ 1000,
      value: Value(value),
      timezone: Value(DateTime.now().timeZoneName),
      offsetSeconds: Value(DateTime.now().timeZoneOffset.inSeconds),
    ));
  }

  Future<void> deleteCustomDataRecord(int id) => (delete(customDataRecords)..where((t) => t.id.equals(id))).go();

  Future<List<String>> getRecentRecordValues(int typeId) async {
    final query = select(customDataRecords)
      ..where((t) => t.typeId.equals(typeId) & t.value.isNotNull())
      ..orderBy([(t) => OrderingTerm(expression: t.unixTimestamp, mode: OrderingMode.desc)])
      ..limit(50);
    final results = await query.get();
    final values = results.map((r) => r.value!.trim()).where((v) => v.isNotEmpty).toSet().toList();
    return values.length > 10 ? values.sublist(0, 10) : values;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
