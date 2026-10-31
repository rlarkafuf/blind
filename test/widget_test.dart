import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majlis/core/utils/anonymity_helper.dart';
import 'package:majlis/features/company/repositories/company_repository.dart';
import 'package:majlis/main.dart';

void main() {
  group('Zero-PII Anonymity & Domain Resolution Tests', () {
    test('SHA-256 email hashing is deterministic and case-insensitive', () {
      final hash1 = AnonymityHelper.hashEmail('engineer@adnoc.ae');
      final hash2 = AnonymityHelper.hashEmail('ENGINEER@ADNOC.AE ');
      final hash3 = AnonymityHelper.hashEmail('pilot@emirates.com');

      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));
      expect(hash1.length, equals(64)); // SHA-256 64 hex characters
    });

    test('Company domain resolution accurately maps UAE enterprises', () {
      final repo = CompanyRepository();

      final adnoc = repo.resolveCompanyByEmail('executive@adnoc.ae');
      expect(adnoc.name, equals('ADNOC'));
      expect(adnoc.isVerifiedEntity, isTrue);

      final emirates = repo.resolveCompanyByEmail('crew@emirates.com');
      expect(emirates.name, equals('Emirates Airline'));
      expect(emirates.isVerifiedEntity, isTrue);

      final unknown = repo.resolveCompanyByEmail('user@gmail.com');
      expect(unknown.name, equals('General / Job Seeker'));
      expect(unknown.isVerifiedEntity, isFalse);
    });

    test('UAE anonymous handle generator formats properly', () {
      final handle = AnonymityHelper.generateAnonymousNickname();
      expect(handle.contains('-'), isTrue);
      final parts = handle.split('-');
      expect(parts.length, equals(2));
      expect(int.tryParse(parts[1]), isNotNull);
    });
  });

  group('Majlis Widget Smoke Test', () {
    testWidgets('Renders MajlisApp brand and feed title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MajlisApp(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Blind'), findsOneWidget);
    });
  });
}
