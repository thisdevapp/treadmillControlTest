import 'package:intl/intl.dart';

class SleepCalculator {
  /// HH:mm 문자열을 분 단위로 변환 (00:00 기준)
  static int? timeToMinutes(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return null;
    }
  }

  /// 두 시간 사이의 차이 계산 (분 단위)
  /// 자정을 넘기는 경우를 처리함 (예: 23:00 ~ 07:00)
  static int calculateDifference(String startStr, String endStr) {
    int start = timeToMinutes(startStr) ?? 0;
    int end = timeToMinutes(endStr) ?? 0;

    if (end < start) {
      // 자정을 넘긴 경우
      return (1440 - start) + end;
    }
    return end - start;
  }

  /// TIB (Time In Bed): 침대에 누운 시간부터 나온 시간까지
  static int calculateTIB(String tryToSleep, String outOfBed) {
    return calculateDifference(tryToSleep, outOfBed);
  }

  /// TST (Total Sleep Time): TIB - SOL - WASO
  static int calculateTST(int tibMin, int solMin, int wasoMin) {
    int tst = tibMin - solMin - wasoMin;
    return tst > 0 ? tst : 0;
  }

  /// SE (Sleep Efficiency): (TST / TIB) * 100
  static double calculateSE(int tstMin, int tibMin) {
    if (tibMin <= 0) return 0.0;
    double se = (tstMin / tibMin) * 100;
    return double.parse(se.toStringAsFixed(1));
  }

  /// 분 단위를 "H시간 M분" 문자열로 변환
  static String formatMinutes(int? totalMinutes) {
    if (totalMinutes == null) return "-";
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours == 0) return "$minutes분";
    return "$hours시간 $minutes분";
  }
}
