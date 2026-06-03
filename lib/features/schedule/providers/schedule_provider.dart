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
    // Deserialize daysOfWeek: could be String array or integer array
    final rawDays = json['daysOfWeek'];
    List<int> parsedDays = [];
    if (rawDays is List) {
      parsedDays = rawDays.map((d) => int.tryParse(d.toString()) ?? 1).toList();
    }
    
    return InvisibleSchedule(
      id: json['id']?.toString() ?? '',
      daysOfWeek: parsedDays,
      startTime: json['startTime'] ?? '10:00',
      endTime: json['endTime'] ?? '18:00',
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
    fetchList();
  }

  Future<void> fetchList() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.scheduleList);
      final List? data = response.data['data'];
      if (mounted) {
        state = data != null ? data.map((json) => InvisibleSchedule.fromJson(json)).toList() : [];
      }
    } catch (e) {
      print('Failed to fetch schedules: $e');
    }
  }

  Future<bool> addSchedule(InvisibleSchedule schedule) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiEndpoints.scheduleSet, data: {
        'daysOfWeek': schedule.daysOfWeek,
        'startTime': schedule.startTime,
        'endTime': schedule.endTime,
        if (schedule.label != null) 'label': schedule.label,
      });
      
      final newScheduleData = response.data['data'];
      if (mounted && newScheduleData != null) {
        final newSchedule = InvisibleSchedule.fromJson(newScheduleData);
        state = [...state, newSchedule];
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add schedule: $e');
      return false;
    }
  }

  Future<void> removeSchedule(String id) async {
    final originalState = List<InvisibleSchedule>.from(state);
    state = state.where((s) => s.id != id).toList();

    try {
      final dio = ref.read(dioProvider);
      await dio.delete(ApiEndpoints.scheduleDelete(id));
    } catch (e) {
      print('Failed to delete schedule: $e');
      if (mounted) {
        state = originalState;
      }
    }
  }

  Future<void> toggleSchedule(String id) async {
    final updated = state.map((s) {
      if (s.id == id) {
        final newVal = !s.isActive;
        _updateScheduleOnServer(id, newVal);
        return s.copyWith(isActive: newVal);
      }
      return s;
    }).toList();
    
    state = updated;
  }

  Future<void> _updateScheduleOnServer(String id, bool isActive) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put(ApiEndpoints.scheduleUpdate(id), data: {
        'isActive': isActive,
      });
    } catch (e) {
      print('Failed to update schedule status on server: $e');
      // Refetch full list to reconcile state in case of network error
      fetchList();
    }
  }
}
