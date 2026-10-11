import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/memo/record_memo.dart';
import '../../database/database.dart';
import 'sync_screen.dart';

/// 설정 > 데이터: 기록 동기화, 모든 데이터 초기화
class DataSettingsScreen extends StatelessWidget {
  final AppDatabase database;

  const DataSettingsScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("데이터", "Data"))),
      body: ListView(children: [
        ListTile(
          title: Text(tr("기록 동기화", "Sync records")),
          subtitle: Text(tr("Withings 등 외부 기기의 기록 가져오기", "Import records from devices such as Withings")),
          leading: const Icon(Icons.sync_rounded),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SyncScreen(database: database))),
        ),
        const Divider(),
        ListTile(
          title: Text(tr("모든 데이터 초기화", "Reset all data")),
          subtitle: Text(tr("영구 파괴 및 대시보드 리셋", "Permanently delete everything and restore defaults")),
          leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
          onTap: () => _confirmResetAllData(context),
        ),
      ]),
    );
  }

  void _confirmResetAllData(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(tr("전체 초기화", "Reset everything")),
      content: Text(tr("모든 설정과 데이터를 초기화하시겠습니까?", "Reset all settings and data?")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr("취소", "Cancel"))),
        TextButton(onPressed: () async {
          final columns = MediaQuery.of(context).size.width > 600 ? 6 : 4;
          await database.transaction(() async {
            await database.delete(database.customDataRecords).go();
            await database.delete(database.customDataTypes).go();
          });
          await database.fixDataIntegrity(columns: columns);
          await MemoStore.instance.prune(const {});
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: Text(tr("초기화", "Reset"), style: const TextStyle(color: Colors.red))),
      ],
    ));
  }
}
