import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majlis/features/feed/screens/feed_screen.dart';

void main() {
  testWidgets('MainScreen renders BottomNavigationBar with 5 items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('채널'), findsOneWidget);
    expect(find.text('글쓰기'), findsOneWidget);
      expect(find.text('계산기/비교'), findsOneWidget);
    expect(find.text('마이페이지'), findsOneWidget);
  });
}
