import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/main_screen.dart';
import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final int themeIndex = prefs.getInt('themeMode') ?? 0;
  final ThemeMode initialThemeMode = ThemeMode.values[themeIndex];

  // 데이터베이스 인스턴스 생성
  final database = AppDatabase();

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
