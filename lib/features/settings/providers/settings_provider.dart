import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../vip_list/providers/vip_provider.dart';

class SettingsState {
  final bool blockUnknown;
  final bool isSyncing;
  final String subscriptionTier;
  final bool pushNotifications;
  final bool blockedCallAlerts;
  final bool blockDirectCalls;

  const SettingsState({
    this.blockUnknown = false,
    this.isSyncing = false,
    this.subscriptionTier = 'free',
    this.pushNotifications = true,
    this.blockedCallAlerts = false,
    this.blockDirectCalls = false,
  });

  SettingsState copyWith({
    bool? blockUnknown,
    bool? isSyncing,
    String? subscriptionTier,
    bool? pushNotifications,
    bool? blockedCallAlerts,
    bool? blockDirectCalls,
  }) {
    return SettingsState(
      blockUnknown: blockUnknown ?? this.blockUnknown,
      isSyncing: isSyncing ?? this.isSyncing,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      blockedCallAlerts: blockedCallAlerts ?? this.blockedCallAlerts,
      blockDirectCalls: blockDirectCalls ?? this.blockDirectCalls,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;
  static const _platform = MethodChannel('com.phantom.app/call_blocker');

  SettingsNotifier(this.ref) : super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localBlockDirect = prefs.getBool('blockDirectCalls') ?? false;
      
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.me);
      final data = response.data['data'];
      
      bool currentInvisible = false;
      if (data != null) {
        currentInvisible = data['isInvisible'] ?? false;
      }
      
      // Save state variables to SharedPreferences for Android CallBlockerService access
      await prefs.setBool('isInvisible', currentInvisible);
      
      // Sync VIP numbers list to SharedPreferences for native access
      final vipContacts = ref.read(vipListProvider);
      final vipPhones = vipContacts.map((c) => c.phone).toList();
      await prefs.setString('vipListCached', jsonEncode(vipPhones));

      if (data != null && mounted) {
        state = state.copyWith(
          blockUnknown: data['blockUnknown'] ?? false,
          subscriptionTier: data['plan'] ?? 'free',
          pushNotifications: data['pushNotifications'] ?? true,
          blockedCallAlerts: data['blockedCallAlerts'] ?? false,
          blockDirectCalls: localBlockDirect,
        );
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  Future<void> togglePushNotifications() async {
    final newValue = !state.pushNotifications;
    state = state.copyWith(pushNotifications: newValue);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/settings/notifications/push/toggle');
    } catch (e) {
      print('Failed to toggle push notifications: $e');
      state = state.copyWith(pushNotifications: !newValue);
    }
  }

  Future<void> toggleBlockedCallAlerts() async {
    final newValue = !state.blockedCallAlerts;
    state = state.copyWith(blockedCallAlerts: newValue);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/settings/notifications/alerts/toggle');
    } catch (e) {
      print('Failed to toggle blocked call alerts: $e');
      state = state.copyWith(blockedCallAlerts: !newValue);
    }
  }

  Future<void> toggleBlockUnknown() async {
    final newValue = !state.blockUnknown;
    // If turning on, request contacts permission
    if (newValue) {
      final status = await Permission.contacts.request();
      if (!status.isGranted) {
        print('Contacts permission denied');
        return;
      }
    }

    // Optimistic update
    state = state.copyWith(blockUnknown: newValue);

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/settings/block-unknown/toggle', data: {
        'blockUnknown': newValue,
      });
    } catch (e) {
      print('Failed to update block unknown: $e');
      // Revert on failure
      state = state.copyWith(blockUnknown: !newValue);
    }
  }

  Future<void> toggleBlockDirectCalls() async {
    final newValue = !state.blockDirectCalls;
    
    if (newValue) {
      // 1. Request Telecom/Phone Permissions
      final phoneStatus = await Permission.phone.request();
      if (!phoneStatus.isGranted) {
        print('Phone permission denied');
        return;
      }
      
      // 2. Request Android Call Screening Role
      try {
        final bool roleGranted = await _platform.invokeMethod<bool>('requestCallScreeningRole') ?? false;
        if (!roleGranted) {
          print('Call screening role denied');
          return;
        }
      } on PlatformException catch (e) {
        print('Failed to request role: ${e.message}');
        return;
      }
    }

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('blockDirectCalls', newValue);
    
    state = state.copyWith(blockDirectCalls: newValue);
  }

  Future<void> upgradeSubscription(String tier) async {
    try {
      final dio = ref.read(dioProvider);
      // Wait, we need to call /api/subscription/upgrade which I just made
      final response = await dio.post('/subscription/upgrade', data: {
        'plan': tier.toLowerCase(),
      });
      if (response.data['success'] == true) {
        state = state.copyWith(subscriptionTier: tier.toLowerCase());
      }
    } catch (e) {
      print('Failed to upgrade subscription: $e');
      rethrow;
    }
  }
}
