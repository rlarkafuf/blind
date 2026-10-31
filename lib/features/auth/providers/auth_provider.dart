import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/anonymity_helper.dart';
import '../../../models/anonymous_user.dart';
import '../../company/repositories/company_repository.dart';
import '../repositories/auth_repository.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final companyRepo = ref.watch(companyRepositoryProvider);
  return MockAuthRepository(companyRepository: companyRepo);
});

class AuthNotifier extends Notifier<AsyncValue<AnonymousUser?>> {
  @override
  AsyncValue<AnonymousUser?> build() {
    final companyRepo = ref.read(companyRepositoryProvider);
    final adnoc = companyRepo.resolveCompanyByEmail('engineer@adnoc.ae');
    final demoUser = AnonymousUser(
      id: 'demo-user-adnoc',
      emailHash: AnonymityHelper.hashEmail('engineer@adnoc.ae'),
      company: adnoc,
      nickname: 'Falcon-491',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    );
    return AsyncValue.data(demoUser);
  }

  Future<void> signInWithEmailOtp({
    required String email,
    required String otpCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.verifyOtpAndSignIn(email, otpCode);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInAsDemoCompany(String emailPrefix, String domain) async {
    state = const AsyncValue.loading();
    final email = '$emailPrefix@$domain';
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.verifyOtpAndSignIn(email, '123456');
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider =
    NotifierProvider<AuthNotifier, AsyncValue<AnonymousUser?>>(AuthNotifier.new);

final currentUserProvider = Provider<AnonymousUser?>((ref) {
  return ref.watch(authStateProvider).value;
});
