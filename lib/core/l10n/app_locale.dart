import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/widgets.dart';
import '../../database/database.dart';

/// 설정 > 언어
enum AppLanguage {
  system,
  ko,
  en;

  /// 설정 화면에 보이는 이름 (각 언어는 자기 언어로 표기)
  String get label => switch (this) {
        AppLanguage.system => tr("시스템 설정", "System default"),
        AppLanguage.ko => "한국어",
        AppLanguage.en => "English",
      };
}

/// 앱 전체의 현재 언어. 지원 언어는 한국어/영어이며, 시스템 언어가 한국어가 아니면 영어로 표시
class AppLocale {
  static AppLanguage setting = AppLanguage.system;

  static const List<Locale> supportedLocales = [Locale('ko'), Locale('en')];

  /// 실제로 표시 중인 언어 ('ko' 또는 'en')
  static String get code {
    if (setting == AppLanguage.ko) return 'ko';
    if (setting == AppLanguage.en) return 'en';
    return PlatformDispatcher.instance.locale.languageCode == 'ko' ? 'ko' : 'en';
  }

  static bool get isKo => code == 'ko';
  static Locale get locale => Locale(code);

  /// intl(DateFormat)에 넘길 로케일
  static String get intl => isKo ? 'ko_KR' : 'en_US';

  /// 언어를 바꾼 뒤 이미 그려진 화면(뒤에 쌓인 화면 포함)의 문구를 모두 다시 그림
  static void rebuildAll() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
  }
}

/// 현재 언어에 맞는 문구
String tr(String ko, String en) => AppLocale.isKo ? ko : en;

/// 기간 표기 ("7시간 30분" / "7h 30m")
String trDuration(int hours, int minutes) => tr("$hours시간 $minutes분", "${hours}h ${minutes}m");

/// 앱 기본 데이터 종류의 표시 이름. DB에는 한국어 이름 그대로 두고(수면 판별 등에 사용) 화면에서만 번역
const Map<String, String> _presetNamesEn = {
  '수면': 'Sleep',
  '약 복용': 'Medication',
  '카페인': 'Caffeine',
  '음주': 'Alcohol',
  '운동': 'Exercise',
  '흡연': 'Smoking',
};

extension CustomDataTypeLabel on CustomDataType {
  /// 화면에 보이는 이름 (기본 데이터는 현재 언어로 번역)
  String get label => isPreset && !AppLocale.isKo ? (_presetNamesEn[name] ?? name) : name;
}
