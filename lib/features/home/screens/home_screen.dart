import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_card.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invisibleProvider);
    final isInvisible = state.isInvisible;

    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: isInvisible
                ? [
                    PhantomColors.primaryStart.withValues(alpha: 0.12),
                    PhantomColors.bgDark,
                  ]
                : [
                    PhantomColors.accent.withValues(alpha: 0.08),
                    PhantomColors.bgDark,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: PhantomColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.visibility_off_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'PHANTOM',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: PhantomColors.textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isInvisible
                            ? PhantomColors.primaryStart.withValues(alpha: 0.15)
                            : PhantomColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isInvisible
                              ? PhantomColors.primaryStart.withValues(alpha: 0.3)
                              : PhantomColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isInvisible
                                  ? PhantomColors.primaryStart
                                  : PhantomColors.success,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isInvisible ? 'Invisible' : 'Visible',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isInvisible
                                  ? PhantomColors.primaryStart
                                  : PhantomColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // The Big Toggle
              _buildToggleButton(isInvisible, state.isLoading),

              const SizedBox(height: 24),

              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isInvisible
                      ? 'You are Invisible'
                      : 'You are Visible',
                  key: ValueKey(isInvisible),
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: PhantomColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isInvisible
                      ? 'All non-VIP calls will hear "switched off"'
                      : 'Everyone can reach you right now',
                  key: ValueKey('desc_$isInvisible'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: PhantomColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 1),

              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: PhantomStatCard(
                        label: 'Blocked Today',
                        value: '${state.blockedToday}',
                        icon: Icons.block_rounded,
                        iconColor: PhantomColors.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PhantomStatCard(
                        label: 'VIP Contacts',
                        value: '${state.vipCount}',
                        icon: Icons.star_rounded,
                        iconColor: PhantomColors.warning,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 500.ms,
                  ),

              const SizedBox(height: 16),

              // Recent blocked call teaser
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PhantomCard(
                  onTap: () {},
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: PhantomColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.phone_missed_rounded,
                          color: PhantomColors.danger,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last blocked call',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: PhantomColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+91 98765 43210 • 2 min ago',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: PhantomColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: PhantomColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool isInvisible, bool isLoading) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              HapticFeedback.heavyImpact();
              ref.read(invisibleProvider.notifier).toggle();
            },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = isInvisible ? _pulseController.value : 0.0;
          final glowValue = _glowController.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings (only when invisible)
              if (isInvisible) ...[
                _buildPulseRing(200, pulseValue, 0.06),
                _buildPulseRing(170, pulseValue * 0.8, 0.10),
                _buildPulseRing(145, pulseValue * 0.6, 0.14),
              ],

              // Main button
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isInvisible
                      ? PhantomColors.invisibleGradient
                      : PhantomColors.visibleGradient,
                  boxShadow: [
                    BoxShadow(
                      color: (isInvisible
                              ? PhantomColors.primaryStart
                              : PhantomColors.accent)
                          .withValues(alpha: 0.3 + (glowValue * 0.2)),
                      blurRadius: 30 + (glowValue * 20),
                      spreadRadius: 5 + (glowValue * 5),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              isInvisible
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              key: ValueKey(isInvisible),
                              size: 44,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isInvisible ? 'ON' : 'OFF',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    ).animate().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildPulseRing(double size, double animValue, double opacity) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: size + (animValue * 20),
      height: size + (animValue * 20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: PhantomColors.primaryStart.withValues(alpha: opacity * (1 - animValue)),
          width: 1.5,
        ),
      ),
    );
  }
}
