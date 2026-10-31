import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/company.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  Company? _detectedCompany;
  bool _otpSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text;
    final companyRepo = ref.read(companyRepositoryProvider);
    final company = companyRepo.resolveCompanyByEmail(email);

    if (company.isVerifiedEntity) {
      setState(() {
        _detectedCompany = company;
      });
    } else {
      if (_detectedCompany != null) {
        setState(() {
          _detectedCompany = null;
        });
      }
    }
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid work email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendOtp(email);
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP code. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length < 4) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit OTP code received.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).signInWithEmailOtp(
            email: email,
            otpCode: otp,
          );
      if (mounted) {
        context.go('/feed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP code. Please check and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleQuickDemoLogin(String emailPrefix, String domain) async {
    setState(() {
      _isLoading = true;
    });
    await ref.read(authStateProvider.notifier).signInAsDemoCompany(emailPrefix, domain);
    if (mounted) {
      context.go('/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Brand Header
                  _buildHeader(),
                  const SizedBox(height: 28),

                  // Zero-PII Security Assurance Card
                  _buildZeroPiiBanner(),
                  const SizedBox(height: 24),

                  // Verification Card
                  _buildVerificationCard(),
                  const SizedBox(height: 24),

                  // Quick Demo Switcher Section
                  _buildDemoQuickLogins(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.uaeEmerald, AppColors.surfaceElevated],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.uaeEmerald.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.uaeEmerald.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'م',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Majlis',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.uaeEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.uaeEmerald.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'مجلس',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.uaeEmerald,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'UAE Professional Anonymous Community',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildZeroPiiBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.uaeEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.uaeEmerald,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strict Zero-PII Guarantee',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your work email is never stored in plaintext. It is irreversibly converted into a SHA-256 salted hash to protect your absolute anonymity.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _otpSent ? 'Enter 6-Digit OTP Code' : 'Verify Workplace Domain',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _otpSent
                  ? 'We sent a verification code to ${_emailController.text}'
                  : 'Enter your UAE enterprise or ministry email to unlock your verified company badge.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            // Email Input
            TextField(
              controller: _emailController,
              enabled: !_otpSent && !_isLoading,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Workplace Email',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                hintText: 'e.g. yourname@adnoc.ae',
                prefixIcon: const Icon(Icons.business_center_outlined, color: AppColors.textMuted),
                suffixIcon: _detectedCompany != null
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.uaeEmerald)
                    : null,
              ),
            ),

            // Realtime Detected Badge Preview
            if (_detectedCompany != null && !_otpSent) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _detectedCompany!.brandColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _detectedCompany!.brandColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: _detectedCompany!.brandColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verified Badge: [${_detectedCompany!.name} · ${_detectedCompany!.industry}]',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _detectedCompany!.brandColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // OTP Input (if sent)
            if (_otpSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  labelText: '6-Digit OTP Code',
                  hintText: '123456',
                  prefixIcon: Icon(Icons.lock_clock_outlined, color: AppColors.textMuted),
                ),
              ),
            ],

            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],

            const SizedBox(height: 20),

            // Action Button
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_otpSent ? _handleVerifyOtp : _handleSendOtp),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_otpSent ? 'Verify & Enter Majlis' : 'Send Verification OTP'),
            ),

            if (_otpSent) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                child: const Text(
                  'Change email address',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoQuickLogins() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'QUICK DEMO PROFILES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildDemoChip('ADNOC', 'lead', 'adnoc.ae', const Color(0xFF0072CE)),
            _buildDemoChip('Emirates Airline', 'captain', 'emirates.com', const Color(0xFFD71921)),
            _buildDemoChip('e& (Etisalat)', 'ai_lead', 'eand.com', const Color(0xFF71B32A)),
            _buildDemoChip('ENEC Nuclear', 'physicist', 'enec.gov.ae', const Color(0xFF007A33)),
            _buildDemoChip('Mubadala', 'analyst', 'mubadala.ae', const Color(0xFF007C92)),
            _buildDemoChip('Careem', 'swe', 'careem.com', const Color(0xFF00B140)),
          ],
        ),
      ],
    );
  }

  Widget _buildDemoChip(String name, String prefix, String domain, Color color) {
    return ActionChip(
      avatar: CircleAvatar(
        radius: 6,
        backgroundColor: color,
      ),
      label: Text(
        name,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppColors.surfaceElevated,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      onPressed: _isLoading ? null : () => _handleQuickDemoLogin(prefix, domain),
    );
  }
}
