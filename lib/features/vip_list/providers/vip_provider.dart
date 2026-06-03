import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final vipListProvider = StateNotifierProvider<VipListNotifier, List<VipContact>>((ref) {
  return VipListNotifier();
});

class VipListNotifier extends StateNotifier<List<VipContact>> {
  VipListNotifier()
      : super([
          VipContact(id: '1', name: 'Mom', phone: '+91 98765 43210'),
          VipContact(id: '2', name: 'Dad', phone: '+91 98765 43211'),
          VipContact(id: '3', name: 'Boss', phone: '+91 98765 43212'),
          VipContact(id: '4', name: 'Best Friend', phone: '+91 98765 43213'),
          VipContact(id: '5', name: 'Wife', phone: '+91 98765 43214'),
        ]);

  void addContact(VipContact contact) {
    state = [...state, contact];
  }

  void removeContact(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void reorderContacts(int oldIndex, int newIndex) {
    final updated = List<VipContact>.from(state);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = updated;
  }
}
