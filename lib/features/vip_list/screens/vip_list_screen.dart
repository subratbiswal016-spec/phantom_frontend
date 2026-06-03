import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/phantom_card.dart';
import '../../../core/widgets/phantom_app_bar.dart';
import '../providers/vip_provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class VipListScreen extends ConsumerStatefulWidget {
  const VipListScreen({super.key});

  @override
  ConsumerState<VipListScreen> createState() => _VipListScreenState();
}

class _VipListScreenState extends ConsumerState<VipListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vipList = ref.watch(vipListProvider);
    final filteredList = _searchQuery.isEmpty
        ? vipList
        : vipList
            .where((c) =>
                c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.phone.contains(_searchQuery))
            .toList();

    return Scaffold(
      backgroundColor: PhantomColors.bgDark,
      appBar: const PhantomAppBar(title: 'VIP Contacts'),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: PhantomColors.bgCardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PhantomColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.inter(
                  color: PhantomColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search VIP contacts...',
                  hintStyle: GoogleFonts.inter(
                    color: PhantomColors.textTertiary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: PhantomColors.textTertiary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // VIP count header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PhantomColors.primaryStart.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${filteredList.length} VIPs',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PhantomColors.primaryStart,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Swipe left to remove',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: PhantomColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // VIP list
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final contact = filteredList[index];
                      return Dismissible(
                        key: ValueKey(contact.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            gradient: PhantomColors.dangerGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(vipListProvider.notifier)
                              .removeContact(contact.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${contact.name} removed from VIP'),
                              backgroundColor: PhantomColors.bgElevated,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: _buildContactTile(contact, index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: PhantomColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PhantomColors.primaryStart.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddContactSheet(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.person_add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContactTile(VipContact contact, int index) {
    final colors = [
      PhantomColors.primaryStart,
      PhantomColors.accent,
      PhantomColors.warning,
      PhantomColors.success,
      PhantomColors.danger,
    ];
    final color = colors[index % colors.length];

    return PhantomCard(
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                contact.name[0].toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name & phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: PhantomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: PhantomColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // VIP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PhantomColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: PhantomColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'VIP',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: PhantomColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn(duration: 300.ms).slideX(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: PhantomColors.primaryStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              size: 36,
              color: PhantomColors.primaryStart,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No VIP contacts yet',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PhantomColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add contacts who can always\nreach you in invisible mode',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: PhantomColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddContactSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: PhantomColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: PhantomColors.border),
              left: BorderSide(color: PhantomColors.border),
              right: BorderSide(color: PhantomColors.border),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PhantomColors.bgElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Add VIP Contact',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: PhantomColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This contact will always be able to reach you',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: PhantomColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Pick from Contacts Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (await Permission.contacts.request().isGranted) {
                        try {
                          final contact = await FlutterContacts.openExternalPick();
                          if (contact != null) {
                            final fullContact = await FlutterContacts.getContact(contact.id);
                            if (fullContact != null && fullContact.phones.isNotEmpty) {
                              nameController.text = fullContact.displayName;
                              phoneController.text = fullContact.phones.first.number;
                            }
                          }
                        } catch (e) {
                          // ignore
                        }
                      }
                    },
                    icon: const Icon(Icons.contacts_rounded, color: PhantomColors.primaryStart, size: 20),
                    label: Text(
                      'Choose from Contacts',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: PhantomColors.primaryStart,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: PhantomColors.primaryStart),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name field
                Text(
                  'Name',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: PhantomColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.inter(color: PhantomColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Contact name',
                    prefixIcon: const Icon(
                      Icons.person_rounded,
                      color: PhantomColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: PhantomColors.bgCardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PhantomColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PhantomColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone field
                Text(
                  'Phone Number',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: PhantomColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(color: PhantomColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '+91 XXXXX XXXXX',
                    prefixIcon: const Icon(
                      Icons.phone_rounded,
                      color: PhantomColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: PhantomColors.bgCardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PhantomColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: PhantomColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: PhantomColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (nameController.text.isNotEmpty &&
                              phoneController.text.isNotEmpty) {
                            ref.read(vipListProvider.notifier).addContact(
                                  VipContact(
                                    id: DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                    name: nameController.text,
                                    phone: phoneController.text,
                                  ),
                                );
                            Navigator.pop(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Add to VIP List',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
