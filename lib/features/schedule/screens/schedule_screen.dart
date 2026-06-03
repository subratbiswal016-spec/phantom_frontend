import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_card.dart';
import '../../../core/widgets/phantom_app_bar.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      appBar: const PhantomAppBar(title: 'Auto Schedule'),
      body: Column(
        children: [
          // Info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: PhantomCard(
              gradient: LinearGradient(
                colors: [
                  PhantomColors.primaryStart.withValues(alpha: 0.15),
                  PhantomColors.primaryEnd.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: PhantomColors.primaryStart.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PhantomColors.primaryStart.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: PhantomColors.primaryStart,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto Invisible',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: PhantomColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Set times when Phantom activates automatically',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: PhantomColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Schedule list
          Expanded(
            child: schedules.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return _buildScheduleTile(context, ref, schedule, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: PhantomColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PhantomColors.primaryStart.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddScheduleSheet(context, ref),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildScheduleTile(
      BuildContext context, WidgetRef ref, InvisibleSchedule schedule, int index) {
    final isActive = schedule.isActive;

    return Dismissible(
      key: ValueKey(schedule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: PhantomColors.dangerGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(scheduleProvider.notifier).removeSchedule(schedule.id);
      },
      child: PhantomCard(
        child: Row(
          children: [
            // Time display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? PhantomColors.primaryStart.withValues(alpha: 0.12)
                    : PhantomColors.bgElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    schedule.startTime,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? PhantomColors.primaryStart
                          : PhantomColors.textTertiary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 12,
                    color: isActive
                        ? PhantomColors.primaryStart.withValues(alpha: 0.3)
                        : PhantomColors.textTertiary.withValues(alpha: 0.3),
                  ),
                  Text(
                    schedule.endTime,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? PhantomColors.accent
                          : PhantomColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Schedule info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (schedule.label != null)
                    Text(
                      schedule.label!,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? PhantomColors.textPrimary
                            : PhantomColors.textTertiary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.daysText,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: PhantomColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Day dots
                  Row(
                    children: List.generate(7, (i) {
                      final dayNum = i + 1;
                      final isSelected = schedule.daysOfWeek.contains(dayNum);
                      return Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: isSelected && isActive
                              ? PhantomColors.primaryStart.withValues(alpha: 0.2)
                              : PhantomColors.bgElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected && isActive
                                  ? PhantomColors.primaryStart
                                  : PhantomColors.textTertiary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Toggle switch
            Switch(
              value: isActive,
              onChanged: (_) {
                ref
                    .read(scheduleProvider.notifier)
                    .toggleSchedule(schedule.id);
              },
              activeColor: PhantomColors.primaryStart,
              activeTrackColor: PhantomColors.primaryStart.withValues(alpha: 0.3),
              inactiveThumbColor: PhantomColors.textTertiary,
              inactiveTrackColor: PhantomColors.bgElevated,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn(duration: 300.ms).slideX(
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
              color: PhantomColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 36,
              color: PhantomColors.warning,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No schedules yet',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PhantomColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set times for Phantom to\nactivate automatically',
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

  void _showAddScheduleSheet(BuildContext context, WidgetRef ref) {
    final labelController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    final selectedDays = <int>{7}; // Default: Sunday

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
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
                      'New Schedule',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: PhantomColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Label
                    TextField(
                      controller: labelController,
                      style: GoogleFonts.inter(color: PhantomColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Schedule name (e.g., Movie Night)',
                        prefixIcon: const Icon(Icons.label_rounded,
                            color: PhantomColors.textTertiary),
                        filled: true,
                        fillColor: PhantomColors.bgCardLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: PhantomColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: PhantomColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Day selector
                    Text(
                      'Repeat on',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: PhantomColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final dayNum = i + 1;
                        final isSelected = selectedDays.contains(dayNum);
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                selectedDays.remove(dayNum);
                              } else {
                                selectedDays.add(dayNum);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? PhantomColors.primaryStart
                                  : PhantomColors.bgCardLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? PhantomColors.primaryStart
                                    : PhantomColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : PhantomColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Time pickers
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            'Start Time',
                            startTime,
                            (picked) {
                              setSheetState(() => startTime = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimePicker(
                            context,
                            'End Time',
                            endTime,
                            (picked) {
                              setSheetState(() => endTime = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Add button
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
                              if (selectedDays.isNotEmpty) {
                                ref
                                    .read(scheduleProvider.notifier)
                                    .addSchedule(InvisibleSchedule(
                                      id: DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString(),
                                      daysOfWeek: selectedDays.toList()..sort(),
                                      startTime:
                                          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                                      endTime:
                                          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                                      label: labelController.text.isNotEmpty
                                          ? labelController.text
                                          : null,
                                    ));
                                Navigator.pop(context);
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.schedule_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create Schedule',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
      },
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: PhantomColors.primaryStart,
                  surface: PhantomColors.bgCard,
                  onSurface: PhantomColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PhantomColors.bgCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PhantomColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: PhantomColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: PhantomColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
