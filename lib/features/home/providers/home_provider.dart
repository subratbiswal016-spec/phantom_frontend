import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Invisible mode state
final invisibleProvider = StateNotifierProvider<InvisibleNotifier, InvisibleState>((ref) {
  return InvisibleNotifier();
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
  InvisibleNotifier() : super(const InvisibleState(
    blockedToday: 12,
    vipCount: 5,
  ));

  Future<void> toggle() async {
    state = state.copyWith(isLoading: true);
    // TODO: Call API to toggle invisible mode
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isInvisible: !state.isInvisible,
      isLoading: false,
    );
  }

  void updateStats({int? blockedToday, int? vipCount}) {
    state = state.copyWith(
      blockedToday: blockedToday,
      vipCount: vipCount,
    );
  }
}
