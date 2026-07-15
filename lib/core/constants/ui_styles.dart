import 'package:flutter/material.dart';

/// 앱 전반의 UI 스타일 일관성을 관리하는 클래스
class UIStyles {
  // --- 공통 스타일 상수 ---
  
  /// 위젯 및 알림 배경의 투명도 (30%)
  static const double bgOpacity = 0.3;
  
  /// 위젯 및 알림 배경의 그림자 투명도 (10%)
  static const double shadowOpacity = 0.1;

  // --- 위젯 카드 스타일 ---
  
  /// 대시보드 위젯 카드의 배경색을 계산합니다.
  static Color getWidgetBgColor(Color themeColor) {
    return themeColor.withValues(alpha: bgOpacity);
  }

  /// 대시보드 위젯의 텍스트 컬러를 결정합니다. (다크/라이트 대응)
  static Color getWidgetTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black;
  }

  // --- 알림 (Toast/SnackBar) 스타일 ---

  /// 알림의 배경색을 계산합니다. (위젯 배경과 동일한 20% 투명도)
  static Color getToastBgColor(Color themeColor) {
    return themeColor.withValues(alpha: bgOpacity);
  }

  /// 알림의 텍스트/아이콘 컬러를 결정합니다.
  /// 사용자 요청: "배경 뿐만 아니라 텍스트 컬러도 버튼과 일치시켜"
  /// -> 버튼(위젯) 텍스트와 동일하게 다크모드 흰색, 라이트모드 검은색 적용
  static Color getToastTextColor(BuildContext context) {
    return getWidgetTextColor(context);
  }
}
