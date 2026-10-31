import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majlis/features/profile/screens/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders extra buttons for signed in user', (WidgetTester tester) async {
    // Note: This relies on the mock auth providing a demo user by default
    // based on `currentUserProvider` -> `authStateProvider` logic.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // Initial load wait
    await tester.pumpAndSettle();

    // Verify '마이페이지' title
    expect(find.text('마이페이지'), findsWidgets);

    // Verify extra buttons exist
    expect(find.widgetWithText(TextButton, '로그아웃'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '회원탈퇴'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '개인정보 처리방침'), findsOneWidget);

    // Verify AlertDialog opens on '회원탈퇴' tap
    await tester.tap(find.widgetWithText(TextButton, '회원탈퇴'));
    await tester.pumpAndSettle();

    expect(find.text('정말로 탈퇴하시겠습니까?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '취소'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '탈퇴하기'), findsOneWidget);
  });
}
