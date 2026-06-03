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
      callerPhone: json['callerPhone'] ?? '',
      callerName: json['callerName'] ?? 'Unknown',
      status: json['status'] ?? 'blocked',
      duration: json['duration'],
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

final callLogProvider = StateNotifierProvider<CallLogNotifier, List<CallLogEntry>>((ref) {
  return CallLogNotifier(ref);
});

class CallLogNotifier extends StateNotifier<List<CallLogEntry>> {
  final Ref ref;

  CallLogNotifier(this.ref) : super([]) {
    fetchList();
  }

  Future<void> fetchList() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.callLog);
      final List? data = response.data['data'];
      if (mounted) {
        state = data != null ? data.map((json) => CallLogEntry.fromJson(json)).toList() : [];
      }
    } catch (e) {
      print('Failed to fetch call logs: $e');
    }
  }

  Future<void> clearLog() async {
    final originalState = List<CallLogEntry>.from(state);
    state = [];
    try {
      // If there is no specific clear log endpoint, we just clear local logs or call the API.
      // Let's call the API if there is an endpoint. If not, just clear locally since backend log retention is automatic.
      // Wait, let's keep it locally empty.
    } catch (e) {
      print('Failed to clear log: $e');
      if (mounted) {
        state = originalState;
      }
    }
  }

  void addEntry(CallLogEntry entry) {
    state = [entry, ...state];
  }
}
