// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppMetadataTable extends AppMetadata
    with TableInfo<$AppMetadataTable, AppMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataData(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $AppMetadataTable createAlias(String alias) {
    return $AppMetadataTable(attachedDatabase, alias);
  }
}

class AppMetadataData extends DataClass implements Insertable<AppMetadataData> {
  final String key;
  final String? value;
  const AppMetadataData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  AppMetadataCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory AppMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  AppMetadataData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => AppMetadataData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  AppMetadataData copyWithCompanion(AppMetadataCompanion data) {
    return AppMetadataData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetadataCompanion extends UpdateCompanion<AppMetadataData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const AppMetadataCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppMetadataData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return AppMetadataCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomDataTypesTable extends CustomDataTypes
    with TableInfo<$CustomDataTypesTable, CustomDataType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomDataTypesTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gridXMeta = const VerificationMeta('gridX');
  @override
  late final GeneratedColumn<int> gridX = GeneratedColumn<int>(
    'grid_x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gridYMeta = const VerificationMeta('gridY');
  @override
  late final GeneratedColumn<int> gridY = GeneratedColumn<int>(
    'grid_y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gridWidthMeta = const VerificationMeta(
    'gridWidth',
  );
  @override
  late final GeneratedColumn<int> gridWidth = GeneratedColumn<int>(
    'grid_width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _gridHeightMeta = const VerificationMeta(
    'gridHeight',
  );
  @override
  late final GeneratedColumn<int> gridHeight = GeneratedColumn<int>(
    'grid_height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconName,
    colorValue,
    isPreset,
    gridX,
    gridY,
    gridWidth,
    gridHeight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_data_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomDataType> instance, {
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
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    }
    if (data.containsKey('grid_x')) {
      context.handle(
        _gridXMeta,
        gridX.isAcceptableOrUnknown(data['grid_x']!, _gridXMeta),
      );
    }
    if (data.containsKey('grid_y')) {
      context.handle(
        _gridYMeta,
        gridY.isAcceptableOrUnknown(data['grid_y']!, _gridYMeta),
      );
    }
    if (data.containsKey('grid_width')) {
      context.handle(
        _gridWidthMeta,
        gridWidth.isAcceptableOrUnknown(data['grid_width']!, _gridWidthMeta),
      );
    }
    if (data.containsKey('grid_height')) {
      context.handle(
        _gridHeightMeta,
        gridHeight.isAcceptableOrUnknown(data['grid_height']!, _gridHeightMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomDataType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomDataType(
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
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
      isPreset:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_preset'],
          )!,
      gridX:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}grid_x'],
          )!,
      gridY:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}grid_y'],
          )!,
      gridWidth:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}grid_width'],
          )!,
      gridHeight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}grid_height'],
          )!,
    );
  }

  @override
  $CustomDataTypesTable createAlias(String alias) {
    return $CustomDataTypesTable(attachedDatabase, alias);
  }
}

