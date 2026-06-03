import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_card.dart';
import '../../../core/widgets/phantom_app_bar.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'payment_simulation_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      appBar: const PhantomAppBar(title: 'Settings'),
      body: RefreshIndicator(
        color: PhantomColors.primaryStart,
        backgroundColor: PhantomColors.bgElevated,
        onRefresh: () async {
          await ref.read(settingsProvider.notifier).loadSettings();
        },
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
                        'S',
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
                          'Subrat Biswal',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: PhantomColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+91 98765 43210',
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
                      'PRO',
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

            // Subscription section
            _buildSectionTitle('Subscription'),
            const SizedBox(height: 16),
            _buildSubscriptionCard(context, ref),
            const SizedBox(height: 32),

            // Settings sections
            _buildSectionTitle('Invisible Mode'),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.message_rounded,
              iconColor: PhantomColors.accent,
              title: 'Custom Message',
              subtitle: 'Set what callers hear',
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: PhantomColors.textTertiary,
              ),
              onTap: () => _showCustomMessageSheet(context),
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
            Consumer(
              builder: (context, ref, child) {
                final settingsState = ref.watch(settingsProvider);
                
                return Column(
                  children: [
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
                    _buildSettingsTile(
                      icon: Icons.settings_phone_rounded,
                      iconColor: PhantomColors.primaryStart,
                      title: 'Direct SIM Call Blocking',
                      subtitle: 'Block calls on physical SIM directly',
                      trailing: Switch(
                        value: settingsState.blockDirectCalls,
                        onChanged: (_) {
                          ref.read(settingsProvider.notifier).toggleBlockDirectCalls();
                        },
                        activeColor: PhantomColors.primaryStart,
                        activeTrackColor: PhantomColors.primaryStart.withValues(alpha: 0.3),
                        inactiveThumbColor: PhantomColors.textTertiary,
                        inactiveTrackColor: PhantomColors.bgElevated,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Notifications'),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final settingsState = ref.watch(settingsProvider);
                return Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: PhantomColors.warning,
                      title: 'Push Notifications',
                      subtitle: 'Get notified when VIPs call',
                      trailing: Switch(
                        value: settingsState.pushNotifications,
                        onChanged: (_) {
                          ref.read(settingsProvider.notifier).togglePushNotifications();
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
                        onChanged: (_) {
                          ref.read(settingsProvider.notifier).toggleBlockedCallAlerts();
                        },
                        activeColor: PhantomColors.accent,
                        activeTrackColor:
                            PhantomColors.accent.withValues(alpha: 0.3),
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
              onTap: () => _showPrivacyPolicy(context),
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
              onTap: () => _showHelpSupport(context),
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
              onTap: () => _showAbout(context),
            ),

            const SizedBox(height: 16),

            // Logout
            PhantomCard(
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
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

  Widget _buildSubscriptionCard(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final currentTier = state.subscriptionTier;

    return PhantomCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Plans grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPlanRow(context, 'Free', '₹0', '3 VIPs', currentTier == 'free'),
                const Divider(color: PhantomColors.border, height: 1),
                _buildPlanRow(context, 'Basic', '₹${AppConstants.basicPrice}', '10 VIPs + Schedule', currentTier == 'basic'),
                const Divider(color: PhantomColors.border, height: 1),
                _buildPlanRow(context, 'Pro', '₹${AppConstants.proPrice}', 'Unlimited + Custom Msg', currentTier == 'pro'),
                const Divider(color: PhantomColors.border, height: 1),
                _buildPlanRow(context, 'Business', '₹${AppConstants.businessPrice}', 'Team Accounts', currentTier == 'business'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRow(BuildContext context, String name, String price, String feature, bool isCurrent) {
    return InkWell(
      onTap: isCurrent ? null : () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentSimulationScreen(
              tierName: name,
              price: '$price/mo',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
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

  void _showCustomMessageSheet(BuildContext context) {
    final messageController = TextEditingController(
      text: 'The number you are trying to reach is currently switched off.',
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
                        onTap: () => Navigator.pop(context),
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

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: PhantomColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: PhantomColors.border)),
        ),
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
            Row(
              children: [
                const Icon(Icons.privacy_tip_rounded, color: PhantomColors.primaryStart, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Privacy Policy',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: PhantomColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your privacy is our priority. Phantom does not store, upload, or sell your contacts or personal call details to third parties.',
              style: GoogleFonts.inter(fontSize: 14, color: PhantomColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              '• Contact Sync: We process contact details locally and only upload hashed values for VIP lookups.\n• Audio & Calls: No audio or actual call contents are recorded or intercepted by Phantom servers.\n• Logs: Temporary logs are cleared weekly.',
              style: GoogleFonts.inter(fontSize: 13, color: PhantomColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PhantomColors.bgElevated,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Close', style: GoogleFonts.inter(color: PhantomColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: PhantomColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: PhantomColors.border)),
        ),
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
            Row(
              children: [
                const Icon(Icons.help_rounded, color: PhantomColors.accent, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Help & Support',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: PhantomColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Frequently Asked Questions:',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: PhantomColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Q: How does Invisible Mode work?\nA: When activated, we route calls to a dummy number that returns a "switched off" tone, bypassing all except VIPs.\n\nQ: How can I contact support?\nA: Reach out to us at support@phantom.app or raise a ticket.',
              style: GoogleFonts.inter(fontSize: 13, color: PhantomColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PhantomColors.bgElevated,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Got It', style: GoogleFonts.inter(color: PhantomColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: PhantomColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: PhantomColors.border)),
        ),
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
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: PhantomColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.visibility_off_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Phantom',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: PhantomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (Build 26)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: PhantomColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© 2026 Phantom Labs Inc. All rights reserved.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: PhantomColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PhantomColors.bgElevated,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Close', style: GoogleFonts.inter(color: PhantomColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
