import 'package:flutter/material.dart';

/// 나중에 디자인 변경이 용이하도록 모듈화된 피커 유틸리티
class CustomPickerUtils {
  /// 날짜 선택 팝업
  static Future<DateTime?> pickDate({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    // 현재는 Material Design의 showDatePicker를 사용하지만,
    // 나중에 이 부분을 커스텀 UI로 교체하면 앱 전체의 날짜 선택기가 일관되게 변경됩니다.
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      helpText: helpText,
    );
  }

  /// 시간 선택 팝업
  static Future<TimeOfDay?> pickTime({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? helpText,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
    );
  }
}