class CustomDataType extends DataClass implements Insertable<CustomDataType> {
  final int id;
  final String name;
  final String? iconName;
  final int? colorValue;
  final bool isPreset;
  final int gridX;
  final int gridY;
  final int gridWidth;
  final int gridHeight;
  const CustomDataType({
    required this.id,
    required this.name,
    this.iconName,
    this.colorValue,
    required this.isPreset,
    required this.gridX,
    required this.gridY,
    required this.gridWidth,
    required this.gridHeight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['is_preset'] = Variable<bool>(isPreset);
    map['grid_x'] = Variable<int>(gridX);
    map['grid_y'] = Variable<int>(gridY);
    map['grid_width'] = Variable<int>(gridWidth);
    map['grid_height'] = Variable<int>(gridHeight);
    return map;
  }

  CustomDataTypesCompanion toCompanion(bool nullToAbsent) {
    return CustomDataTypesCompanion(
      id: Value(id),
      name: Value(name),
      iconName:
          iconName == null && nullToAbsent
              ? const Value.absent()
              : Value(iconName),
      colorValue:
          colorValue == null && nullToAbsent
              ? const Value.absent()
              : Value(colorValue),
      isPreset: Value(isPreset),
      gridX: Value(gridX),
      gridY: Value(gridY),
      gridWidth: Value(gridWidth),
      gridHeight: Value(gridHeight),
    );
  }

  factory CustomDataType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomDataType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      gridX: serializer.fromJson<int>(json['gridX']),
      gridY: serializer.fromJson<int>(json['gridY']),
      gridWidth: serializer.fromJson<int>(json['gridWidth']),
      gridHeight: serializer.fromJson<int>(json['gridHeight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String?>(iconName),
      'colorValue': serializer.toJson<int?>(colorValue),
      'isPreset': serializer.toJson<bool>(isPreset),
      'gridX': serializer.toJson<int>(gridX),
      'gridY': serializer.toJson<int>(gridY),
      'gridWidth': serializer.toJson<int>(gridWidth),
      'gridHeight': serializer.toJson<int>(gridHeight),
    };
  }

  CustomDataType copyWith({
    int? id,
    String? name,
    Value<String?> iconName = const Value.absent(),
    Value<int?> colorValue = const Value.absent(),
    bool? isPreset,
    int? gridX,
    int? gridY,
    int? gridWidth,
    int? gridHeight,
  }) => CustomDataType(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName.present ? iconName.value : this.iconName,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
    isPreset: isPreset ?? this.isPreset,
    gridX: gridX ?? this.gridX,
    gridY: gridY ?? this.gridY,
    gridWidth: gridWidth ?? this.gridWidth,
    gridHeight: gridHeight ?? this.gridHeight,
  );
  CustomDataType copyWithCompanion(CustomDataTypesCompanion data) {
    return CustomDataType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      gridX: data.gridX.present ? data.gridX.value : this.gridX,
      gridY: data.gridY.present ? data.gridY.value : this.gridY,
      gridWidth: data.gridWidth.present ? data.gridWidth.value : this.gridWidth,
      gridHeight:
          data.gridHeight.present ? data.gridHeight.value : this.gridHeight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomDataType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('isPreset: $isPreset, ')
          ..write('gridX: $gridX, ')
          ..write('gridY: $gridY, ')
          ..write('gridWidth: $gridWidth, ')
          ..write('gridHeight: $gridHeight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconName,
    colorValue,
    isPreset,
    gridX,
    gridY,
    gridWidth,
    gridHeight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomDataType &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.colorValue == this.colorValue &&
          other.isPreset == this.isPreset &&
          other.gridX == this.gridX &&
          other.gridY == this.gridY &&
          other.gridWidth == this.gridWidth &&
          other.gridHeight == this.gridHeight);
}

class CustomDataTypesCompanion extends UpdateCompanion<CustomDataType> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> iconName;
  final Value<int?> colorValue;
  final Value<bool> isPreset;
  final Value<int> gridX;
  final Value<int> gridY;
  final Value<int> gridWidth;
  final Value<int> gridHeight;
  const CustomDataTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.gridX = const Value.absent(),
    this.gridY = const Value.absent(),
    this.gridWidth = const Value.absent(),
    this.gridHeight = const Value.absent(),
  });
  CustomDataTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.iconName = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.gridX = const Value.absent(),
    this.gridY = const Value.absent(),
    this.gridWidth = const Value.absent(),
    this.gridHeight = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CustomDataType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? colorValue,
    Expression<bool>? isPreset,
    Expression<int>? gridX,
    Expression<int>? gridY,
    Expression<int>? gridWidth,
    Expression<int>? gridHeight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (colorValue != null) 'color_value': colorValue,
      if (isPreset != null) 'is_preset': isPreset,
      if (gridX != null) 'grid_x': gridX,
      if (gridY != null) 'grid_y': gridY,
      if (gridWidth != null) 'grid_width': gridWidth,
      if (gridHeight != null) 'grid_height': gridHeight,
    });
  }

  CustomDataTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? iconName,
    Value<int?>? colorValue,
    Value<bool>? isPreset,
    Value<int>? gridX,
    Value<int>? gridY,
    Value<int>? gridWidth,
    Value<int>? gridHeight,
  }) {
    return CustomDataTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isPreset: isPreset ?? this.isPreset,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
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
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (gridX.present) {
      map['grid_x'] = Variable<int>(gridX.value);
    }
    if (gridY.present) {
      map['grid_y'] = Variable<int>(gridY.value);
    }
    if (gridWidth.present) {
      map['grid_width'] = Variable<int>(gridWidth.value);
    }
    if (gridHeight.present) {
      map['grid_height'] = Variable<int>(gridHeight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomDataTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('isPreset: $isPreset, ')
          ..write('gridX: $gridX, ')
          ..write('gridY: $gridY, ')
          ..write('gridWidth: $gridWidth, ')
          ..write('gridHeight: $gridHeight')
          ..write(')'))
        .toString();
  }
}

