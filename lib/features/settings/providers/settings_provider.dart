import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/call_blocking_service.dart';

class SettingsState {
  final bool blockUnknown;
  final bool isSyncing;
  final bool pushNotifications;
  final bool blockedCallAlerts;
  final String customMessage;

  const SettingsState({
    this.blockUnknown = false,
    this.isSyncing = false,
    this.pushNotifications = true,
    this.blockedCallAlerts = false,
    this.customMessage = 'The number you are trying to reach is currently switched off.',
  });

  SettingsState copyWith({
    bool? blockUnknown,
    bool? isSyncing,
    bool? pushNotifications,
    bool? blockedCallAlerts,
    String? customMessage,
  }) {
    return SettingsState(
      blockUnknown: blockUnknown ?? this.blockUnknown,
      isSyncing: isSyncing ?? this.isSyncing,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      blockedCallAlerts: blockedCallAlerts ?? this.blockedCallAlerts,
      customMessage: customMessage ?? this.customMessage,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;

  SettingsNotifier(this.ref) : super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.me);
      final user = response.data['data']; // The /auth/me payload is usually nested in 'data'
      if (user != null && mounted) {
        state = state.copyWith(
          blockUnknown: user['blockUnknown'] ?? false,
          customMessage: user['customMessage'] ?? state.customMessage,
        );
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  Future<void> togglePushNotifications(bool value) async {
    state = state.copyWith(pushNotifications: value);
    if (value) {
      await NotificationService().requestPermission();
      await NotificationService().showNotification(
        title: 'Push Notifications Enabled',
        body: 'You will now receive alerts for VIP calls.',
      );
    }
  }

  Future<void> toggleBlockedCallAlerts(bool value) async {
    state = state.copyWith(blockedCallAlerts: value);
    if (value) {
      await NotificationService().requestPermission();
      await NotificationService().showNotification(
        title: 'Blocked Call Alerts Enabled',
        body: 'You will receive silent notifications when an unknown caller is blocked.',
      );
    }
  }

  Future<void> updateCustomMessage(String message) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiEndpoints.updateCustomMessage, data: {'message': message});
      state = state.copyWith(customMessage: message);
    } catch (e) {
      print('Failed to update custom message: $e');
    }
  }

  Future<void> toggleBlockUnknown() async {
    // If turning on, we need contacts permission to sync them to the backend
    if (!state.blockUnknown) {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        
        // Request the native call screening role!
        final roleGranted = await CallBlockingService.requestCallScreeningRole();
        if (!roleGranted) {
          print('Call screening role denied. Cannot enable feature natively.');
          // We can choose to fail here or just allow backend blocking (if backend blocking existed).
          // We will proceed for the sake of the backend sync, but native won't block.
        }

        state = state.copyWith(isSyncing: true, blockUnknown: true);
        
        try {
          // Tell native Android layer to block unknown callers
          await CallBlockingService.setBlockUnknown(true);

          // 1. Fetch contacts from phone
          final contacts = await FlutterContacts.getContacts(
            withProperties: true,
          );
          
          // 2. Extract phone numbers
          final phoneNumbers = <String>[];
          for (final contact in contacts) {
            for (final phone in contact.phones) {
              phoneNumbers.add(phone.number);
            }
          }
          
          // 3. Send to backend
          final dio = ref.read(dioProvider);
          await dio.post(ApiEndpoints.syncContacts, data: {'contacts': phoneNumbers});
          print('Synced ${phoneNumbers.length} contacts to backend for Unknown Numbers block.');
          
          // 4. Toggle on backend
          await dio.post(ApiEndpoints.toggleBlockUnknown, data: {'block_unknown': true});
          
        } catch (e) {
          print('Error syncing contacts: $e');
          state = state.copyWith(blockUnknown: false); // Revert on failure
          await CallBlockingService.setBlockUnknown(false); // Revert natively
        } finally {
          if (mounted) state = state.copyWith(isSyncing: false);
        }
      } else {
        // Permission denied, cannot enable feature
        print('Contacts permission denied');
        return;
      }
    } else {
      // Turning off
      try {
        await CallBlockingService.setBlockUnknown(false); // Update native layer
        
        final dio = ref.read(dioProvider);
        await dio.post(ApiEndpoints.toggleBlockUnknown, data: {'block_unknown': false});
        state = state.copyWith(blockUnknown: false);
      } catch (e) {
        print('Failed to toggle block unknown: $e');
      }
    }
  }
}
