import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/call_blocking_service.dart';

class VipContact {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final DateTime addedAt;

  VipContact({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  factory VipContact.fromJson(Map<String, dynamic> json) {
    return VipContact(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      addedAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

final vipListProvider = StateNotifierProvider<VipListNotifier, List<VipContact>>((ref) {
  return VipListNotifier(ref);
});

class VipListNotifier extends StateNotifier<List<VipContact>> {
  final Ref ref;

  VipListNotifier(this.ref) : super([]) {
    loadContacts();
  }

  Future<void> _syncToNative() async {
    final phoneNumbers = state.map((c) => c.phone).toList();
    await CallBlockingService.syncVipList(phoneNumbers);
  }

  Future<void> loadContacts() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.vipList);
      final List<dynamic> data = response.data['data'] ?? [];
      state = data.map((json) => VipContact.fromJson(json)).toList();
      await _syncToNative();
    } catch (e) {
      print('Failed to load VIP contacts: $e');
    }
  }

  Future<void> addContact(String name, String phone) async {
    try {
      final dio = ref.read(dioProvider);
      // Clean phone number and ensure it starts with + for backend validation
      String formattedPhone = phone.replaceAll(RegExp(r'\s+|-|\(|\)'), '').trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }
      
      await dio.post(ApiEndpoints.vipAdd, data: {
        'name': name.trim(),
        'phone': formattedPhone,
      });
      await loadContacts(); // Reload from server
    } catch (e) {
      print('Failed to add VIP contact: $e');
      rethrow;
    }
  }

  Future<void> removeContact(String id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete(ApiEndpoints.vipRemove(id));
      state = state.where((c) => c.id != id).toList();
      await _syncToNative();
    } catch (e) {
      print('Failed to remove VIP contact: $e');
    }
  }

  void reorderContacts(int oldIndex, int newIndex) {
    // Local reorder only for now
    final updated = List<VipContact>.from(state);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = updated;
  }
}
