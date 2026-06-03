import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/call_blocking_service.dart';

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
    loadStatus();
  }

  Future<void> loadStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.invisibleStatus);
      final data = response.data['data'];
      if (data != null && mounted) {
        state = state.copyWith(
          isInvisible: data['isInvisible'] ?? false,
          // Let's assume stats aren't currently returned by this endpoint, we will fetch stats in call log
        );
      }
    } catch (e) {
      print('Failed to load status: $e');
    }
  }

  Future<void> toggle() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiEndpoints.invisibleToggle);
      final data = response.data['data'];
      if (data != null && mounted) {
        final newInvisibleState = data['isInvisible'] ?? false;
        
        // Sync with Native Android Call Blocker
        await CallBlockingService.setInvisibleMode(newInvisibleState);

        state = state.copyWith(
          isInvisible: newInvisibleState,
          isLoading: false,
        );
      }
    } catch (e) {
      print('Failed to toggle status: $e');
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
