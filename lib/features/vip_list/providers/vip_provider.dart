import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

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
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      addedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

final vipListProvider = StateNotifierProvider<VipListNotifier, List<VipContact>>((ref) {
  return VipListNotifier(ref);
});

class VipListNotifier extends StateNotifier<List<VipContact>> {
  final Ref ref;

  VipListNotifier(this.ref) : super([]) {
    fetchList();
  }

  Future<void> fetchList() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiEndpoints.vipList);
      final List? data = response.data['data'];
      if (mounted) {
        state = data != null ? data.map((json) => VipContact.fromJson(json)).toList() : [];
      }
    } catch (e) {
      print('Failed to fetch VIP contacts: $e');
    }
  }

  Future<bool> addContact(String name, String phone) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiEndpoints.vipAdd, data: {
        'name': name,
        'phone': phone,
      });
      final newContactData = response.data['data'];
      if (mounted && newContactData != null) {
        final newContact = VipContact.fromJson(newContactData);
        state = [...state, newContact];
        return true;
      }
      return false;
    } catch (e) {
      print('Failed to add VIP contact: $e');
      return false;
    }
  }

  Future<void> removeContact(String id) async {
    // Optimistic update
    final originalState = List<VipContact>.from(state);
    state = state.where((c) => c.id != id).toList();

    try {
      final dio = ref.read(dioProvider);
      await dio.delete(ApiEndpoints.vipRemove(id));
    } catch (e) {
      print('Failed to remove VIP contact: $e');
      // Revert
      if (mounted) {
        state = originalState;
      }
    }
  }

  void reorderContacts(int oldIndex, int newIndex) {
    final updated = List<VipContact>.from(state);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = updated;
  }
}
