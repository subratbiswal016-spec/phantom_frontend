import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

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

  factory InvisibleSchedule.fromJson(Map<String, dynamic> json) {
    return InvisibleSchedule(
      id: json['id']?.toString() ?? '',
      daysOfWeek: () {
        final d = json['daysOfWeek'];
        if (d is String) {
          try {
            final decoded = jsonDecode(d) as List;
            return decoded.map((e) => e as int).toList();
          } catch (_) {
            return <int>[];
          }
        } else if (d is List) {
          return d.map((e) => e as int).toList();
        }
        return <int>[];
      }(),
      startTime: json['startTime'] ?? '00:00',
      endTime: json['endTime'] ?? '00:00',
      isActive: json['isActive'] ?? true,
      label: json['label'],
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
  return ScheduleNotifier(ref);
});

class ScheduleNotifier extends StateNotifier<List<InvisibleSchedule>> {
  final Ref ref;

  ScheduleNotifier(this.ref) : super([]) {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.scheduleList);
      final List<dynamic> data = response.data['data'] ?? [];
      state = data.map((json) => InvisibleSchedule.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load schedules: $e');
    }
  }

  Future<void> addSchedule(String startTime, String endTime, List<int> days, String label) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiEndpoints.scheduleSet, data: {
        'startTime': startTime,
        'endTime': endTime,
        'daysOfWeek': days,
        'label': label,
      });
      await loadSchedules();
    } catch (e) {
      print('Failed to add schedule: $e');
    }
  }

  Future<void> removeSchedule(String id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete(ApiEndpoints.scheduleDelete(id));
      state = state.where((s) => s.id != id).toList();
    } catch (e) {
      print('Failed to remove schedule: $e');
    }
  }

  Future<void> toggleSchedule(String id) async {
    final schedule = state.firstWhere((s) => s.id == id);
    final isActive = !schedule.isActive;
    
    // Optimistic update
    state = state.map((s) {
      if (s.id == id) return s.copyWith(isActive: isActive);
      return s;
    }).toList();

    try {
      final dio = ref.read(dioProvider);
      await dio.put(ApiEndpoints.scheduleUpdate(id), data: {
        'isActive': isActive,
      });
    } catch (e) {
      print('Failed to toggle schedule: $e');
      // Revert on failure
      state = state.map((s) {
        if (s.id == id) return s.copyWith(isActive: !isActive);
        return s;
      }).toList();
    }
  }
}
