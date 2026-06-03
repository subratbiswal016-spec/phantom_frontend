import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_card.dart';
import '../../../core/widgets/phantom_app_bar.dart';
import '../providers/call_log_provider.dart';

class CallLogScreen extends ConsumerWidget {
  const CallLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callLogs = ref.watch(callLogProvider);
    final blockedCount = callLogs.where((c) => c.isBlocked).length;
    final forwardedCount = callLogs.where((c) => !c.isBlocked).length;

    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      appBar: PhantomAppBar(
        title: 'Call Log',
        actions: [
          IconButton(
            onPressed: () {
              ref.read(callLogProvider.notifier).clearLog();
            },
            icon: const Icon(
              Icons.delete_sweep_rounded,
              color: PhantomColors.textTertiary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildStatChip(
                  Icons.block_rounded,
                  '$blockedCount Blocked',
                  PhantomColors.danger,
                ),
                const SizedBox(width: 10),
                _buildStatChip(
                  Icons.call_made_rounded,
                  '$forwardedCount Forwarded',
                  PhantomColors.success,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Call log list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(callLogProvider.notifier).loadLogs(),
              color: PhantomColors.primaryStart,
              backgroundColor: PhantomColors.bgCardLight,
              child: callLogs.isEmpty
                  ? CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: callLogs.length,
                      itemBuilder: (context, index) {
                        final entry = callLogs[index];
                        return _buildCallLogTile(context, entry, index);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallLogTile(BuildContext context, CallLogEntry entry, int index) {
    final timeStr = _formatTime(entry.timestamp);
    final isBlocked = entry.isBlocked;

    return PhantomCard(
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isBlocked ? PhantomColors.danger : PhantomColors.success)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBlocked
                  ? Icons.phone_disabled_rounded
                  : Icons.phone_forwarded_rounded,
              color: isBlocked ? PhantomColors.danger : PhantomColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Caller info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (entry.callerName.toLowerCase() == 'unknown' || entry.callerName.isEmpty)
                            ? entry.callerPhone
                            : entry.callerName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: PhantomColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (isBlocked
                                ? PhantomColors.danger
                                : PhantomColors.success)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBlocked ? 'Blocked' : 'VIP',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isBlocked
                              ? PhantomColors.danger
                              : PhantomColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (entry.callerName.toLowerCase() != 'unknown' && entry.callerName.isNotEmpty) ...[
                      Text(
                        entry.callerPhone,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: PhantomColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: GoogleFonts.inter(
                          color: PhantomColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: PhantomColors.textTertiary,
                      ),
                    ),
                    if (entry.duration != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: GoogleFonts.inter(
                          color: PhantomColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(entry.duration!),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: PhantomColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 80 * index)).fadeIn(duration: 300.ms).slideX(
          begin: 0.05,
          end: 0,
          duration: 300.ms,
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: PhantomColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_in_talk_rounded,
              size: 36,
              color: PhantomColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No calls yet',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PhantomColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calls will appear here when\nyou activate invisible mode',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: PhantomColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins}m ${secs}s';
  }
}
