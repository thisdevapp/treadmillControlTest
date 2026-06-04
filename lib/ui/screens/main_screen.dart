import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import '../../database/database.dart';
import '../widgets/custom_picker_utils.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final AppDatabase database;

  const MainScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.database,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  double _longPressSeconds = 4.0;
  DateTime _selectedDate = DateTime.now();

  final List<String> _titles = ["기록 일지", "수면 통계", "환경 설정"];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _longPressSeconds = prefs.getDouble('long_press_seconds') ?? 4.0;
    });
  }

  Future<void> _saveLongPressSeconds(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('long_press_seconds', value);
    setState(() {
      _longPressSeconds = value;
    });
  }

  IconData _getIconData(String? name) {
    switch (name) {
      case 'hotel': return Icons.hotel;
      case 'medication': return Icons.medication;
      case 'coffee': return Icons.local_cafe;
      case 'smoke': return Icons.smoking_rooms;
      case 'sports': return Icons.directions_run;
      case 'beer': return Icons.local_bar;
      case 'star': return Icons.star;
      case 'favorite': return Icons.favorite;
      case 'mood': return Icons.mood;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildRecordJournalView(),
          StatisticsScreen(
            database: widget.database,
            longPressSeconds: _longPressSeconds,
          ),
          _buildSettingsView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit_calendar), label: "일지 기록"),
          NavigationDestination(icon: Icon(Icons.legend_toggle), label: "분석 통계"),
          NavigationDestination(icon: Icon(Icons.tune), label: "설정"),
        ],
      ),
    );
  }

  Widget _buildRecordJournalView() {
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 0, 0, 0);
    final endOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    return StreamBuilder<List<CustomDataType>>(
      stream: widget.database.watchCustomDataTypes(),
      builder: (context, typeSnapshot) {
        if (!typeSnapshot.hasData) return const Center(child: CircularProgressIndicator());

        final types = typeSnapshot.data!;
        final sleepType = types.firstWhere((t) => t.isPreset && t.name == '수면', orElse: () => types[0]);
        final otherTypes = types.where((t) => t.id != sleepType.id).toList();

        return StreamBuilder<List<CustomDataRecord>>(
          stream: widget.database.watchRecordsInPeriod(startOfDay, endOfDay),
          builder: (context, recordSnapshot) {
            final records = recordSnapshot.data ?? [];
            final sleepRecords = records.where((r) => r.typeId == sleepType.id).toList();
            final otherRecords = records.where((r) => r.typeId != sleepType.id).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                _buildDateNavigator(),
                const SizedBox(height: 12),
                _buildSleepSection(sleepType, sleepRecords),
                const SizedBox(height: 20),
                if (otherTypes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("일상 영향 요소 기록", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => _showManageTypesDialog(),
                        icon: const Icon(Icons.add_circle_outline, size: 16),
                        label: const Text("유형 관리", style: TextStyle(fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildQuickLogGrid(otherTypes),
                  const SizedBox(height: 24),
                ],
                if (records.isNotEmpty) ...[
                  const Text("선택한 날의 기록 타임라인", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTimeline(records, types),
                ] else ...[
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    child: const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text("아직 기록된 항목이 없습니다.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateNavigator() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).isAtSameMomentAs(today);

    return Card(
      elevation: 0,
      color: Colors.indigo.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.indigo),
              onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
            ),
            InkWell(
              onTap: () async {
                final picked = await CustomPickerUtils.pickDate(context: context, initialDate: _selectedDate);
                if (picked != null) setState(() => _selectedDate = picked);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 18, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDate) + (isToday ? " [오늘]" : ""),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.indigo),
              onPressed: isToday ? null : () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepSection(CustomDataType sleepType, List<CustomDataRecord> sleepRecords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("수면 세션 기록", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            FilledButton.icon(
              onPressed: () => _showSleepLogDialog(sleepType.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("수면 기록 추가", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (sleepRecords.isEmpty)
          Card(
            elevation: 0,
            color: Colors.green.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.green.withOpacity(0.15))),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Center(child: Text("기록된 수면이 없습니다. 수면 일지를 추가해 주세요.", style: TextStyle(color: Colors.grey, fontSize: 13))),
            ),
          )
        else
          Column(
            children: sleepRecords.map((record) {
              int? endUnix;
              int quality = 3;
              String memo = "";
              if (record.value != null) {
                try {
                  final data = json.decode(record.value!);
                  endUnix = data['endUnix'] as int?;
                  quality = data['quality'] as int? ?? 3;
                  memo = data['memo'] as String? ?? "";
                } catch (_) { endUnix = int.tryParse(record.value!); }
              }
              final startDT = DateTime.fromMillisecondsSinceEpoch(record.unixTimestamp * 1000);
              final endDT = endUnix != null ? DateTime.fromMillisecondsSinceEpoch(endUnix * 1000) : null;
              final durationMin = endDT != null ? endDT.difference(startDT).inMinutes : null;

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.green.withOpacity(0.2))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.hotel, color: Colors.green, size: 24)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(DateFormat('HH:mm').format(startDT), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text(" ~ ", style: TextStyle(color: Colors.grey, fontSize: 15)),
                          Text(endDT != null ? DateFormat('HH:mm').format(endDT) : "진행중", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (durationMin != null) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(6)), child: Text("${durationMin ~/ 60}시간 ${durationMin % 60}분", style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)))]
                        ]),
                        const SizedBox(height: 6),
                        Row(children: List.generate(5, (index) => Icon(index < quality ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                        if (memo.isNotEmpty) ...[const SizedBox(height: 6), Text(memo, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic))]
                      ])),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _confirmDeleteRecord(record.id, "수면 기록")),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildQuickLogGrid(List<CustomDataType> otherTypes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: otherTypes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 64),
      itemBuilder: (context, index) {
        final type = otherTypes[index];
        final typeColor = Color(type.colorValue ?? Colors.indigo.value);
        return Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: typeColor.withOpacity(0.15))),
          child: InkWell(
            onTap: () => _quickLogEvent(type),
            borderRadius: BorderRadius.circular(16),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0), child: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: typeColor.withOpacity(0.08), shape: BoxShape.circle), child: Icon(_getIconData(type.iconName), color: typeColor, size: 20)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const Text("탭하여 빠른기록", style: TextStyle(fontSize: 10, color: Colors.grey))
              ])),
              IconButton(icon: const Icon(Icons.edit_note, size: 18), color: typeColor, constraints: const BoxConstraints(), padding: EdgeInsets.zero, onPressed: () => _showDetailLogSheet(type)),
            ])),
          ),
        );
      },
    );
  }

  Widget _buildTimeline(List<CustomDataRecord> records, List<CustomDataType> types) {
    final sortedRecords = List<CustomDataRecord>.from(records)..sort((a, b) => b.unixTimestamp.compareTo(a.unixTimestamp));
    return Column(children: sortedRecords.map((record) {
      final type = types.firstWhere((t) => t.id == record.typeId, orElse: () => types[0]);
      final typeColor = Color(type.colorValue ?? Colors.indigo.value);
      final dt = DateTime.fromMillisecondsSinceEpoch(record.unixTimestamp * 1000);
      final timeStr = DateFormat('HH:mm').format(dt);
      String title = type.name;
      String subtitle = "";
      if (type.name == '수면' && record.value != null) {
        try {
          final data = json.decode(record.value!);
          final endUnix = data['endUnix'] as int?;
          final startDT = DateTime.fromMillisecondsSinceEpoch(record.unixTimestamp * 1000);
          final endDT = endUnix != null ? DateTime.fromMillisecondsSinceEpoch(endUnix * 1000) : null;
          if (endDT != null) subtitle = "${endDT.difference(startDT).inHours}시간 ${endDT.difference(startDT).inMinutes % 60}분 수면 (${data['quality']}★)";
        } catch (_) { subtitle = "수면기록"; }
      } else if (record.value != null && record.value!.trim().isNotEmpty) { subtitle = record.value!; }
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(backgroundColor: typeColor.withOpacity(0.1), radius: 16, child: Icon(_getIconData(type.iconName), color: typeColor, size: 16)),
          title: Row(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const Spacer(), Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
          subtitle: subtitle.isNotEmpty ? Padding(padding: const EdgeInsets.only(top: 2.0), child: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))) : null,
          trailing: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.grey), onPressed: () => _confirmDeleteRecord(record.id, type.name)),
        ),
      );
    }).toList());
  }

  Widget _buildSettingsView() {
    return ListView(children: [
      const Padding(padding: EdgeInsets.all(16.0), child: Text("테마 및 사용자 환경", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      RadioListTile<ThemeMode>(title: const Text("시스템 설정"), value: ThemeMode.system, groupValue: widget.currentThemeMode, onChanged: (value) => widget.onThemeChanged(value!)),
      RadioListTile<ThemeMode>(title: const Text("라이트 모드"), value: ThemeMode.light, groupValue: widget.currentThemeMode, onChanged: (value) => widget.onThemeChanged(value!)),
      RadioListTile<ThemeMode>(title: const Text("다크 모드"), value: ThemeMode.dark, groupValue: widget.currentThemeMode, onChanged: (value) => widget.onThemeChanged(value!)),
      const Divider(),
      ListTile(title: const Text("데이터 삭제를 위한 길게 누르기 시간"), subtitle: Text("차트 지표 꾹 누르기 시간: ${_longPressSeconds.toStringAsFixed(1)}초"), leading: const Icon(Icons.timer)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Slider(value: _longPressSeconds, min: 1.0, max: 10.0, divisions: 18, onChanged: (value) => _saveLongPressSeconds(value))),
      const Divider(),
      const Padding(padding: EdgeInsets.all(16.0), child: Text("데이터베이스 관리", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ListTile(title: const Text("기록 유형 커스텀 관리"), subtitle: const Text("수면에 방해/영향을 주는 항목 및 복용 약물을 직접 커스텀해보세요."), leading: const Icon(Icons.dashboard_customize, color: Colors.indigo), onTap: () => _showManageTypesDialog()),
      ListTile(title: const Text("모든 데이터 초기화"), subtitle: const Text("모든 커스텀 설정 및 기록 데이터를 영구히 파괴합니다."), leading: const Icon(Icons.delete_forever, color: Colors.redAccent), onTap: () => _confirmResetAllData()),
    ]);
  }

  Future<void> _quickLogEvent(CustomDataType type) async {
    final now = DateTime.now();
    final logTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, now.hour, now.minute, now.second);
    final recordId = await widget.database.addCustomDataRecord(typeId: type.id, timestamp: logTime);
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${type.name} 기록되었습니다. (${DateFormat('HH:mm').format(logTime)})"), action: SnackBarAction(label: "실행 취소", onPressed: () => widget.database.deleteCustomDataRecord(recordId))));
    }
  }

  void _showDetailLogSheet(CustomDataType type) async {
    final recentValues = await widget.database.getRecentRecordValues(type.id);
    final textController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    if (mounted) {
      showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => StatefulBuilder(builder: (context, setSheetState) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 20, right: 20, top: 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(_getIconData(type.iconName), color: Color(type.colorValue ?? Colors.indigo.value)), const SizedBox(width: 8), Text("${type.name} 상세 입력", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        Row(children: [const Text("기록 시각: ", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), OutlinedButton.icon(onPressed: () async { final time = await CustomPickerUtils.pickTime(context: context, initialTime: selectedTime); if (time != null) setSheetState(() => selectedTime = time); }, icon: const Icon(Icons.access_time, size: 16), label: Text(selectedTime.format(context)))]),
        const SizedBox(height: 16),
        TextField(controller: textController, decoration: InputDecoration(labelText: "추가 정보 / 약 이름 및 용량", hintText: "예: 졸피뎀 10mg, 아메리카노 1잔 등", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        if (recentValues.isNotEmpty) ...[const SizedBox(height: 12), const Text("최근 기입 목록 (탭하여 바로 입력)", style: TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 6), Wrap(spacing: 6, runSpacing: 4, children: recentValues.map((val) => InkWell(onTap: () => textController.text = val, child: Chip(label: Text(val, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact))).toList())],
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")), const SizedBox(width: 8), FilledButton(onPressed: () async { final logTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, selectedTime.hour, selectedTime.minute); await widget.database.addCustomDataRecord(typeId: type.id, timestamp: logTime, value: textController.text.trim().isEmpty ? null : textController.text.trim()); if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${type.name} 상세 입력 완료"))); } }, child: const Text("저장"))])
      ]))));
    }
  }

  void _showSleepLogDialog(int sleepTypeId) {
    DateTime startDT = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 22, 0);
    DateTime endDT = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 7, 0).add(const Duration(days: 1));
    int selectedQuality = 3;
    final memoController = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) => AlertDialog(
      title: const Row(children: [Icon(Icons.bedtime, color: Colors.green), SizedBox(width: 8), Text("수면 기록 추가", style: TextStyle(fontWeight: FontWeight.bold))]),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("취침 시각", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
        Row(children: [Expanded(child: OutlinedButton(onPressed: () async { final d = await CustomPickerUtils.pickDate(context: context, initialDate: startDT); if (d != null) setDlgState(() { startDT = DateTime(d.year, d.month, d.day, startDT.hour, startDT.minute); if (endDT.isBefore(startDT)) endDT = startDT.add(const Duration(hours: 8)); }); }, child: Text(DateFormat('MM월 dd일').format(startDT)))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () async { final t = await CustomPickerUtils.pickTime(context: context, initialTime: TimeOfDay.fromDateTime(startDT)); if (t != null) setDlgState(() { startDT = DateTime(startDT.year, startDT.month, startDT.day, t.hour, t.minute); if (endDT.isBefore(startDT)) endDT = startDT.add(const Duration(hours: 8)); }); }, child: Text(DateFormat('HH:mm').format(startDT))))]),
        const SizedBox(height: 12),
        const Text("기상 시각", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
        Row(children: [Expanded(child: OutlinedButton(onPressed: () async { final d = await CustomPickerUtils.pickDate(context: context, initialDate: endDT); if (d != null) setDlgState(() { endDT = DateTime(d.year, d.month, d.day, endDT.hour, endDT.minute); if (endDT.isBefore(startDT)) startDT = endDT.subtract(const Duration(hours: 8)); }); }, child: Text(DateFormat('MM월 dd일').format(endDT)))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: () async { final t = await CustomPickerUtils.pickTime(context: context, initialTime: TimeOfDay.fromDateTime(endDT)); if (t != null) setDlgState(() { endDT = DateTime(endDT.year, endDT.month, endDT.day, t.hour, t.minute); if (endDT.isBefore(startDT)) startDT = endDT.subtract(const Duration(hours: 8)); }); }, child: Text(DateFormat('HH:mm').format(endDT))))]),
        const SizedBox(height: 8),
        Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Text("총 수면 시간: ${endDT.difference(startDT).inHours}시간 ${endDT.difference(startDT).inMinutes % 60}분", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)))),
        const SizedBox(height: 16),
        const Text("수면 만족도", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) => IconButton(icon: Icon(index < selectedQuality ? Icons.star : Icons.star_border, color: Colors.amber, size: 28), onPressed: () => setDlgState(() => selectedQuality = index + 1)))),
        const SizedBox(height: 12),
        TextField(controller: memoController, decoration: InputDecoration(labelText: "수면 만족도 사유 및 메모", hintText: "예: 꿈을 많이 꿨다, 새벽에 깼음", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")), FilledButton(onPressed: () async { final valueJson = json.encode({'endUnix': endDT.millisecondsSinceEpoch ~/ 1000, 'quality': selectedQuality, 'memo': memoController.text.trim()}); await widget.database.addCustomDataRecord(typeId: sleepTypeId, timestamp: startDT, value: valueJson); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text("기록"))]
    )));
  }

  void _confirmDeleteRecord(int recordId, String typeName) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text("$typeName 삭제"), content: const Text("정말로 이 기록을 삭제하시겠습니까?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")), TextButton(onPressed: () async { await widget.database.deleteCustomDataRecord(recordId); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text("삭제", style: TextStyle(color: Colors.red)))]));
  }

  void _showManageTypesDialog() {
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) => AlertDialog(title: const Row(children: [Icon(Icons.dashboard_customize, color: Colors.indigo), SizedBox(width: 8), Text("기록 유형 관리", style: TextStyle(fontWeight: FontWeight.bold))]), content: SizedBox(width: double.maxFinite, height: 380, child: FutureBuilder<List<CustomDataType>>(future: widget.database.getCustomDataTypes(), builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final types = snapshot.data!; return Column(children: [Expanded(child: ListView.builder(itemCount: types.length, itemBuilder: (context, index) { final type = types[index]; final typeColor = Color(type.colorValue ?? Colors.indigo.value); return ListTile(dense: true, leading: Icon(_getIconData(type.iconName), color: typeColor), title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(type.isPreset ? "기본 프리셋 (수정불가)" : "커스텀 유형", style: const TextStyle(fontSize: 10)), trailing: type.isPreset ? null : Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, size: 16, color: Colors.grey), onPressed: () => _showAddOrEditTypeDialog(type: type, onSaved: () => setDlgState(() {}))), IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent), onPressed: () => _confirmDeleteType(type, () => setDlgState(() {})))])); })), const Divider(), FilledButton.icon(onPressed: () => _showAddOrEditTypeDialog(onSaved: () => setDlgState(() {})), icon: const Icon(Icons.add), label: const Text("새 기록 유형 만들기"))]); })), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("닫기"))])));
  }

  void _showAddOrEditTypeDialog({CustomDataType? type, required VoidCallback onSaved}) {
    final nameController = TextEditingController(text: type?.name ?? "");
    String selectedIcon = type?.iconName ?? "medication";
    int selectedColor = type?.colorValue ?? 0xFF3F51B5;
    final List<Map<String, dynamic>> icons = [{'name': 'medication', 'icon': Icons.medication, 'label': '약물'}, {'name': 'coffee', 'icon': Icons.local_cafe, 'label': '카페인'}, {'name': 'smoke', 'icon': Icons.smoking_rooms, 'label': '담배'}, {'name': 'sports', 'icon': Icons.directions_run, 'label': '운동'}, {'name': 'beer', 'icon': Icons.local_bar, 'label': '술'}, {'name': 'star', 'icon': Icons.star, 'label': '스타'}, {'name': 'favorite', 'icon': Icons.favorite, 'label': '사랑'}, {'name': 'mood', 'icon': Icons.mood, 'label': '감정'}];
    final List<int> colors = [0xFF3F51B5, 0xFF4CAF50, 0xFFFF9800, 0xFFE91E63, 0xFF009688, 0xFF9C27B0, 0xFF2196F3, 0xFF795548];
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) => AlertDialog(title: Text(type == null ? "새 유형 만들기" : "기록 유형 편집", style: const TextStyle(fontWeight: FontWeight.bold)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: nameController, decoration: const InputDecoration(labelText: "유형 이름 (예: 커피, 졸피뎀 5mg)", border: OutlineInputBorder())),
      const SizedBox(height: 16),
      const Text("대표 아이콘 선택", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: icons.map((item) { final bool isSelected = selectedIcon == item['name']; return ChoiceChip(avatar: Icon(item['icon'], size: 16, color: isSelected ? Colors.white : Colors.indigo), label: Text(item['label']), selected: isSelected, selectedColor: Colors.indigo, labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black), onSelected: (selected) { if (selected) setDlgState(() => selectedIcon = item['name'] as String); }); }).toList()),
      const SizedBox(height: 16),
      const Text("대표 컬러 선택", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, children: colors.map<Widget>((colorVal) { final bool isSelected = selectedColor == colorVal; return GestureDetector(onTap: () => setDlgState(() => selectedColor = colorVal), child: CircleAvatar(backgroundColor: Color(colorVal), radius: 14, child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null)); }).toList()),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")), FilledButton(onPressed: () async { final name = nameController.text.trim(); if (name.isEmpty) return; if (type == null) { await widget.database.addCustomDataType(name: name, iconName: selectedIcon, colorValue: selectedColor); } else { await widget.database.updateCustomDataType(type.id, name, selectedIcon, selectedColor); } onSaved(); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text("저장"))])));
  }

  void _confirmDeleteType(CustomDataType type, VoidCallback onDeleteDone) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text("${type.name} 유형 삭제"), content: Text("정말로 이 기록 유형을 삭제하시겠습니까?\n\n※ 주의: 이 유형에 속한 모든 기존 기록 데이터(${type.name})도 영구적으로 파괴됩니다."), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")), TextButton(onPressed: () async { await widget.database.deleteCustomDataType(type.id); onDeleteDone(); if (ctx.mounted) Navigator.pop(ctx); }, child: const Text("전체 삭제", style: TextStyle(color: Colors.red)))]));
  }

  void _confirmResetAllData() {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("데이터 영구 초기화"), content: const Text("정말로 모든 커스텀 유형 설정 및 수면 기록을 영구 파괴하시겠습니까? 이 작업은 절대 취소할 수 없습니다."), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")), TextButton(onPressed: () async {
      await widget.database.transaction(() async {
        await widget.database.delete(widget.database.customDataRecords).go();
        await widget.database.delete(widget.database.customDataTypes).go();
        await widget.database.into(widget.database.customDataTypes).insert(CustomDataTypesCompanion.insert(name: '수면', iconName: const Value('hotel'), colorValue: const Value(0xFF4CAF50), isPreset: const Value(true)));
        await widget.database.into(widget.database.customDataTypes).insert(CustomDataTypesCompanion.insert(name: '약 복용', iconName: const Value('medication'), colorValue: const Value(0xFF3F51B5), isPreset: const Value(true)));
      });
      if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("모든 데이터가 완벽하게 초기화되었습니다."))); }
    }, child: const Text("영구 파괴", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))]));
  }
}
