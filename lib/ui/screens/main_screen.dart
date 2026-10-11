import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/l10n/app_locale.dart';
import '../../database/database.dart';
import '../widgets/quick_add_button.dart';
import '../widgets/record_manager.dart';
import '../widgets/record_type_manager.dart';
import 'convenience_settings_screen.dart';
import 'data_settings_screen.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final AppDatabase database;

  const MainScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.database,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 0: 통계, 1: 설정
  double _longPressSeconds = 4.0;
  bool _showAllDetails = false; // 통계 상세 표시 설정 상태 추가
  double _undoToastSeconds = RecordManager.undoToastSeconds;
  ChartDateLabelMode _dateLabelMode = ChartDateLabelMode.dynamic;

  List<String> get _titles => [tr("통계 분석", "Statistics"), tr("환경 설정", "Settings")];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _longPressSeconds = prefs.getDouble('long_press_seconds') ?? 4.0;
      _showAllDetails = prefs.getBool('statistics_show_details') ?? false;
      _undoToastSeconds = prefs.getDouble('undo_toast_seconds') ?? RecordManager.undoToastSeconds;
      RecordManager.undoToastSeconds = _undoToastSeconds;
      final int labelModeIndex = prefs.getInt('chart_date_label_mode') ?? 0;
      _dateLabelMode = ChartDateLabelMode.values[labelModeIndex.clamp(0, ChartDateLabelMode.values.length - 1)];
    });
  }

  Future<void> _saveDateLabelMode(ChartDateLabelMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chart_date_label_mode', mode.index);
    setState(() {
      _dateLabelMode = mode;
    });
  }

  Future<void> _saveLongPressSeconds(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('long_press_seconds', value);
    setState(() {
      _longPressSeconds = value;
    });
  }

  Future<void> _saveUndoToastSeconds(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('undo_toast_seconds', value);
    RecordManager.undoToastSeconds = value;
    setState(() {
      _undoToastSeconds = value;
    });
  }

  Future<void> _updateShowAllDetails(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('statistics_show_details', value);
    setState(() {
      _showAllDetails = value;
    });
  }

  Color get _bgColor => Theme.of(context).brightness == Brightness.light ? const Color(0xFFF0F2F8) : const Color(0xFF101012);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StatisticsScreen(
            database: widget.database,
            longPressSeconds: _longPressSeconds,
            showAllDetails: _showAllDetails,
            onShowAllDetailsChanged: _updateShowAllDetails,
            dateLabelMode: _dateLabelMode,
          ),
          _buildSettingsView(),
        ],
      ),
      // 가운데 큰 + 버튼: 한 번 누르면 마지막 점 데이터 추가, 꾹 누르면 데이터 종류 다이얼
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: QuickAddButton(
        database: widget.database,
        color: const Color(0xFF4CAF50),
        iconColor: _bgColor,
        onTap: _quickAddLast,
        onSelectType: _logType,
        onTypeMenu: _showWidgetMenu,
        onAddType: () => RecordTypeManager.showAddOrEditTypeDialog(context: context, database: widget.database, onSaved: () {}),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(child: _navItem(0, Icons.analytics_rounded, tr("통계", "Stats"))),
            const SizedBox(width: QuickAddButton.size + 24),
            Expanded(child: _navItem(1, Icons.settings_rounded, tr("설정", "Settings"))),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    final bool selected = _selectedIndex == index;
    final Color color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // ==========================================
  // [1] 설정 탭 뷰
  // ==========================================
  Widget _buildSettingsView() {
    return ListView(children: [
      Padding(padding: const EdgeInsets.all(16.0), child: Text(tr("환경 설정", "Settings"), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ListTile(
        title: Text(tr("언어", "Language")),
        subtitle: Text(AppLocale.setting.label),
        leading: const Icon(Icons.language_rounded),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: _showLanguageDialog,
      ),
      const Divider(),
      ListTile(
        title: Text(tr("편의성 기능", "Convenience")),
        subtitle: Text(tr("테마, 꾹 누르기 시간, 수정취소 알림, 차트 보기", "Theme, long-press time, undo notice, chart view")),
        leading: const Icon(Icons.tune_rounded),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConvenienceSettingsScreen(
          themeMode: widget.currentThemeMode,
          onThemeChanged: widget.onThemeChanged,
          longPressSeconds: _longPressSeconds,
          onLongPressSecondsChanged: _saveLongPressSeconds,
          undoToastSeconds: _undoToastSeconds,
          onUndoToastSecondsChanged: _saveUndoToastSeconds,
          dateLabelMode: _dateLabelMode,
          onDateLabelModeChanged: _saveDateLabelMode,
          showAllDetails: _showAllDetails,
          onShowAllDetailsChanged: _updateShowAllDetails,
        ))),
      ),
      const Divider(),
      ListTile(
        title: Text(tr("데이터", "Data")),
        subtitle: Text(tr("기록 동기화, 모든 데이터 초기화", "Sync records, reset all data")),
        leading: const Icon(Icons.storage_rounded),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DataSettingsScreen(database: widget.database))),
      ),
    ]);
  }

  /// 설정 > 언어: 시스템 설정 / 한국어 / English
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(tr("언어", "Language")),
        children: [
          RadioGroup<AppLanguage>(
            groupValue: AppLocale.setting,
            onChanged: (value) {
              Navigator.pop(ctx);
              if (value != null) widget.onLanguageChanged(value);
            },
            child: Column(children: [
              for (final lang in AppLanguage.values)
                RadioListTile<AppLanguage>(title: Text(lang.label), value: lang),
            ]),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // [2] 비즈니스 로직
  // ==========================================
  /// 마지막에 추가한 점 데이터(수면 제외)와 같은 종류를 지금 시각으로 한 번 더 기록.
  /// 아직 점 기록이 없으면 false (다이얼을 대신 엶)
  Future<bool> _quickAddLast() async {
    final types = await widget.database.getCustomDataTypes();
    final sleepType = RecordManager.findSleepType(types);
    final last = await widget.database.getLastAddedRecord(excludeTypeId: sleepType?.id);
    final type = types.where((t) => t.id == last?.typeId).firstOrNull;
    if (type == null || !mounted) return false;
    _logType(type);
    return true;
  }

  void _logType(CustomDataType type) {
    if (type.name == '수면') {
      RecordManager.showSleepLogDialog(
        context: context,
        database: widget.database,
        sleepTypeId: type.id,
        onShowToast: _showToast,
      );
    } else {
      RecordManager.quickLogEvent(
        context: context,
        database: widget.database,
        type: type,
        onShowToast: _showToast,
      );
    }
  }

  void _showToast(CustomDataType type, String message) {
    RecordManager.showRecordToast(context, type, message);
  }

  void _showWidgetMenu(CustomDataType type) {
    final color = Color(type.colorValue ?? Colors.indigo.toARGB32());
    final onColor = Theme.of(context).scaffoldBackgroundColor;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type.name != '수면') ...[
              _menuOption(
                ctx,
                icon: Icons.add_circle_outline_rounded,
                label: tr("지금 기록 추가", "Log now"),
                onColor: onColor,
                onTap: () => RecordManager.quickLogEvent(
                  context: context,
                  database: widget.database,
                  type: type,
                  onShowToast: _showToast,
                ),
              ),
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            ],
            _menuOption(
              ctx,
              icon: Icons.history_rounded,
              label: tr("지난 기록 추가", "Add past record"),
              onColor: onColor,
              onTap: () {
                if (type.name == '수면') {
                  RecordManager.showSleepLogDialog(
                    context: context,
                    database: widget.database,
                    sleepTypeId: type.id,
                    onShowToast: _showToast,
                  );
                } else {
                  RecordManager.showAddPastRecordDialog(
                    context: context,
                    database: widget.database,
                    type: type,
                    onShowToast: _showToast,
                  );
                }
              },
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _menuOption(
              ctx,
              icon: Icons.note_add_rounded,
              label: tr("메모 추가", "Add memo"),
              onColor: onColor,
              onTap: () => RecordManager.showMemoDialog(
                context: context,
                database: widget.database,
                type: type,
                onShowToast: _showToast,
              ),
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _menuOption(
              ctx,
              icon: Icons.settings_suggest_rounded,
              label: tr("기록 수정", "Edit type"),
              onColor: onColor,
              onTap: () => RecordTypeManager.showAddOrEditTypeDialog(
                context: context, 
                database: widget.database, 
                type: type, 
                onSaved: () {}
              ),
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _menuOption(
              ctx,
              icon: Icons.delete_outline_rounded,
              label: tr("종류 삭제", "Delete type"),
              onColor: onColor,
              onTap: () => RecordTypeManager.confirmDeleteType(
                context: context,
                database: widget.database,
                type: type,
                onDeleteDone: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuOption(BuildContext dialogCtx,
      {required IconData icon, required String label, required Color onColor, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: onColor),
      title: Text(label, style: TextStyle(color: onColor, fontWeight: FontWeight.bold, fontSize: 16)),
      onTap: () {
        Navigator.pop(dialogCtx);
        onTap();
      },
    );
  }
}
