import 'package:flutter/material.dart';
import '../../database/database.dart';
import 'sync_screen.dart';

/// 설정 > 데이터: 기록 동기화, 모든 데이터 초기화
class DataSettingsScreen extends StatelessWidget {
  final AppDatabase database;

  const DataSettingsScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("데이터")),
      body: ListView(children: [
        ListTile(
          title: const Text("기록 동기화"),
          subtitle: const Text("Withings 등 외부 기기의 기록 가져오기"),
          leading: const Icon(Icons.sync_rounded),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SyncScreen(database: database))),
        ),
        const Divider(),
        ListTile(
          title: const Text("모든 데이터 초기화"),
          subtitle: const Text("영구 파괴 및 대시보드 리셋"),
          leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
          onTap: () => _confirmResetAllData(context),
        ),
      ]),
    );
  }

  void _confirmResetAllData(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("전체 초기화"),
      content: const Text("모든 설정과 데이터를 초기화하시겠습니까?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        TextButton(onPressed: () async {
          final columns = MediaQuery.of(context).size.width > 600 ? 6 : 4;
          await database.transaction(() async {
            await database.delete(database.customDataRecords).go();
            await database.delete(database.customDataTypes).go();
          });
          await database.fixDataIntegrity(columns: columns);
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text("초기화", style: TextStyle(color: Colors.red))),
      ],
    ));
  }
}
