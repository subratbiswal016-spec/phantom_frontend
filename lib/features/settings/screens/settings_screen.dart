import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_card.dart';
import '../../../core/widgets/phantom_app_bar.dart';
import '../../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      appBar: const PhantomAppBar(title: 'Settings'),
      body: RefreshIndicator(
        onRefresh: () => ref.read(settingsProvider.notifier).loadSettings(),
        color: PhantomColors.primaryStart,
        backgroundColor: PhantomColors.bgCardLight,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: 8),

            // Profile card
            PhantomCard(
              gradient: LinearGradient(
                colors: [
                  PhantomColors.primaryStart.withValues(alpha: 0.12),
                  PhantomColors.primaryEnd.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: PhantomColors.primaryStart.withValues(alpha: 0.3),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: PhantomColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        settingsState.name.isNotEmpty ? settingsState.name[0].toUpperCase() : 'U',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settingsState.name.isNotEmpty ? settingsState.name : 'Unknown User',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: PhantomColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          settingsState.phone.isNotEmpty ? settingsState.phone : 'No Phone Linked',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: PhantomColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: PhantomColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      settingsState.plan.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            Consumer(
              builder: (context, ref, child) {
                final settingsState = ref.watch(settingsProvider);
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subscription section
                    _buildSectionTitle('Subscription'),
                    const SizedBox(height: 8),
                    _buildSubscriptionCard(context, ref, settingsState.plan),
                    const SizedBox(height: 24),

                    // Settings sections
                    _buildSectionTitle('Invisible Mode'),
                    const SizedBox(height: 8),
                    _buildSettingsTile(
                      icon: Icons.message_rounded,
                      iconColor: PhantomColors.accent,
                      title: 'Custom Message',
                      subtitle: settingsState.customMessage.length > 25 
                          ? '${settingsState.customMessage.substring(0, 25)}...' 
                          : settingsState.customMessage,
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: PhantomColors.textTertiary,
                      ),
                      onTap: () => _showCustomMessageSheet(context, ref),
                    ),
                    _buildSettingsTile(
                      icon: Icons.phone_android_rounded,
                      iconColor: PhantomColors.success,
                      title: 'Virtual Number',
                      subtitle: '+91 80000 12345',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PhantomColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: PhantomColors.success,
                          ),
                        ),
                      ),
                    ),

                    _buildSectionTitle('Call Blocking'),
                    const SizedBox(height: 8),
                    _buildSettingsTile(
                      icon: Icons.contact_phone_rounded,
                      iconColor: PhantomColors.danger,
                      title: 'Block Unknown Numbers',
                      subtitle: settingsState.isSyncing 
                          ? 'Syncing contacts...' 
                          : 'Block callers not in your contacts',
                      trailing: settingsState.isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: PhantomColors.danger,
                              ),
                            )
                          : Switch(
                              value: settingsState.blockUnknown,
                              onChanged: (_) {
                                ref.read(settingsProvider.notifier).toggleBlockUnknown();
                              },
                              activeColor: PhantomColors.danger,
                              activeTrackColor: PhantomColors.danger.withValues(alpha: 0.3),
                              inactiveThumbColor: PhantomColors.textTertiary,
                              inactiveTrackColor: PhantomColors.bgElevated,
                            ),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 8),
                    _buildSettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: PhantomColors.warning,
                      title: 'Push Notifications',
                      subtitle: 'Get notified when VIPs call',
                      trailing: Switch(
                        value: settingsState.pushNotifications,
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).togglePushNotifications(val);
                        },
                        activeColor: PhantomColors.primaryStart,
                        activeTrackColor:
                            PhantomColors.primaryStart.withValues(alpha: 0.3),
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.notifications_active_rounded,
                      iconColor: PhantomColors.accent,
                      title: 'Blocked Call Alerts',
                      subtitle: 'Summary of blocked calls',
                      trailing: Switch(
                        value: settingsState.blockedCallAlerts,
                        onChanged: (val) {
                          ref.read(settingsProvider.notifier).toggleBlockedCallAlerts(val);
                        },
                        activeColor: PhantomColors.accent,
                        activeTrackColor: PhantomColors.accent.withValues(alpha: 0.3),
                        inactiveThumbColor: PhantomColors.textTertiary,
                        inactiveTrackColor: PhantomColors.bgElevated,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Account'),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.privacy_tip_rounded,
              iconColor: PhantomColors.primaryStart,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: PhantomColors.textTertiary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy: Your data is secure and encrypted.')),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.help_rounded,
              iconColor: PhantomColors.accent,
              title: 'Help & Support',
              subtitle: 'FAQ and contact us',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: PhantomColors.textTertiary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support: Contact us at support@phantom.app')),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.info_rounded,
              iconColor: PhantomColors.textSecondary,
              title: 'About',
              subtitle: 'Version 1.0.0',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: PhantomColors.textTertiary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phantom App v1.0.0 - Built with Flutter')),
                );
              },
            ),

            const SizedBox(height: 16),

            // Logout
            Consumer(
              builder: (context, ref, child) {
                return PhantomCard(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('auth_token');
                    if (context.mounted) context.go('/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        color: PhantomColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: PhantomColors.danger,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: PhantomColors.textTertiary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return PhantomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: PhantomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: PhantomColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref, String currentPlan) {
    final lowerCurrentPlan = currentPlan.toLowerCase();
    
    return PhantomCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Plans grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPlanRow(
                  'Free', 
                  '₹0/mo', 
                  '1 VIP • 20 Blocked Calls', 
                  lowerCurrentPlan == 'free',
                  () => _confirmUpgrade(context, ref, 'free'),
                ),
                const Divider(color: PhantomColors.border, height: 1),
                _buildPlanRow(
                  'Basic', 
                  '₹${AppConstants.basicPrice}/mo', 
                  '10 VIPs • 100 Blocked Calls', 
                  lowerCurrentPlan == 'basic',
                  () => _confirmUpgrade(context, ref, 'basic'),
                ),
                const Divider(color: PhantomColors.border, height: 1),
                _buildPlanRow(
                  'Pro', 
                  '₹${AppConstants.proPrice}/mo', 
                  'Unlimited VIPs • Unlimited Blocks', 
                  lowerCurrentPlan == 'pro',
                  () => _confirmUpgrade(context, ref, 'pro'),
                ),
                const Divider(color: PhantomColors.border, height: 1),
                _buildPlanRow(
                  'Business', 
                  '₹${AppConstants.businessPrice}/mo', 
                  'Team Accounts • Priority Support', 
                  lowerCurrentPlan == 'business',
                  () => _confirmUpgrade(context, ref, 'business'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmUpgrade(BuildContext context, WidgetRef ref, String planName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PhantomColors.bgCard,
        title: Text(
          'Change Plan',
          style: GoogleFonts.outfit(color: PhantomColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Do you want to switch your plan to ${planName.toUpperCase()}?',
          style: GoogleFonts.inter(color: PhantomColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: PhantomColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PhantomColors.primaryStart,
            ),
            onPressed: () async {
              Navigator.pop(context);
              _showPaymentSheet(context, ref, planName);
            },
            child: Text('Confirm', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, WidgetRef ref, String planName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        bool isProcessing = false;
        bool isRequestSent = false;
        final upiController = TextEditingController();
        String? paymentError;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: PhantomColors.bgCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: PhantomColors.border),
                  left: BorderSide(color: PhantomColors.border),
                  right: BorderSide(color: PhantomColors.border),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: PhantomColors.bgElevated,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        isRequestSent ? 'Approve Payment' : 'UPI Payment',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: PhantomColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRequestSent
                            ? 'Check your UPI app to complete the purchase'
                            : 'Enter your UPI ID to request a payment for ${planName.toUpperCase()}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: PhantomColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (!isRequestSent) ...[
                        Text(
                          'UPI ID / VPA',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: PhantomColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: upiController,
                          style: GoogleFonts.inter(color: PhantomColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'username@upi',
                            filled: true,
                            fillColor: PhantomColors.bgCardLight,
                            prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: PhantomColors.primaryStart),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PhantomColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PhantomColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (paymentError != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              paymentError!,
                              style: GoogleFonts.inter(
                                color: PhantomColors.danger,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],

                        // Pay Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isProcessing ? null : PhantomColors.primaryGradient,
                              color: isProcessing ? PhantomColors.bgCardLight : null,
                              borderRadius: BorderRadius.circular(14),
                              border: isProcessing ? Border.all(color: PhantomColors.border) : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isProcessing
                                    ? null
                                    : () {
                                        if (upiController.text.isEmpty || !upiController.text.contains('@')) {
                                          setSheetState(() => paymentError = 'Please enter a valid UPI ID');
                                          return;
                                        }

                                        setSheetState(() {
                                          isProcessing = true;
                                          paymentError = null;
                                        });

                                        // Simulate sending UPI Request
                                        Future.delayed(const Duration(seconds: 2), () {
                                          setSheetState(() {
                                            isProcessing = false;
                                            isRequestSent = true;
                                          });

                                          // Simulate checking/approving payment after 4 seconds
                                          Future.delayed(const Duration(seconds: 4), () async {
                                            if (!context.mounted) return;
                                            setSheetState(() {
                                              isProcessing = true;
                                            });

                                            try {
                                              await ref.read(settingsProvider.notifier).upgradeSubscription(planName);
                                              if (context.mounted) {
                                                Navigator.pop(context); // Close bottom sheet
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Payment Approved! Switched to ${planName.toUpperCase()} plan!'),
                                                    backgroundColor: PhantomColors.success,
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                setSheetState(() {
                                                  isRequestSent = false;
                                                  isProcessing = false;
                                                  paymentError = 'Failed to activate plan. Please try again.';
                                                });
                                              }
                                            }
                                          });
                                        });
                                      },
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: isProcessing
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: PhantomColors.primaryStart,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Send Payment Request',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Request Sent State
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Column(
                              children: [
                                const SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: CircularProgressIndicator(
                                    color: PhantomColors.primaryStart,
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Checking for approval...',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: PhantomColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      color: PhantomColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(text: 'We\'ve sent a payment request to '),
                                      TextSpan(
                                        text: upiController.text,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: PhantomColors.primaryStart,
                                        ),
                                      ),
                                      const TextSpan(text: '.\nPlease open your UPI client app to approve it.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlanRow(String name, String price, String feature, bool isCurrent, VoidCallback onTap) {
    return InkWell(
      onTap: isCurrent ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? PhantomColors.primaryStart
                    : PhantomColors.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? PhantomColors.primaryStart
                              : PhantomColors.textPrimary,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: PhantomColors.primaryStart.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CURRENT',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: PhantomColors.primaryStart,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    feature,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: PhantomColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PhantomColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomMessageSheet(BuildContext context, WidgetRef ref) {
    final settingsState = ref.read(settingsProvider);
    final messageController = TextEditingController(
      text: settingsState.customMessage,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: PhantomColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: PhantomColors.border),
              left: BorderSide(color: PhantomColors.border),
              right: BorderSide(color: PhantomColors.border),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PhantomColors.bgElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Custom Message',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: PhantomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This message will be played to blocked callers',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: PhantomColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  style: GoogleFonts.inter(color: PhantomColors.textPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: PhantomColors.bgCardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PhantomColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PhantomColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: PhantomColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          ref.read(settingsProvider.notifier).updateCustomMessage(messageController.text);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: Text(
                            'Save Message',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
