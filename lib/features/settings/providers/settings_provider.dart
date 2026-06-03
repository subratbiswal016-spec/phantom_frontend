import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
// Note: In a real app, this would use ApiClient to hit /api/settings/sync-contacts
// and /api/settings/block-unknown/toggle. For this UI prototype, we manage state locally.

class SettingsState {
  final bool blockUnknown;
  final bool isSyncing;

  const SettingsState({
    this.blockUnknown = false,
    this.isSyncing = false,
  });

  SettingsState copyWith({
    bool? blockUnknown,
    bool? isSyncing,
  }) {
    return SettingsState(
      blockUnknown: blockUnknown ?? this.blockUnknown,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  Future<void> toggleBlockUnknown() async {
    // If turning on, we need contacts permission to sync them to the backend
    if (!state.blockUnknown) {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        state = state.copyWith(isSyncing: true, blockUnknown: true);
        
        try {
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
          
          // 3. TODO: Send to backend -> POST /api/settings/sync-contacts
          // await apiClient.post('/settings/sync-contacts', data: {'contacts': phoneNumbers});
          print('Synced ${phoneNumbers.length} contacts to backend for Unknown Numbers block.');
          
        } catch (e) {
          print('Error syncing contacts: $e');
        } finally {
          state = state.copyWith(isSyncing: false);
        }
      } else {
        // Permission denied, cannot enable feature
        print('Contacts permission denied');
        return;
      }
    } else {
      // Turning off
      // TODO: Call backend -> POST /api/settings/block-unknown/toggle
      state = state.copyWith(blockUnknown: false);
    }
  }
}
