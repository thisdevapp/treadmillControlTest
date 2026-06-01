import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database.dart';
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

  final List<String> _titles = ["기록", "통계", "설정"];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const Center(child: Text("기록 화면 (준비 중)")),
          StatisticsScreen(
            database: widget.database, 
            longPressSeconds: _longPressSeconds
          ),
          _buildSettingsView(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton.extended(
              onPressed: () async {
                await widget.database.logMedicationIntake();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("수면제 복용 기록됨")),
                  );
                }
              },
              label: const Text("지금 복용"),
              icon: const Icon(Icons.medication),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.edit_note), label: "기록"),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: "통계"),
          NavigationDestination(icon: Icon(Icons.settings), label: "설정"),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("테마 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        RadioListTile<ThemeMode>(
          title: const Text("시스템 설정"),
          value: ThemeMode.system,
          groupValue: widget.currentThemeMode,
          onChanged: (value) => widget.onThemeChanged(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text("라이트 모드"),
          value: ThemeMode.light,
          groupValue: widget.currentThemeMode,
          onChanged: (value) => widget.onThemeChanged(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text("다크 모드"),
          value: ThemeMode.dark,
          groupValue: widget.currentThemeMode,
          onChanged: (value) => widget.onThemeChanged(value!),
        ),
        const Divider(),
        ListTile(
          title: const Text("삭제를 위한 길게 누르기 시간"),
          subtitle: Text("${_longPressSeconds.toStringAsFixed(1)}초"),
          leading: const Icon(Icons.timer),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Slider(
            value: _longPressSeconds,
            min: 1.0, max: 10.0, divisions: 18,
            onChanged: (value) => _saveLongPressSeconds(value),
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text("데이터 초기화 (Debug)"),
          subtitle: const Text("모든 수면 기록과 세션을 삭제합니다."),
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          onTap: () async {
            // 디버그용 전체 삭제 로직 (필요시 구현)
          },
        ),
      ],
    );
  }
}
