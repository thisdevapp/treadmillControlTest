import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  final List<String> _titles = ["기록", "통계", "설정"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              const Center(child: Text("기록 화면 (준비 중)")),
              StatisticsScreen(database: widget.database),
              _buildSettingsView(),
            ],
          ),
          // 수면제 복용 버튼은 오직 '기록' 탭에서만 보이도록 수정
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _selectedIndex == 0 
                ? _buildQuickMedicationButton()
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: "기록",
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: "통계",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "설정",
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMedicationButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // withOpacity 대신 권장되는 API 사용
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: () async {
          await widget.database.logMedicationIntake();
          
          final now = DateTime.now();
          final formattedTime = DateFormat('HH:mm').format(now);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("수면제 복용 기록됨: $formattedTime"),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        icon: const Icon(Icons.medication),
        label: const Text(
          "지금 수면제 복용",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsView() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "테마 설정",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        RadioListTile<ThemeMode>(
          title: const Text("시스템 설정"),
          secondary: const Icon(Icons.brightness_auto),
          value: ThemeMode.system,
          groupValue: widget.currentThemeMode,
          onChanged: (value) => widget.onThemeChanged(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text("라이트 모드"),
          secondary: const Icon(Icons.light_mode),
          value: ThemeMode.light,
          groupValue: widget.currentThemeMode,
          onChanged: (value) => widget.onThemeChanged(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text("다크 모드"),
          secondary: const Icon(Icons.dark_mode),
          value: ThemeMode.dark,
          groupValue: widget.currentThemeMode,
          onChanged: (value) => widget.onThemeChanged(value!),
        ),
        const Divider(),
        // DB 데이터 확인용 디버그 버튼 추가
        ListTile(
          title: const Text("전체 데이터 로그 확인 (Debug)"),
          subtitle: const Text("콘솔창에 전체 데이터를 출력합니다."),
          leading: const Icon(Icons.bug_report),
          onTap: () async {
            final allRecords = await widget.database.getAllRecords();
            print('--- DB ALL RECORDS ---');
            for (var r in allRecords) {
              print('Date: ${r.date}, Meds: ${r.medications}');
            }
            print('--- END ---');
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("콘솔창(Run 탭)에서 데이터를 확인하세요.")),
              );
            }
          },
        ),
        const Divider(),
        ListTile(
          title: const Text("데이터 백업 및 복원 (JSON)"),
          subtitle: const Text("준비 중"),
          leading: const Icon(Icons.backup),
          onTap: () {},
        ),
      ],
    );
  }
}
