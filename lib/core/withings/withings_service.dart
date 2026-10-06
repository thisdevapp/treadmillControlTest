import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../database/database.dart';
import '../../ui/widgets/record_manager.dart';
import 'withings_config.dart';

class WithingsException implements Exception {
  final String message;
  WithingsException(this.message);

  @override
  String toString() => message;
}

/// Withings 수면 가져오기 결과
class WithingsImportResult {
  final int added;
  final int updated;
  final int fetched;
  final String? backupPath; // 가져오기 직전 DB 백업 파일
  final String? rawPath; // Withings 원본 응답 보관 파일

  const WithingsImportResult({
    required this.added,
    required this.updated,
    required this.fetched,
    this.backupPath,
    this.rawPath,
  });

  String get message {
    if (fetched == 0) return "가져올 Withings 수면 데이터가 없습니다.";
    if (added == 0 && updated == 0) return "Withings 수면 기록이 이미 모두 반영되어 있습니다.";
    return "Withings 수면 기록 $added건 추가, $updated건 갱신";
  }
}

/// Withings OAuth 인증 + 수면 요약(취침·기상 시각, 총 수면시간) 가져오기
class WithingsService {
  static const _storage = FlutterSecureStorage();
  static const _kAccessToken = 'withings_access_token';
  static const _kRefreshToken = 'withings_refresh_token';
  static const _kExpiresAt = 'withings_expires_at'; // ms since epoch

  final AppDatabase database;

  WithingsService(this.database);

  /// 필요하면 로그인 후, [from]~[to] (날짜 단위, 양 끝 포함) 수면 기록을 가져와 저장.
  /// 로그인 창을 사용자가 닫으면 null 반환
  Future<WithingsImportResult?> connectAndImport({required DateTime from, required DateTime to}) async {
    if (!WithingsConfig.isConfigured) {
      throw WithingsException("Withings 설정값이 없습니다. --dart-define 으로 CLIENT_ID / CLIENT_SECRET / REDIRECT_URI 를 넣어 실행하세요.");
    }
    if (to.isBefore(from)) throw WithingsException("종료 날짜가 시작 날짜보다 앞설 수 없습니다.");

    String? token = await _validAccessToken();
    if (token == null) {
      final code = await _authorize();
      if (code == null) return null; // 사용자가 취소
      token = await _exchangeCode(code);
    }
    return _importSleep(token, from, to);
  }

  // ==========================================
  // 1. 인증 (브라우저 로그인 → 중계 페이지 → 커스텀 스킴 콜백)
  // ==========================================
  Future<String?> _authorize() async {
    final state = _randomState();
    final url = Uri.parse(WithingsConfig.authorizeUrl).replace(queryParameters: {
      'response_type': 'code',
      'client_id': WithingsConfig.clientId,
      'scope': WithingsConfig.scope,
      'redirect_uri': WithingsConfig.redirectUri,
      'state': state,
    });

    final String result;
    try {
      result = await FlutterWebAuth2.authenticate(url: url.toString(), callbackUrlScheme: WithingsConfig.callbackScheme);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') return null;
      rethrow;
    }

    final params = Uri.parse(result).queryParameters;
    if (params['error'] != null) {
      throw WithingsException("Withings 인증 실패: ${params['error']}");
    }
    if (params['state'] != state) {
      throw WithingsException("Withings 인증 응답의 state가 일치하지 않습니다.");
    }
    final code = params['code'];
    if (code == null || code.isEmpty) {
      throw WithingsException("Withings 인증 코드를 받지 못했습니다.");
    }
    return code;
  }

