import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) return;
    
    // Normalize format to start with +
    String formattedPhone = phone;
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+$formattedPhone';
    }

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).sendOtp(formattedPhone);
    setState(() => _isLoading = false);
    
    if (success) {
      setState(() {
        _otpSent = true;
      });
    } else {
      final error = ref.read(authProvider).error ?? 'Failed to send OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: PhantomColors.danger),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) return;

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).verifyOtp(
          otp,
          name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        );
    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      final error = ref.read(authProvider).error ?? 'Invalid OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: PhantomColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              PhantomColors.primaryStart.withValues(alpha: 0.08),
              PhantomColors.bgDark,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: PhantomColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: PhantomColors.primaryStart.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                    ),

                const SizedBox(height: 40),

                // Welcome text
                Center(
                  child: Text(
                    _otpSent ? 'Verify OTP' : 'Welcome Back',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: PhantomColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    _otpSent
                        ? 'Enter the 6-digit code sent to +91 ${_phoneController.text}'
                        : 'Sign in with your phone number',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: PhantomColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 48),

                if (!_otpSent) ...[
                  // Phone number input
                  Text(
                    'Phone Number',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: PhantomColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: PhantomColors.bgCardLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: PhantomColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: PhantomColors.border),
                            ),
                          ),
                          child: Text(
                            '+91',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: PhantomColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: PhantomColors.textPrimary,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter 10-digit number',
                              hintStyle: GoogleFonts.inter(
                                color: PhantomColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  PhantomButton(
                    text: 'Send OTP',
                    onPressed: _sendOtp,
                    isLoading: _isLoading,
                    icon: Icons.send_rounded,
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                ] else ...[
                  // OTP input
                  Text(
                    'Verification Code',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: PhantomColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: PhantomColors.textPrimary,
                      letterSpacing: 12,
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: '• • • • • •',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 28,
                        color: PhantomColors.textTertiary,
                        letterSpacing: 12,
                      ),
                      filled: true,
                      fillColor: PhantomColors.bgCardLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: PhantomColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: PhantomColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: PhantomColors.primaryStart,
                          width: 2,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),

                  // Resend OTP
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        });
                      },
                      child: Text(
                        'Change number / Resend OTP',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: PhantomColors.primaryStart,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  PhantomButton(
                    text: 'Verify & Login',
                    onPressed: _verifyOtp,
                    isLoading: _isLoading,
                    icon: Icons.verified_rounded,
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],

                const SizedBox(height: 40),

                // Terms
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: PhantomColors.textTertiary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
