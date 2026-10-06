import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/withings/withings_config.dart';
import '../../core/withings/withings_service.dart';
import '../../database/database.dart';
import '../widgets/custom_picker_utils.dart';

/// 설정 > 기록 동기화: 외부 서비스 목록
class SyncScreen extends StatelessWidget {
  final AppDatabase database;

  const SyncScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("기록 동기화", style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(children: [
        ListTile(
          title: const Text("Withings"),
          subtitle: Text(WithingsConfig.isConfigured
              ? "수면 기록(취침·기상 시각, 총 수면시간) 가져오기"
              : "Client ID / Secret / Redirect URI 미설정 (--dart-define 필요)"),
          leading: const Icon(Icons.watch_rounded),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WithingsSyncScreen(database: database)),
          ),
        ),
        const Divider(),
      ]),
    );
  }
}

/// 설정 > 기록 동기화 > Withings: 기간을 골라 수면 기록 가져오기
class WithingsSyncScreen extends StatefulWidget {
  final AppDatabase database;

  const WithingsSyncScreen({super.key, required this.database});

  @override
  State<WithingsSyncScreen> createState() => _WithingsSyncScreenState();
}

class _WithingsSyncScreenState extends State<WithingsSyncScreen> {
  late DateTime _from;
  late DateTime _to;
  bool _isImporting = false;
  WithingsImportResult? _result;
  String? _error;

  final _dateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _to = DateTime(now.year, now.month, now.day);
    _from = _to.subtract(const Duration(days: WithingsConfig.importDays));
  }

  Future<void> _pickFrom() async {
    final picked = await CustomPickerUtils.pickDate(
      context: context,
      initialDate: _from,
      lastDate: _to,
      helpText: "시작 날짜 선택",
    );
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickTo() async {
    final picked = await CustomPickerUtils.pickDate(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now(),
      helpText: "종료 날짜 선택",
    );
    if (picked != null) setState(() => _to = picked);
  }

  Future<void> _import() async {
    setState(() {
      _isImporting = true;
      _result = null;
      _error = null;
    });
    try {
      final result = await WithingsService(widget.database).connectAndImport(from: _from, to: _to);
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) setState(() => _error = e is WithingsException ? e.message : "Withings 가져오기 실패: $e");
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _to.difference(_from).inDays + 1;
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: const Text("Withings", style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("가져올 기간", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: const Text("시작 날짜"),
          subtitle: Text(_dateFormat.format(_from)),
          leading: const Icon(Icons.event_rounded),
          enabled: !_isImporting,
          onTap: _pickFrom,
        ),
        ListTile(
          title: const Text("종료 날짜"),
          subtitle: Text(_dateFormat.format(_to)),
          leading: const Icon(Icons.event_available_rounded),
          enabled: !_isImporting,
          onTap: _pickTo,
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.shield_outlined),
          title: Text("기존 기록 보호"),
          subtitle: Text("가져오기 전에 현재 DB를 별도 백업 파일로 보존하고, Withings 원본 데이터도 따로 보관합니다. "
              "저장 도중 문제가 생기면 변경 내용 전체가 취소됩니다."),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: _isImporting || !WithingsConfig.isConfigured ? null : _import,
            icon: _isImporting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_rounded),
            label: Text(_isImporting ? "가져오는 중..." : "$days일간 수면 기록 가져오기"),
          ),
        ),
        if (!WithingsConfig.isConfigured)
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            subtitle: Text("Client ID / Secret / Redirect URI가 설정되지 않았습니다. --dart-define 으로 넣어 실행하세요."),
          ),
        if (_error != null)
          ListTile(
            leading: const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            title: Text(_error!),
          ),
        if (result != null) ...[
          ListTile(
            leading: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
            title: Text(result.message),
          ),
          if (result.backupPath != null)
            ListTile(dense: true, title: const Text("DB 백업"), subtitle: Text(result.backupPath!)),
          if (result.rawPath != null)
            ListTile(dense: true, title: const Text("Withings 원본 보관"), subtitle: Text(result.rawPath!)),
        ],
      ]),
    );
  }
}
