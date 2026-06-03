import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

/// Invisible mode state
final invisibleProvider = StateNotifierProvider<InvisibleNotifier, InvisibleState>((ref) {
  return InvisibleNotifier(ref);
});

class InvisibleState {
  final bool isInvisible;
  final int blockedToday;
  final int vipCount;
  final bool isLoading;

  const InvisibleState({
    this.isInvisible = false,
    this.blockedToday = 0,
    this.vipCount = 0,
    this.isLoading = false,
  });

  InvisibleState copyWith({
    bool? isInvisible,
    int? blockedToday,
    int? vipCount,
    bool? isLoading,
  }) {
    return InvisibleState(
      isInvisible: isInvisible ?? this.isInvisible,
      blockedToday: blockedToday ?? this.blockedToday,
      vipCount: vipCount ?? this.vipCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class InvisibleNotifier extends StateNotifier<InvisibleState> {
  final Ref ref;

  InvisibleNotifier(this.ref) : super(const InvisibleState()) {
    refreshStats();
  }

  Future<void> refreshStats() async {
    try {
      final dio = ref.read(dioProvider);
      
      // Fetch status, stats and VIP list in parallel
      final results = await Future.wait([
        dio.get(ApiEndpoints.invisibleStatus),
        dio.get(ApiEndpoints.callStats),
        dio.get(ApiEndpoints.vipList),
      ]);

      final statusData = results[0].data['data'];
      final statsData = results[1].data['data'];
      final vipData = results[2].data['data'];

      if (mounted) {
        state = state.copyWith(
          isInvisible: statusData['isInvisible'] ?? false,
          blockedToday: statsData['blockedToday'] ?? 0,
          vipCount: vipData != null ? (vipData as List).length : 0,
        );
      }
    } catch (e) {
      print('Failed to refresh home stats: $e');
    }
  }

  Future<void> toggle() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiEndpoints.invisibleToggle);
      final data = response.data['data'];
      if (mounted && data != null) {
        state = state.copyWith(
          isInvisible: data['isInvisible'] ?? !state.isInvisible,
          isLoading: false,
        );
        // Refresh call stats in background
        refreshStats();
      }
    } catch (e) {
      print('Failed to toggle invisible mode: $e');
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void updateStats({int? blockedToday, int? vipCount}) {
    state = state.copyWith(
      blockedToday: blockedToday,
      vipCount: vipCount,
    );
  }
}
