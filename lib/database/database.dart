import 'dart:io';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

part 'database.g.dart';

// DB 내부 상태를 관리하기 위한 메타데이터 테이블
class AppMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('CustomDataType')
class CustomDataTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get iconName => text().nullable()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isPreset => boolean().withDefault(const Constant(false))();

  // 그리드 배치 정보 (Android 위젯 스타일)
  IntColumn get gridX => integer().withDefault(const Constant(0))();
  IntColumn get gridY => integer().withDefault(const Constant(0))();
  IntColumn get gridWidth => integer().withDefault(const Constant(1))();
  IntColumn get gridHeight => integer().withDefault(const Constant(1))();
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

@DriftDatabase(tables: [AppMetadata, CustomDataTypes, CustomDataRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11; 

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      print("🚀 [DB MIGRATION] Internal: $from -> External: $to");
      
      // 1. 메타데이터 테이블 우선 생성
      await m.createTable(appMetadata);

      if (from < 11) {
        // 2. 핵심 테이블들 생성 시도 (방어적)
        try { await m.createTable(customDataTypes); } catch(_) {}
        try { await m.createTable(customDataRecords); } catch(_) {}

        // 3. 누락된 컬럼들 강제 보강
        final columns = [
          customDataTypes.gridX, customDataTypes.gridY, 
          customDataTypes.gridWidth, customDataTypes.gridHeight
        ];
        for (var col in columns) {
          try { await m.addColumn(customDataTypes, col); } catch(_) {}
        }
        
        // 4. 프리셋 데이터 보장
        await _ensurePresets();
        
        // 5. DB 파일 내부에 명시적 버전 기록
        await _updateInternalVersion(to);
      }
      print("✅ [DB MIGRATION] Migration sequence completed.");
    },
    onCreate: (m) async {
      await m.createAll();
      await _ensurePresets();
      await _updateInternalVersion(schemaVersion);
      print("✅ [DB] Database created with Version $schemaVersion");
    },
    beforeOpen: (details) async {
      final internalVersion = await _getInternalVersion();
      print("📊 [DB STATUS] Physical Version (user_version): ${details.versionNow}");
      print("📊 [DB STATUS] App Logged Version (metadata): $internalVersion");
    },
  );

  // --- 헬퍼 메서드 ---

  Future<void> _ensurePresets() async {
    final List<Map<String, dynamic>> presets = [
      {
        'name': '수면',
        'icon': 'hotel',
        'color': 0xFF4CAF50,
        'x': 0, 'y': 0, 'w': 4, 'h': 2
      },
      {
        'name': '약 복용',
        'icon': 'medication',
        'color': 0xFF3F51B5,
        'x': 0, 'y': 2, 'w': 2, 'h': 2
      },
      {
        'name': '카페인',
        'icon': 'coffee',
        'color': 0xFFFF9800,
        'x': 2, 'y': 2, 'w': 1, 'h': 1
      },
      {
        'name': '음주',
        'icon': 'beer',
        'color': 0xFFE91E63,
        'x': 3, 'y': 2, 'w': 1, 'h': 1
      },
      {
        'name': '운동',
        'icon': 'sports',
        'color': 0xFF009688,
        'x': 2, 'y': 3, 'w': 1, 'h': 1
      },
      {
        'name': '흡연',
        'icon': 'smoke',
        'color': 0xFF9C27B0,
        'x': 3, 'y': 3, 'w': 1, 'h': 1
      },
    ];

    for (var p in presets) {
      final count = await customSelect(
        'SELECT COUNT(*) as c FROM custom_data_types WHERE name = ?',
        variables: [Variable(p['name'] as String)],
      ).getSingle();

      if (count.read<int>('c') == 0) {
        await into(customDataTypes).insert(CustomDataTypesCompanion.insert(
          name: p['name'] as String,
          iconName: Value(p['icon'] as String),
          colorValue: Value(p['color'] as int),
          isPreset: const Value(true),
          gridX: Value(p['x'] as int),
          gridY: Value(p['y'] as int),
          gridWidth: Value(p['w'] as int),
          gridHeight: Value(p['h'] as int),
        ));
      }
    }
  }

  /// 모든 데이터 타입의 위치 정보를 검사하고, 겹치거나 누락된 경우 상단부터 순차 재배치합니다.
  Future<void> fixDataIntegrity({int columns = 4}) async {
    await transaction(() async {
      final allTypes = await getCustomDataTypes();
      if (allTypes.isEmpty) {
        await _ensurePresets();
        return;
      }

      // 간단한 그리드 맵
      // 넉넉하게 100행까지 관리 (필요시 자동 확장)
      List<List<bool>> grid = List.generate(100, (_) => List.filled(columns, false));

      for (var type in allTypes) {
        bool needsRelocation = false;
        
        // 1. 유효성 검사: 좌표가 음수이거나 너비/높이가 1 미만인 경우, 혹은 열 범위를 벗어난 경우
        if (type.gridX < 0 || type.gridY < 0 || type.gridWidth < 1 || type.gridHeight < 1 || type.gridX + type.gridWidth > columns) {
          needsRelocation = true;
        } else {
          // 2. 겹침 검사
          for (int dy = 0; dy < type.gridHeight; dy++) {
            for (int dx = 0; dx < type.gridWidth; dx++) {
              int gy = type.gridY + dy;
              int gx = type.gridX + dx;
              if (gy < 100 && grid[gy][gx]) {
                needsRelocation = true;
                break;
              }
            }
            if (needsRelocation) break;
          }
        }

        if (needsRelocation) {
          // 비어 있는 공간 찾기
          var pos = _findEmptySpace(grid, type.gridWidth, type.gridHeight, columns);
          await (update(customDataTypes)..where((t) => t.id.equals(type.id))).write(
            CustomDataTypesCompanion(
              gridX: Value(pos.x),
              gridY: Value(pos.y),
            ),
          );
          // 그리드 업데이트
          _occupyGrid(grid, pos.x, pos.y, type.gridWidth, type.gridHeight, columns);
        } else {
          // 현재 위치 유지 및 그리드 점유 표시
          _occupyGrid(grid, type.gridX, type.gridY, type.gridWidth, type.gridHeight, columns);
        }
      }
    });
  }

  _Point _findEmptySpace(List<List<bool>> grid, int w, int h, int columns) {
    // 위젯 너비가 그리드 너비보다 크면 조정
    final actualW = w.clamp(1, columns);
    
    for (int y = 0; y < 100 - h; y++) {
      for (int x = 0; x <= columns - actualW; x++) {
        bool canFit = true;
        for (int dy = 0; dy < h; dy++) {
          for (int dx = 0; dx < actualW; dx++) {
            if (grid[y + dy][x + dx]) {
              canFit = false;
              break;
            }
          }
          if (!canFit) break;
        }
        if (canFit) return _Point(x, y);
      }
    }
    return _Point(0, 0); 
  }

  void _occupyGrid(List<List<bool>> grid, int x, int y, int w, int h, int columns) {
    final actualW = w.clamp(1, columns);
    for (int dy = 0; dy < h; dy++) {
      for (int dx = 0; dx < actualW; dx++) {
        if (y + dy < 100 && x + dx < columns) {
          grid[y + dy][x + dx] = true;
        }
      }
    }
  }

  Future<void> _updateInternalVersion(int version) async {
    await into(appMetadata).insertOnConflictUpdate(AppMetadataCompanion.insert(
      key: 'db_version',
      value: Value(version.toString()),
    ));
    await into(appMetadata).insertOnConflictUpdate(AppMetadataCompanion.insert(
      key: 'last_migration_date',
      value: Value(DateTime.now().toIso8601String()),
    ));
  }

  Future<String> _getInternalVersion() async {
    try {
      final row = await (select(appMetadata)..where((t) => t.key.equals('db_version'))).getSingleOrNull();
      return row?.value ?? "Unknown";
    } catch (e) {
      return "None (Table not found)";
    }
  }

  // === CustomDataType CRUD ===
  Stream<List<CustomDataType>> watchCustomDataTypes() => 
      (select(customDataTypes)..orderBy([(t) => OrderingTerm(expression: t.gridY), (t) => OrderingTerm(expression: t.gridX)])).watch();
  
  Future<List<CustomDataType>> getCustomDataTypes() => 
      (select(customDataTypes)..orderBy([(t) => OrderingTerm(expression: t.gridY), (t) => OrderingTerm(expression: t.gridX)])).get();

  Future<int> addCustomDataType({required String name, String? iconName, int? colorValue, bool isPreset = false, int x = 0, int y = 0, int w = 1, int h = 1}) {
    return into(customDataTypes).insert(CustomDataTypesCompanion.insert(
      name: name, iconName: Value(iconName), colorValue: Value(colorValue), isPreset: Value(isPreset),
      gridX: Value(x), gridY: Value(y), gridWidth: Value(w), gridHeight: Value(h),
    ));
  }

  Future<void> updateCustomDataTypeLayout(int id, int x, int y, int w, int h) {
    return (update(customDataTypes)..where((t) => t.id.equals(id))).write(
      CustomDataTypesCompanion(gridX: Value(x), gridY: Value(y), gridWidth: Value(w), gridHeight: Value(h)),
    );
  }

  Future<void> updateCustomDataTypeInfo(int id, String name, String? iconName, int? colorValue) {
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

  Future<void> updateCustomDataRecord(int id, {DateTime? timestamp, String? value}) {
    return (update(customDataRecords)..where((t) => t.id.equals(id))).write(
      CustomDataRecordsCompanion(
        unixTimestamp: timestamp != null ? Value(timestamp.millisecondsSinceEpoch ~/ 1000) : const Value.absent(),
        value: value != null ? Value(value) : const Value.absent(),
      ),
    );
  }

  Future<void> updateRecordsValueInPeriod({
    required int typeId,
    required DateTime start,
    required DateTime end,
    required String value,
  }) async {
    final startUnix = start.millisecondsSinceEpoch ~/ 1000;
    final endUnix = end.millisecondsSinceEpoch ~/ 1000;
    await (update(customDataRecords)
          ..where((t) => t.typeId.equals(typeId) & t.unixTimestamp.isBetweenValues(startUnix, endUnix)))
        .write(CustomDataRecordsCompanion(value: Value(value)));
  }

  Future<CustomDataRecord?> getLastRecord(int typeId) {
    return (select(customDataRecords)
          ..where((t) => t.typeId.equals(typeId))
          ..orderBy([(t) => OrderingTerm(expression: t.unixTimestamp, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
  }

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

class _Point {
  final int x;
  final int y;
  _Point(this.x, this.y);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    
    // DB 파일을 열기 전에 물리적 파일 백업 수행 (안전한 마이그레이션을 위함)
    if (await file.exists()) {
      final backupPath = p.join(dbFolder.path, 'db.sqlite.backup');
      try {
        await file.copy(backupPath);
        print("📦 [DB BACKUP] Existing database file backed up to: $backupPath");
      } catch (e) {
        print("⚠️ [DB BACKUP] Failed to create backup: $e");
      }
    }

    return NativeDatabase(file);
  });
}
