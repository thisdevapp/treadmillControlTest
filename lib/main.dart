import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ui/screens/main_screen.dart';
import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);
  
  // 사용자 설정 테마 로드
  final prefs = await SharedPreferences.getInstance();
  final int themeIndex = prefs.getInt('themeMode') ?? 0;
  final ThemeMode initialThemeMode = ThemeMode.values[themeIndex];

  // 데이터베이스 초기화 (신규 Unix Timestamp 스키마 버전 5)
  final database = AppDatabase();

  // [임시 마이그레이션] 기존 HH:mm 데이터를 Unix Timestamp 세션 데이터로 전환
  await database.migrateOldDataToSessions();

  runApp(SleepTrackerApp(
    initialThemeMode: initialThemeMode,
    database: database,
  ));
}

class SleepTrackerApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final AppDatabase database;
  
  const SleepTrackerApp({
    super.key, 
    required this.initialThemeMode,
    required this.database,
  });

  @override
  State<SleepTrackerApp> createState() => _SleepTrackerAppState();
}

class _SleepTrackerAppState extends State<SleepTrackerApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _updateThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'NanumGothic',
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'NanumGothic',
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: MainScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _updateThemeMode,
        database: widget.database,
      ),
    );
  }
}
