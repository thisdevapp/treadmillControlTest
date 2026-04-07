import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_prototype/main.dart';
import 'package:sleep_prototype/database/database.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // 테스트용 인메모리 DB 생성
    final database = AppDatabase();
    
    await tester.pumpWidget(SleepTrackerApp(
      initialThemeMode: ThemeMode.system,
      database: database,
    ));

    expect(find.text('기록'), findsAtLeast(1));
    
    // DB 닫기
    await database.close();
  });
}
