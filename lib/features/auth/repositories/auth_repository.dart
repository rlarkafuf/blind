import 'dart:async';
import '../../../core/utils/anonymity_helper.dart';
import '../../../models/anonymous_user.dart';
import '../../../models/company.dart';
import '../../company/repositories/company_repository.dart';

abstract class AuthRepository {
  Future<Company> previewCompany(String email);
  Future<void> sendOtp(String email);
  Future<AnonymousUser> verifyOtpAndSignIn(String email, String otpCode);
  Future<AnonymousUser?> getCurrentUser();
  Future<void> signOut();
}

/// Mock Auth Repository for development, offline previews, and unit testing.
/// Strictly enforces Zero-PII: plaintext emails are hashed immediately and discarded.
class MockAuthRepository implements AuthRepository {
  final CompanyRepository _companyRepository;
  AnonymousUser? _currentUser;

  MockAuthRepository({CompanyRepository? companyRepository})
      : _companyRepository = companyRepository ?? CompanyRepository();

  @override
  Future<Company> previewCompany(String email) async {
    return _companyRepository.resolveCompanyByEmail(email);
  }

  @override
  Future<void> sendOtp(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<AnonymousUser> verifyOtpAndSignIn(String email, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Zero-PII: plain email is converted to one-way SHA-256 hash
    final emailHash = AnonymityHelper.hashEmail(email);
    final company = _companyRepository.resolveCompanyByEmail(email);
    final nickname = AnonymityHelper.generateAnonymousNickname();

    final user = AnonymousUser(
      id: 'anon-user-${DateTime.now().millisecondsSinceEpoch}',
      emailHash: emailHash,
      company: company,
      nickname: nickname,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<AnonymousUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  /// Preset demo user helper for fast previewing in emulator/web
  void setPresetUser(AnonymousUser user) {
    _currentUser = user;
  }
}