  String _randomState() {
    final rand = Random.secure();
    return List.generate(16, (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  // ==========================================
  // 2~3. 토큰 교환 / 갱신 (secure storage 저장)
  // ==========================================

  /// code는 유효시간이 매우 짧으므로 받자마자 교환
  Future<String> _exchangeCode(String code) async {
    final body = await _post('/v2/oauth2', {
      'action': 'requesttoken',
      'grant_type': 'authorization_code',
      'client_id': WithingsConfig.clientId,
      'client_secret': WithingsConfig.clientSecret,
      'code': code,
      'redirect_uri': WithingsConfig.redirectUri,
    });
    return _saveTokens(body);
  }

  /// 저장된 토큰이 유효하면 반환, 만료됐으면 refresh_token으로 갱신. 둘 다 불가하면 null (재로그인 필요)
  Future<String?> _validAccessToken() async {
    final String? access;
    final String? refresh;
    final String? expiresAt;
    try {
      access = await _storage.read(key: _kAccessToken);
      refresh = await _storage.read(key: _kRefreshToken);
      expiresAt = await _storage.read(key: _kExpiresAt);
    } catch (_) {
      // 기기 백업 복원 등으로 복호화 키가 바뀐 경우: 저장값을 버리고 재로그인
      await _clearTokens();
      return null;
    }

    final expiry = int.tryParse(expiresAt ?? '');
    // 만료 1분 전부터는 갱신
    if (access != null && expiry != null && DateTime.now().millisecondsSinceEpoch < expiry - 60000) {
      return access;
    }
    if (refresh == null) return null;

    try {
      final body = await _post('/v2/oauth2', {
        'action': 'requesttoken',
        'grant_type': 'refresh_token',
        'client_id': WithingsConfig.clientId,
        'client_secret': WithingsConfig.clientSecret,
        'refresh_token': refresh,
      });
      return await _saveTokens(body);
    } on WithingsException {
      // refresh_token 만료/폐기: 재로그인으로 처리
      await _clearTokens();
      return null;
    }
  }

  /// 토큰 응답 저장. 갱신 시 새 refresh_token으로 반드시 교체 (이전 것은 무효화됨)
  Future<String> _saveTokens(Map<String, dynamic> body) async {
    final access = body['access_token'] as String?;
    final refresh = body['refresh_token'] as String?;
    final expiresIn = (body['expires_in'] as num?)?.toInt() ?? 0;
    if (access == null || refresh == null) {
      throw WithingsException("Withings 토큰 응답이 올바르지 않습니다.");
    }
    final expiresAt = DateTime.now().millisecondsSinceEpoch + expiresIn * 1000;
    await _storage.write(key: _kAccessToken, value: access);
    await _storage.write(key: _kRefreshToken, value: refresh);
    await _storage.write(key: _kExpiresAt, value: expiresAt.toString());
    return access;
  }

  Future<void> _clearTokens() async {
    try {
      await _storage.delete(key: _kAccessToken);
      await _storage.delete(key: _kRefreshToken);
      await _storage.delete(key: _kExpiresAt);
    } catch (_) {}
  }

  // ==========================================
  // 4~5. 수면 요약 조회 → (DB 백업 + 원본 보관) → 기존 수면 기록으로 저장
  // ==========================================
  Future<WithingsImportResult> _importSleep(String token, DateTime from, DateTime to) async {
    final f = DateFormat('yyyy-MM-dd');
    final series = <Map<String, dynamic>>[];

    // DB를 건드리기 전에 먼저 전부 받아옴 (네트워크 실패 시 DB에는 아무 변화 없음)
    int? offset;
    do {
      final body = await _post('/v2/sleep', {
        'action': 'getsummary',
        'startdateymd': f.format(from),
        'enddateymd': f.format(to),
        'data_fields': 'total_sleep_time',
        'offset': ?offset?.toString(),
      }, bearer: token);
      series.addAll(((body['series'] as List?) ?? const []).whereType<Map<String, dynamic>>());
      offset = body['more'] == true ? (body['offset'] as num?)?.toInt() : null;
    } while (offset != null);

    if (series.isEmpty) return const WithingsImportResult(added: 0, updated: 0, fetched: 0);

    final types = await database.getCustomDataTypes();
    final sleepType = RecordManager.findSleepType(types);
    if (sleepType == null) throw WithingsException("앱에 '수면' 기록 유형이 없습니다.");

    final docs = await getApplicationDocumentsDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // ① 기존 DB 백업 (새 파일, 덮어쓰지 않음). 실패하면 아무것도 저장하지 않고 중단
    final File backup;
    try {
      backup = await database.backupToFile(p.join(docs.path, 'backups', 'db_before_withings_$stamp.sqlite'));
    } catch (e) {
      throw WithingsException("DB 백업에 실패해 가져오기를 중단했습니다. ($e)");
    }

    // ② Withings 원본 응답은 DB와 별도 파일로 보관
    final raw = File(p.join(docs.path, 'withings', 'sleep_${f.format(from)}_${f.format(to)}_$stamp.json'));
    await raw.parent.create(recursive: true);
    await raw.writeAsString(const JsonEncoder.withIndent('  ').convert({
      'fetchedAt': DateTime.now().toIso8601String(),
      'startdateymd': f.format(from),
      'enddateymd': f.format(to),
      'series': series,
    }));

    // ③ 변환 저장은 한 트랜잭션으로: 중간에 실패하면 전부 취소되어 DB가 반만 바뀌는 일이 없음
    final (added, updated) = await database.transaction(() => _writeSleepRecords(series, sleepType.id));
    return WithingsImportResult(
      added: added,
      updated: updated,
      fetched: series.length,
      backupPath: backup.path,
      rawPath: raw.path,
    );
  }

  Future<(int, int)> _writeSleepRecords(List<Map<String, dynamic>> series, int sleepTypeId) async {
    // 이전에 가져온 Withings 기록 (key → 기록)
    final existing = <String, CustomDataRecord>{};
    final rows = await (database.select(database.customDataRecords)
          ..where((t) => t.typeId.equals(sleepTypeId) & t.value.like('%"source":"withings"%')))
        .get();
    for (final r in rows) {
      try {
        final key = (jsonDecode(r.value!) as Map<String, dynamic>)['withingsKey'] as String?;
        if (key != null) existing[key] = r;
      } catch (_) {}
    }

    int added = 0, updated = 0;
    final seen = <String>{};
    for (final item in series) {
      final start = (item['startdate'] as num?)?.toInt();
      final end = (item['enddate'] as num?)?.toInt();
      if (start == null || end == null || end <= start) continue;
      final totalSleep = ((item['data'] as Map?)?['total_sleep_time'] as num?)?.toInt();

      // 같은 밤 중복 방지: Withings 항목 id 우선, 없으면 날짜 기준
      final key = item['id'] != null ? 'id:${item['id']}' : 'date:${item['date'] ?? start}';
      if (!seen.add(key)) continue; // 같은 응답 안에서 중복된 항목
      final prev = existing[key];

      String memo = '';
      if (prev != null) {
        try {
          memo = (jsonDecode(prev.value!) as Map<String, dynamic>)['memo'] as String? ?? '';
        } catch (_) {}
      }
      // 기존 수면 기록 형식(endUnix, memo) + Withings 식별/총 수면시간
      final value = jsonEncode({
        'endUnix': end,
        'memo': memo,
        'source': 'withings',
        'withingsKey': key,
        'totalSleepSec': ?totalSleep,
      });

      if (prev == null) {
        await database.addCustomDataRecord(
          typeId: sleepTypeId,
          timestamp: DateTime.fromMillisecondsSinceEpoch(start * 1000),
          value: value,
        );
        added++;
      } else if (prev.unixTimestamp != start || prev.value != value) {
        await database.updateCustomDataRecord(
          prev.id,
          timestamp: DateTime.fromMillisecondsSinceEpoch(start * 1000),
          value: value,
        );
        updated++;
      }
    }
    return (added, updated);
  }

  // ==========================================
  // HTTP (HTTP 200이어도 status == 0 일 때만 성공)
  // ==========================================
  Future<Map<String, dynamic>> _post(String path, Map<String, String?> fields, {String? bearer}) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(Uri.parse('${WithingsConfig.apiBase}$path'));
      req.headers.contentType = ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
      if (bearer != null) req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
      req.write(Uri(queryParameters: {
        for (final e in fields.entries)
          if (e.value != null) e.key: e.value!,
      }).query);

      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) {
        throw WithingsException("Withings 서버 오류 (HTTP ${res.statusCode})");
      }
      final json = jsonDecode(text) as Map<String, dynamic>;
      final status = (json['status'] as num?)?.toInt();
      if (status != 0) {
        throw WithingsException("Withings 요청 실패 (status $status${json['error'] != null ? ': ${json['error']}' : ''})");
      }
      return (json['body'] as Map<String, dynamic>?) ?? const {};
    } on SocketException {
      throw WithingsException("네트워크에 연결할 수 없습니다.");
    } finally {
      client.close();
    }
  }
}
