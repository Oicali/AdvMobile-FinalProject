import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';

// Widget class (XState naming convention)
class MyAddressesState extends StatefulWidget {
  const MyAddressesState({super.key});

  @override
  State<MyAddressesState> createState() => MyAddressesPage();
}

// State class (XPage naming convention)
class MyAddressesPage extends State<MyAddressesState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

  // My addresses with the default one first
  List<Map<String, dynamic>> get mine {
    final list = AllAddresses.ownedBy(ActiveUser.username);
    list.sort((a, b) => (b['isDefault'] == true ? 1 : 0) - (a['isDefault'] == true ? 1 : 0));
    return list;
  }

  // Open the form: no argument = add, an id String = edit; refresh on return
  void openForm(String? id) {
    Navigator.pushNamed(context, '/addeditaddress', arguments: id).then((_) => setState(() {}));
  }

  // Make one address the default (only one per owner)
  void setDefault(Map<String, dynamic> a) {
    setState(() {
      for (final x in AllAddresses.ownedBy(ActiveUser.username)) {
        x['isDefault'] = x['id'] == a['id'];
      }
    });
  }

  // Confirm, delete, and promote another address if the default was removed
  Future<void> confirmDelete(Map<String, dynamic> a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${a['label']}?'),
        content: const Text('Past rentals keep their own copy of the address, so they are not affected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: error))),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() {
      final wasDefault = a['isDefault'] == true;
      AllAddresses.addresses.removeWhere((x) => x['id'] == a['id']);
      final rest = AllAddresses.ownedBy(ActiveUser.username);
      if (wasDefault && rest.isNotEmpty) rest.first['isDefault'] = true;
    });
  }

  // Small outlined pill button
  Widget buildPill(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: teal,
        side: const BorderSide(color: teal, width: 1.5),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }

  // One address card
  Widget buildAddress(Map<String, dynamic> a) {
    final isDefault = a['isDefault'] == true;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Default tag
          Row(
            children: [
              Expanded(child: Text(a['label'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
              if (isDefault) const StatusTag(text: 'Default'),
            ],
          ),
          const SizedBox(height: 4),
          Text('${a['street']}, ${a['barangay']}, ${a['city']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
          const SizedBox(height: 12),

          // Actions wrap onto a second line on narrow phones
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildPill('Edit', () => openForm(a['id'])),
              if (!isDefault) buildPill('Set as default', () => setDefault(a)),
              buildPill('Delete', () => confirmDelete(a)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = mine;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow + title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: ink)),
                  const SizedBox(width: 8),
                  const Text('My addresses', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                ],
              ),
            ),

            // Cards, or an empty message
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('No saved addresses yet.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)))
                  : ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), children: list.map(buildAddress).toList()),
            ),

            // Pinned: add address
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => openForm(null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Add address'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}