class $CustomDataRecordsTable extends CustomDataRecords
    with TableInfo<$CustomDataRecordsTable, CustomDataRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomDataRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
    'type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_data_types (id)',
    ),
  );
  static const VerificationMeta _unixTimestampMeta = const VerificationMeta(
    'unixTimestamp',
  );
  @override
  late final GeneratedColumn<int> unixTimestamp = GeneratedColumn<int>(
    'unix_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    typeId,
    unixTimestamp,
    value,
    timezone,
    offsetSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_data_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomDataRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    if (data.containsKey('unix_timestamp')) {
      context.handle(
        _unixTimestampMeta,
        unixTimestamp.isAcceptableOrUnknown(
          data['unix_timestamp']!,
          _unixTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unixTimestampMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomDataRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomDataRecord(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      typeId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}type_id'],
          )!,
      unixTimestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}unix_timestamp'],
          )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
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
    );
  }

  @override
  $CustomDataRecordsTable createAlias(String alias) {
    return $CustomDataRecordsTable(attachedDatabase, alias);
  }
}

class CustomDataRecord extends DataClass
    implements Insertable<CustomDataRecord> {
  final int id;
  final int typeId;
  final int unixTimestamp;
  final String? value;
  final String timezone;
  final int offsetSeconds;
  const CustomDataRecord({
    required this.id,
    required this.typeId,
    required this.unixTimestamp,
    this.value,
    required this.timezone,
    required this.offsetSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type_id'] = Variable<int>(typeId);
    map['unix_timestamp'] = Variable<int>(unixTimestamp);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['timezone'] = Variable<String>(timezone);
    map['offset_seconds'] = Variable<int>(offsetSeconds);
    return map;
  }

  CustomDataRecordsCompanion toCompanion(bool nullToAbsent) {
    return CustomDataRecordsCompanion(
      id: Value(id),
      typeId: Value(typeId),
      unixTimestamp: Value(unixTimestamp),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      timezone: Value(timezone),
      offsetSeconds: Value(offsetSeconds),
    );
  }

  factory CustomDataRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomDataRecord(
      id: serializer.fromJson<int>(json['id']),
      typeId: serializer.fromJson<int>(json['typeId']),
      unixTimestamp: serializer.fromJson<int>(json['unixTimestamp']),
      value: serializer.fromJson<String?>(json['value']),
      timezone: serializer.fromJson<String>(json['timezone']),
      offsetSeconds: serializer.fromJson<int>(json['offsetSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'typeId': serializer.toJson<int>(typeId),
      'unixTimestamp': serializer.toJson<int>(unixTimestamp),
      'value': serializer.toJson<String?>(value),
      'timezone': serializer.toJson<String>(timezone),
      'offsetSeconds': serializer.toJson<int>(offsetSeconds),
    };
  }

  CustomDataRecord copyWith({
    int? id,
    int? typeId,
    int? unixTimestamp,
    Value<String?> value = const Value.absent(),
    String? timezone,
    int? offsetSeconds,
  }) => CustomDataRecord(
    id: id ?? this.id,
    typeId: typeId ?? this.typeId,
    unixTimestamp: unixTimestamp ?? this.unixTimestamp,
    value: value.present ? value.value : this.value,
    timezone: timezone ?? this.timezone,
    offsetSeconds: offsetSeconds ?? this.offsetSeconds,
  );
  CustomDataRecord copyWithCompanion(CustomDataRecordsCompanion data) {
    return CustomDataRecord(
      id: data.id.present ? data.id.value : this.id,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      unixTimestamp:
          data.unixTimestamp.present
              ? data.unixTimestamp.value
              : this.unixTimestamp,
      value: data.value.present ? data.value.value : this.value,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      offsetSeconds:
          data.offsetSeconds.present
              ? data.offsetSeconds.value
              : this.offsetSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomDataRecord(')
          ..write('id: $id, ')
          ..write('typeId: $typeId, ')
          ..write('unixTimestamp: $unixTimestamp, ')
          ..write('value: $value, ')
          ..write('timezone: $timezone, ')
          ..write('offsetSeconds: $offsetSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, typeId, unixTimestamp, value, timezone, offsetSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomDataRecord &&
          other.id == this.id &&
          other.typeId == this.typeId &&
          other.unixTimestamp == this.unixTimestamp &&
          other.value == this.value &&
          other.timezone == this.timezone &&
          other.offsetSeconds == this.offsetSeconds);
}

class CustomDataRecordsCompanion extends UpdateCompanion<CustomDataRecord> {
  final Value<int> id;
  final Value<int> typeId;
  final Value<int> unixTimestamp;
  final Value<String?> value;
  final Value<String> timezone;
  final Value<int> offsetSeconds;
  const CustomDataRecordsCompanion({
    this.id = const Value.absent(),
    this.typeId = const Value.absent(),
    this.unixTimestamp = const Value.absent(),
    this.value = const Value.absent(),
    this.timezone = const Value.absent(),
    this.offsetSeconds = const Value.absent(),
  });
  CustomDataRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int typeId,
    required int unixTimestamp,
    this.value = const Value.absent(),
    this.timezone = const Value.absent(),
    this.offsetSeconds = const Value.absent(),
  }) : typeId = Value(typeId),
       unixTimestamp = Value(unixTimestamp);
  static Insertable<CustomDataRecord> custom({
    Expression<int>? id,
    Expression<int>? typeId,
    Expression<int>? unixTimestamp,
    Expression<String>? value,
    Expression<String>? timezone,
    Expression<int>? offsetSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (typeId != null) 'type_id': typeId,
      if (unixTimestamp != null) 'unix_timestamp': unixTimestamp,
      if (value != null) 'value': value,
      if (timezone != null) 'timezone': timezone,
      if (offsetSeconds != null) 'offset_seconds': offsetSeconds,
    });
  }

  CustomDataRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? typeId,
    Value<int>? unixTimestamp,
    Value<String?>? value,
    Value<String>? timezone,
    Value<int>? offsetSeconds,
  }) {
    return CustomDataRecordsCompanion(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      unixTimestamp: unixTimestamp ?? this.unixTimestamp,
      value: value ?? this.value,
      timezone: timezone ?? this.timezone,
      offsetSeconds: offsetSeconds ?? this.offsetSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<int>(typeId.value);
    }
    if (unixTimestamp.present) {
      map['unix_timestamp'] = Variable<int>(unixTimestamp.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (offsetSeconds.present) {
      map['offset_seconds'] = Variable<int>(offsetSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomDataRecordsCompanion(')
          ..write('id: $id, ')
          ..write('typeId: $typeId, ')
          ..write('unixTimestamp: $unixTimestamp, ')
          ..write('value: $value, ')
          ..write('timezone: $timezone, ')
          ..write('offsetSeconds: $offsetSeconds')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppMetadataTable appMetadata = $AppMetadataTable(this);
  late final $CustomDataTypesTable customDataTypes = $CustomDataTypesTable(
    this,
  );
  late final $CustomDataRecordsTable customDataRecords =
      $CustomDataRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appMetadata,
    customDataTypes,
    customDataRecords,
  ];
}

typedef $$AppMetadataTableCreateCompanionBuilder =
    AppMetadataCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$AppMetadataTableUpdateCompanionBuilder =
    AppMetadataCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$AppMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetadataTable> {
  $$AppMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetadataTable> {
  $$AppMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetadataTable> {
  $$AppMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetadataTable,
          AppMetadataData,
          $$AppMetadataTableFilterComposer,
          $$AppMetadataTableOrderingComposer,
          $$AppMetadataTableAnnotationComposer,
          $$AppMetadataTableCreateCompanionBuilder,
          $$AppMetadataTableUpdateCompanionBuilder,
          (
            AppMetadataData,
            BaseReferences<_$AppDatabase, $AppMetadataTable, AppMetadataData>,
          ),
          AppMetadataData,
          PrefetchHooks Function()
        > {
  $$AppMetadataTableTableManager(_$AppDatabase db, $AppMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AppMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AppMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$AppMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataCompanion.insert(
                key: key,
                value: value,
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

typedef $$AppMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetadataTable,
      AppMetadataData,
      $$AppMetadataTableFilterComposer,
      $$AppMetadataTableOrderingComposer,
      $$AppMetadataTableAnnotationComposer,
      $$AppMetadataTableCreateCompanionBuilder,
      $$AppMetadataTableUpdateCompanionBuilder,
      (
        AppMetadataData,
        BaseReferences<_$AppDatabase, $AppMetadataTable, AppMetadataData>,
      ),
      AppMetadataData,
      PrefetchHooks Function()
    >;
typedef $$CustomDataTypesTableCreateCompanionBuilder =
    CustomDataTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> iconName,
      Value<int?> colorValue,
      Value<bool> isPreset,
      Value<int> gridX,
      Value<int> gridY,
      Value<int> gridWidth,
      Value<int> gridHeight,
    });
typedef $$CustomDataTypesTableUpdateCompanionBuilder =
    CustomDataTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> iconName,
      Value<int?> colorValue,
      Value<bool> isPreset,
      Value<int> gridX,
      Value<int> gridY,
      Value<int> gridWidth,
      Value<int> gridHeight,
    });

final class $$CustomDataTypesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CustomDataTypesTable, CustomDataType> {
  $$CustomDataTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CustomDataRecordsTable, List<CustomDataRecord>>
  _customDataRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customDataRecords,
        aliasName: $_aliasNameGenerator(
          db.customDataTypes.id,
          db.customDataRecords.typeId,
        ),
      );

  $$CustomDataRecordsTableProcessedTableManager get customDataRecordsRefs {
    final manager = $$CustomDataRecordsTableTableManager(
      $_db,
      $_db.customDataRecords,
    ).filter((f) => f.typeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customDataRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomDataTypesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomDataTypesTable> {
  $$CustomDataTypesTableFilterComposer({
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

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gridX => $composableBuilder(
    column: $table.gridX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gridY => $composableBuilder(
    column: $table.gridY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gridWidth => $composableBuilder(
    column: $table.gridWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gridHeight => $composableBuilder(
    column: $table.gridHeight,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customDataRecordsRefs(
    Expression<bool> Function($$CustomDataRecordsTableFilterComposer f) f,
  ) {
    final $$CustomDataRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customDataRecords,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomDataRecordsTableFilterComposer(
            $db: $db,
            $table: $db.customDataRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomDataTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomDataTypesTable> {
  $$CustomDataTypesTableOrderingComposer({
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

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gridX => $composableBuilder(
    column: $table.gridX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gridY => $composableBuilder(
    column: $table.gridY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gridWidth => $composableBuilder(
    column: $table.gridWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gridHeight => $composableBuilder(
    column: $table.gridHeight,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomDataTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomDataTypesTable> {
  $$CustomDataTypesTableAnnotationComposer({
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

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumn<int> get gridX =>
      $composableBuilder(column: $table.gridX, builder: (column) => column);

  GeneratedColumn<int> get gridY =>
      $composableBuilder(column: $table.gridY, builder: (column) => column);

  GeneratedColumn<int> get gridWidth =>
      $composableBuilder(column: $table.gridWidth, builder: (column) => column);

  GeneratedColumn<int> get gridHeight => $composableBuilder(
    column: $table.gridHeight,
    builder: (column) => column,
  );

  Expression<T> customDataRecordsRefs<T extends Object>(
    Expression<T> Function($$CustomDataRecordsTableAnnotationComposer a) f,
  ) {
    final $$CustomDataRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customDataRecords,
          getReferencedColumn: (t) => t.typeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomDataRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.customDataRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CustomDataTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomDataTypesTable,
          CustomDataType,
          $$CustomDataTypesTableFilterComposer,
          $$CustomDataTypesTableOrderingComposer,
          $$CustomDataTypesTableAnnotationComposer,
          $$CustomDataTypesTableCreateCompanionBuilder,
          $$CustomDataTypesTableUpdateCompanionBuilder,
          (CustomDataType, $$CustomDataTypesTableReferences),
          CustomDataType,
          PrefetchHooks Function({bool customDataRecordsRefs})
        > {
  $$CustomDataTypesTableTableManager(
    _$AppDatabase db,
    $CustomDataTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$CustomDataTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CustomDataTypesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CustomDataTypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<int> gridX = const Value.absent(),
                Value<int> gridY = const Value.absent(),
                Value<int> gridWidth = const Value.absent(),
                Value<int> gridHeight = const Value.absent(),
              }) => CustomDataTypesCompanion(
                id: id,
                name: name,
                iconName: iconName,
                colorValue: colorValue,
                isPreset: isPreset,
                gridX: gridX,
                gridY: gridY,
                gridWidth: gridWidth,
                gridHeight: gridHeight,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> iconName = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<int> gridX = const Value.absent(),
                Value<int> gridY = const Value.absent(),
                Value<int> gridWidth = const Value.absent(),
                Value<int> gridHeight = const Value.absent(),
              }) => CustomDataTypesCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                colorValue: colorValue,
                isPreset: isPreset,
                gridX: gridX,
                gridY: gridY,
                gridWidth: gridWidth,
                gridHeight: gridHeight,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CustomDataTypesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({customDataRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customDataRecordsRefs) db.customDataRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customDataRecordsRefs)
                    await $_getPrefetchedData<
                      CustomDataType,
                      $CustomDataTypesTable,
                      CustomDataRecord
                    >(
                      currentTable: table,
                      referencedTable: $$CustomDataTypesTableReferences
                          ._customDataRecordsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CustomDataTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).customDataRecordsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.typeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomDataTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomDataTypesTable,
      CustomDataType,
      $$CustomDataTypesTableFilterComposer,
      $$CustomDataTypesTableOrderingComposer,
      $$CustomDataTypesTableAnnotationComposer,
      $$CustomDataTypesTableCreateCompanionBuilder,
      $$CustomDataTypesTableUpdateCompanionBuilder,
      (CustomDataType, $$CustomDataTypesTableReferences),
      CustomDataType,
      PrefetchHooks Function({bool customDataRecordsRefs})
    >;
typedef $$CustomDataRecordsTableCreateCompanionBuilder =
    CustomDataRecordsCompanion Function({
      Value<int> id,
      required int typeId,
      required int unixTimestamp,
      Value<String?> value,
      Value<String> timezone,
      Value<int> offsetSeconds,
    });
typedef $$CustomDataRecordsTableUpdateCompanionBuilder =
    CustomDataRecordsCompanion Function({
      Value<int> id,
      Value<int> typeId,
      Value<int> unixTimestamp,
      Value<String?> value,
      Value<String> timezone,
      Value<int> offsetSeconds,
    });

final class $$CustomDataRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomDataRecordsTable,
          CustomDataRecord
        > {
  $$CustomDataRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomDataTypesTable _typeIdTable(_$AppDatabase db) =>
      db.customDataTypes.createAlias(
        $_aliasNameGenerator(
          db.customDataRecords.typeId,
          db.customDataTypes.id,
        ),
      );

  $$CustomDataTypesTableProcessedTableManager get typeId {
    final $_column = $_itemColumn<int>('type_id')!;

    final manager = $$CustomDataTypesTableTableManager(
      $_db,
      $_db.customDataTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomDataRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomDataRecordsTable> {
  $$CustomDataRecordsTableFilterComposer({
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

  ColumnFilters<int> get unixTimestamp => $composableBuilder(
    column: $table.unixTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
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

  $$CustomDataTypesTableFilterComposer get typeId {
    final $$CustomDataTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.customDataTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomDataTypesTableFilterComposer(
            $db: $db,
            $table: $db.customDataTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomDataRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomDataRecordsTable> {
  $$CustomDataRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get unixTimestamp => $composableBuilder(
    column: $table.unixTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
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

  $$CustomDataTypesTableOrderingComposer get typeId {
    final $$CustomDataTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.customDataTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomDataTypesTableOrderingComposer(
            $db: $db,
            $table: $db.customDataTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomDataRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomDataRecordsTable> {
  $$CustomDataRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get unixTimestamp => $composableBuilder(
    column: $table.unixTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get offsetSeconds => $composableBuilder(
    column: $table.offsetSeconds,
    builder: (column) => column,
  );

  $$CustomDataTypesTableAnnotationComposer get typeId {
    final $$CustomDataTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.customDataTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomDataTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.customDataTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomDataRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomDataRecordsTable,
          CustomDataRecord,
          $$CustomDataRecordsTableFilterComposer,
          $$CustomDataRecordsTableOrderingComposer,
          $$CustomDataRecordsTableAnnotationComposer,
          $$CustomDataRecordsTableCreateCompanionBuilder,
          $$CustomDataRecordsTableUpdateCompanionBuilder,
          (CustomDataRecord, $$CustomDataRecordsTableReferences),
          CustomDataRecord,
          PrefetchHooks Function({bool typeId})
        > {
  $$CustomDataRecordsTableTableManager(
    _$AppDatabase db,
    $CustomDataRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CustomDataRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$CustomDataRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$CustomDataRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> typeId = const Value.absent(),
                Value<int> unixTimestamp = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> offsetSeconds = const Value.absent(),
              }) => CustomDataRecordsCompanion(
                id: id,
                typeId: typeId,
                unixTimestamp: unixTimestamp,
                value: value,
                timezone: timezone,
                offsetSeconds: offsetSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int typeId,
                required int unixTimestamp,
                Value<String?> value = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> offsetSeconds = const Value.absent(),
              }) => CustomDataRecordsCompanion.insert(
                id: id,
                typeId: typeId,
                unixTimestamp: unixTimestamp,
                value: value,
                timezone: timezone,
                offsetSeconds: offsetSeconds,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CustomDataRecordsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({typeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                if (typeId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.typeId,
                            referencedTable: $$CustomDataRecordsTableReferences
                                ._typeIdTable(db),
                            referencedColumn:
                                $$CustomDataRecordsTableReferences
                                    ._typeIdTable(db)
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

typedef $$CustomDataRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomDataRecordsTable,
      CustomDataRecord,
      $$CustomDataRecordsTableFilterComposer,
      $$CustomDataRecordsTableOrderingComposer,
      $$CustomDataRecordsTableAnnotationComposer,
      $$CustomDataRecordsTableCreateCompanionBuilder,
      $$CustomDataRecordsTableUpdateCompanionBuilder,
      (CustomDataRecord, $$CustomDataRecordsTableReferences),
      CustomDataRecord,
      PrefetchHooks Function({bool typeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppMetadataTableTableManager get appMetadata =>
      $$AppMetadataTableTableManager(_db, _db.appMetadata);
  $$CustomDataTypesTableTableManager get customDataTypes =>
      $$CustomDataTypesTableTableManager(_db, _db.customDataTypes);
  $$CustomDataRecordsTableTableManager get customDataRecords =>
      $$CustomDataRecordsTableTableManager(_db, _db.customDataRecords);
}
