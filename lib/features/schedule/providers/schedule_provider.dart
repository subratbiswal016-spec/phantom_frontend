import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvisibleSchedule {
  final String id;
  final List<int> daysOfWeek; // 1 = Mon, 7 = Sun
  final String startTime; // "HH:mm"
  final String endTime;
  final bool isActive;
  final String? label;

  InvisibleSchedule({
    required this.id,
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
    this.label,
  });

  InvisibleSchedule copyWith({
    List<int>? daysOfWeek,
    String? startTime,
    String? endTime,
    bool? isActive,
    String? label,
  }) {
    return InvisibleSchedule(
      id: id,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
    );
  }

  String get daysText {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.length == 5 &&
        daysOfWeek.every((d) => d >= 1 && d <= 5)) {
      return 'Weekdays';
    }
    if (daysOfWeek.length == 2 &&
        daysOfWeek.contains(6) &&
        daysOfWeek.contains(7)) {
      return 'Weekends';
    }
    return daysOfWeek.map((d) => dayNames[d - 1]).join(', ');
  }
}

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<InvisibleSchedule>>((ref) {
  return ScheduleNotifier();
});

class ScheduleNotifier extends StateNotifier<List<InvisibleSchedule>> {
  ScheduleNotifier()
      : super([
          InvisibleSchedule(
            id: '1',
            daysOfWeek: [7],
            startTime: '10:00',
            endTime: '18:00',
            isActive: true,
            label: 'Sunday Rest',
          ),
          InvisibleSchedule(
            id: '2',
            daysOfWeek: [1, 2, 3, 4, 5],
            startTime: '22:00',
            endTime: '07:00',
            isActive: true,
            label: 'Night Sleep',
          ),
          InvisibleSchedule(
            id: '3',
            daysOfWeek: [6],
            startTime: '14:00',
            endTime: '17:00',
            isActive: false,
            label: 'Saturday Nap',
          ),
        ]);

  void addSchedule(InvisibleSchedule schedule) {
    state = [...state, schedule];
  }

  void removeSchedule(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void toggleSchedule(String id) {
    state = state.map((s) {
      if (s.id == id) return s.copyWith(isActive: !s.isActive);
      return s;
    }).toList();
  }
}
