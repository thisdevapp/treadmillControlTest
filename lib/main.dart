import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/l10n/app_locale.dart';
import 'core/memo/record_memo.dart';
import 'ui/screens/main_screen.dart';
import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 날짜 표기용 로케일 데이터 초기화 (언어 설정에 따라 한국어/영어 사용)
  await initializeDateFormatting();
  
  // 사용자 설정 테마 로드
  final prefs = await SharedPreferences.getInstance();
  final int themeIndex = prefs.getInt('themeMode') ?? 0;
  final ThemeMode initialThemeMode = ThemeMode.values[themeIndex];

  // 사용자 설정 언어 로드
  final int languageIndex = prefs.getInt('app_language') ?? 0;
  AppLocale.setting = AppLanguage.values[languageIndex.clamp(0, AppLanguage.values.length - 1)];

  // 데이터베이스 초기화 (신규 Unix Timestamp 스키마 버전 6)
  final database = AppDatabase();
  
  // 최초 실행 시 기본 데이터 유무 확인 및 복구
  final types = await database.getCustomDataTypes();
  if (types.isEmpty) {
    debugPrint("🆕 최초 실행: 기본 프리셋 데이터 생성 중...");
    await database.fixDataIntegrity();
  }

  // 기록 메모 (파일) 목록 로드 및 DB에 없는 기록의 메모 정리
  await MemoStore.instance.init();
  await MemoStore.instance.prune(await database.getAllRecordIds());

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

  Future<void> _updateLanguage(AppLanguage language) async {
    AppLocale.setting = language;
    setState(() {});
    // 이미 열려 있는 화면들의 문구도 바로 바뀌도록 전체를 다시 그림
    AppLocale.rebuildAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_language', language.index);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ SleepTrackerApp build 시작");
    return MaterialApp(
      title: 'Sleep Prototype',
      debugShowCheckedModeBanner: false,
      locale: AppLocale.locale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: MainScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _updateThemeMode,
        onLanguageChanged: _updateLanguage,
        database: widget.database,
      ),
    );
  }
}
