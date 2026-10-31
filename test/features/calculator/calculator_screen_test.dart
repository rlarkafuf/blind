import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majlis/features/calculator/screens/calculator_screen.dart';

void main() {
  testWidgets('CalculatorScreen renders form and calculates ranking', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CalculatorScreen(),
      ),
    );

    // Verify all form fields exist
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.text('회사명'), findsOneWidget);
    expect(find.text('직무'), findsOneWidget);
    expect(find.text('경력 연수'), findsOneWidget);
    expect(find.text('기본급 (만원)'), findsOneWidget);
    expect(find.text('성과급 (만원)'), findsOneWidget);

    // Verify calculate button exists
    final calculateButton = find.text('계산하기');
    expect(calculateButton, findsOneWidget);

    // Enter text in fields
    await tester.enterText(find.widgetWithText(TextFormField, '회사명'), 'Google');
    await tester.enterText(find.widgetWithText(TextFormField, '직무'), 'Software Engineer');
    await tester.enterText(find.widgetWithText(TextFormField, '경력 연수'), '5');
    await tester.enterText(find.widgetWithText(TextFormField, '기본급 (만원)'), '10000');
    await tester.enterText(find.widgetWithText(TextFormField, '성과급 (만원)'), '2000');

    // Tap calculate button
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    // Verify result is displayed
    expect(find.text('동일 그룹 평균 대비 내 연봉 수준'), findsOneWidget);
    expect(find.text('상위 15% 입니다.'), findsOneWidget);
  });
}
