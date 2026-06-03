import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final callLogProvider = StateNotifierProvider<CallLogNotifier, List<CallLogEntry>>((ref) {
  return CallLogNotifier();
});

class CallLogNotifier extends StateNotifier<List<CallLogEntry>> {
  CallLogNotifier()
      : super([
          CallLogEntry(
            id: '1',
            callerName: 'Unknown',
            callerPhone: '+91 98765 43210',
            status: 'blocked',
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
          CallLogEntry(
            id: '2',
            callerName: 'Mom',
            callerPhone: '+91 98765 43211',
            status: 'forwarded',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            duration: 180,
          ),
          CallLogEntry(
            id: '3',
            callerName: 'Spam Caller',
            callerPhone: '+91 77777 77777',
            status: 'blocked',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          CallLogEntry(
            id: '4',
            callerName: 'Unknown',
            callerPhone: '+91 88888 88888',
            status: 'blocked',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          CallLogEntry(
            id: '5',
            callerName: 'Boss',
            callerPhone: '+91 98765 43212',
            status: 'forwarded',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            duration: 120,
          ),
          CallLogEntry(
            id: '6',
            callerName: 'Unknown',
            callerPhone: '+91 66666 66666',
            status: 'blocked',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          CallLogEntry(
            id: '7',
            callerName: 'Telemarketer',
            callerPhone: '+91 11111 11111',
            status: 'blocked',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          CallLogEntry(
            id: '8',
            callerName: 'Wife',
            callerPhone: '+91 98765 43214',
            status: 'forwarded',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
            duration: 300,
          ),
        ]);

  void clearLog() {
    state = [];
  }

  void addEntry(CallLogEntry entry) {
    state = [entry, ...state];
  }
}
