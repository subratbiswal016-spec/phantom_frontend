import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class CallLogEntry {
  final String id;
  final String callerName;
  final String callerPhone;
  final String status; // 'blocked' or 'forwarded'
  final DateTime timestamp;
  final int? duration; // in seconds, for forwarded calls

  CallLogEntry({
    required this.id,
    required this.callerName,
    required this.callerPhone,
    required this.status,
    required this.timestamp,
    this.duration,
  });

  bool get isBlocked => status == 'blocked';

  factory CallLogEntry.fromJson(Map<String, dynamic> json) {
    return CallLogEntry(
      id: json['id']?.toString() ?? '',
      callerName: json['callerName'] ?? json['caller_name'] ?? 'Unknown',
      callerPhone: json['callerPhone'] ?? json['caller_phone'] ?? '',
      status: json['status'] ?? 'blocked',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      duration: json['duration'],
    );
  }
}

final callLogProvider = StateNotifierProvider<CallLogNotifier, List<CallLogEntry>>((ref) {
  return CallLogNotifier(ref);
});

class CallLogNotifier extends StateNotifier<List<CallLogEntry>> {
  final Ref ref;

  CallLogNotifier(this.ref) : super([]) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.callLog);
      final List<dynamic> data = response.data['data'] ?? [];
      state = data.map((json) => CallLogEntry.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load call logs: $e');
    }
  }

  void clearLog() {
    // Note: Backend might need a clear logs endpoint, but for now we clear local
    state = [];
  }

  void addEntry(CallLogEntry entry) {
    state = [entry, ...state];
  }
}
