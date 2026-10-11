import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 메모에 붙는 위치 정보 (아직 저장 기능은 없고 형식만 정의. 위치 기능을 추가할 때 이 형식으로 meta.json에 기록)
@immutable
class MemoLocation {
  final double latitude;
  final double longitude;

  /// 수평 정확도 (m)
  final double? accuracy;

  /// 고도 (m)
  final double? altitude;

  /// 위치를 측정한 시각
  final DateTime? capturedAt;

  /// 사용자가 붙인 장소 이름 또는 역지오코딩 주소
  final String? label;

  const MemoLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.capturedAt,
    this.label,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracy != null) 'accuracy': accuracy,
        if (altitude != null) 'altitude': altitude,
        if (capturedAt != null) 'capturedAt': capturedAt!.toUtc().toIso8601String(),
        if (label != null) 'label': label,
      };

  static MemoLocation? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = json['latitude'], lng = json['longitude'];
    if (lat is! num || lng is! num) return null;
    return MemoLocation(
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      capturedAt: DateTime.tryParse(json['capturedAt'] as String? ?? '')?.toLocal(),
      label: json['label'] as String?,
    );
  }

  /// 화면 표시용 좌표 문자열
  String get coordinateText => '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

/// 기록 하나에 붙은 메모
/// 저장 위치: <앱 문서 폴더>/memos/<기록 id>/
///   memo.md      본문 (마크다운)
///   meta.json    {version, createdAt, updatedAt, images: [파일 이름...], location: MemoLocation?}
///   images/      첨부 사진 (갤러리에서 복사해 온 사본)
@immutable
class RecordMemo {
  final int recordId;
  final String markdown;
  final List<String> images; // images/ 폴더 안의 파일 이름 (표시 순서)
  final MemoLocation? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecordMemo({
    required this.recordId,
    required this.markdown,
    this.images = const [],
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => markdown.trim().isEmpty && images.isEmpty && location == null;
}

/// 메모 파일 읽기/쓰기와 "메모가 있는 기록 id" 목록 관리
class MemoStore {
  MemoStore._();
  static final MemoStore instance = MemoStore._();

  static const int formatVersion = 1;
  static const String _markdownFile = 'memo.md';
  static const String _metaFile = 'meta.json';
  static const String _imagesDir = 'images';

  late final Directory _root;
  bool _ready = false;

  /// 메모가 있는 기록 id (차트의 메모 아이콘 표시용)
  final ValueNotifier<Set<int>> ids = ValueNotifier(const {});

  bool has(int recordId) => ids.value.contains(recordId);

  /// 앱 시작 시 한 번 호출. 메모 폴더를 훑어 메모가 있는 기록 id 목록을 만듦
  Future<void> init() async {
    if (_ready) return;
    final docs = await getApplicationDocumentsDirectory();
    _root = Directory(p.join(docs.path, 'memos'));
    await _root.create(recursive: true);
    _ready = true;

    final found = <int>{};
    await for (final entity in _root.list()) {
      final id = int.tryParse(p.basename(entity.path));
      if (entity is Directory && id != null) found.add(id);
    }
    ids.value = found;
  }

  Directory _dirOf(int recordId) => Directory(p.join(_root.path, '$recordId'));

  /// 첨부 사진 파일
  File imageFile(int recordId, String name) => File(p.join(_dirOf(recordId).path, _imagesDir, name));

  Future<RecordMemo?> load(int recordId) async {
    final dir = _dirOf(recordId);
    if (!await dir.exists()) return null;
    try {
      final mdFile = File(p.join(dir.path, _markdownFile));
      final metaFile = File(p.join(dir.path, _metaFile));
      final String markdown = await mdFile.exists() ? await mdFile.readAsString() : '';
      Map<String, dynamic> meta = {};
      if (await metaFile.exists()) {
        final decoded = json.decode(await metaFile.readAsString());
        if (decoded is Map<String, dynamic>) meta = decoded;
      }
      final stat = await dir.stat();
      return RecordMemo(
        recordId: recordId,
        markdown: markdown,
        images: [
          for (final name in (meta['images'] as List? ?? const []))
            if (name is String && imageFile(recordId, name).existsSync()) name,
        ],
        location: MemoLocation.fromJson(meta['location']),
        createdAt: DateTime.tryParse(meta['createdAt'] as String? ?? '')?.toLocal() ?? stat.changed,
        updatedAt: DateTime.tryParse(meta['updatedAt'] as String? ?? '')?.toLocal() ?? stat.modified,
      );
    } catch (e) {
      debugPrint("⚠️ [MEMO] $recordId 메모 읽기 실패: $e");
      return null;
    }
  }

  /// 메모 저장
  /// [keepImages]: 기존 첨부 중 남길 파일 이름, [newImages]: 새로 첨부할 사진 경로 (앱 폴더로 복사)
  /// 내용이 모두 비면 메모를 삭제
  Future<void> save({
    required int recordId,
    required String markdown,
    List<String> keepImages = const [],
    List<String> newImages = const [],
    MemoLocation? location,
  }) async {
    if (markdown.trim().isEmpty && keepImages.isEmpty && newImages.isEmpty && location == null) {
      await delete(recordId);
      return;
    }

    final dir = _dirOf(recordId);
    final imagesDir = Directory(p.join(dir.path, _imagesDir));
    await imagesDir.create(recursive: true);
    final previous = await load(recordId);

    // 새 사진은 앱 폴더로 복사 (원본이 갤러리에서 지워져도 메모에는 남도록)
    final images = [...keepImages];
    final int stamp = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < newImages.length; i++) {
      final ext = p.extension(newImages[i]).toLowerCase();
      final name = '${stamp}_$i${ext.isEmpty ? '.jpg' : ext}';
      await File(newImages[i]).copy(p.join(imagesDir.path, name));
      images.add(name);
    }

    // 목록에서 빠진 사진 파일 정리
    await for (final entity in imagesDir.list()) {
      if (entity is File && !images.contains(p.basename(entity.path))) await entity.delete();
    }

    final now = DateTime.now();
    await File(p.join(dir.path, _markdownFile)).writeAsString(markdown);
    await File(p.join(dir.path, _metaFile)).writeAsString(const JsonEncoder.withIndent('  ').convert({
      'version': formatVersion,
      'createdAt': (previous?.createdAt ?? now).toUtc().toIso8601String(),
      'updatedAt': now.toUtc().toIso8601String(),
      'images': images,
      'location': location?.toJson(),
    }));

    ids.value = {...ids.value, recordId};
  }

  Future<void> delete(int recordId) async {
    final dir = _dirOf(recordId);
    if (await dir.exists()) await dir.delete(recursive: true);
    if (has(recordId)) ids.value = {...ids.value}..remove(recordId);
  }

  /// DB에 더 이상 없는 기록의 메모 정리 (기록 종류 삭제, 전체 초기화 등)
  Future<void> prune(Set<int> existingRecordIds) async {
    for (final id in ids.value.difference(existingRecordIds)) {
      await delete(id);
    }
  }
}
