import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_button.dart';
import '../providers/settings_provider.dart';

class PaymentSimulationScreen extends ConsumerStatefulWidget {
  final String tierName;
  final String price;

  const PaymentSimulationScreen({
    super.key,
    required this.tierName,
    required this.price,
  });

  @override
  ConsumerState<PaymentSimulationScreen> createState() => _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState extends ConsumerState<PaymentSimulationScreen> {
  bool _isProcessing = false;
  bool _isSuccess = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Simulate network delay and payment gateway processing
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      // Call backend to update tier
      await ref.read(settingsProvider.notifier).upgradeSubscription(widget.tierName);
      
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });

      // Show success animation then pop
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully upgraded to ${widget.tierName} plan!'),
            backgroundColor: PhantomColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment failed. Please try again.'),
            backgroundColor: PhantomColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        backgroundColor: PhantomColors.bgDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PhantomColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: PhantomColors.success,
                  size: 40,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: PhantomColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Welcome to the ${widget.tierName} plan',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: PhantomColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Checkout',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: PhantomColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: PhantomColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PhantomColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PhantomColors.bgCardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PhantomColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Phantom ${widget.tierName}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: PhantomColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.price,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: PhantomColors.primaryStart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: PhantomColors.border, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Due Today',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PhantomColors.textSecondary,
                          ),
                        ),
                        Text(
                          widget.price,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: PhantomColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PhantomColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PhantomColors.warning.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: PhantomColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a simulated payment gateway. No real charges will be made.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: PhantomColors.warning,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PhantomButton(
                text: 'Pay Securely',
                onPressed: _processPayment,
                isLoading: _isProcessing,
                icon: Icons.lock_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
