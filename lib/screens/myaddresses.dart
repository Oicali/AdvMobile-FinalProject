import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

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
  static const Color tealSoft = Color(0xFFE3F0EE);

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


  Widget buildPill(String label, VoidCallback onTap, {IconData? icon, Color color = teal}) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: color,
      backgroundColor: color.withAlpha(20),
      side: BorderSide(color: color, width: 1.5),
      shape: const StadiumBorder(),
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    );
    if (icon == null) return OutlinedButton(onPressed: onTap, style: style, child: Text(label));
    return OutlinedButton.icon(onPressed: onTap, style: style, icon: Icon(icon, size: 16), label: Text(label));
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
        border: isDefault ? Border.all(color: teal, width: 1.5) : null,
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                child: const Icon(Icons.location_on_outlined, size: 18, color: teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['label'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
                    const SizedBox(height: 4),
                    Text('${a['street']}, ${a['barangay']}, ${a['city']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
                  ],
                ),
              ),
              if (isDefault) ...[
                const SizedBox(width: 8),
                const StatusTag(text: 'Default'),
              ],
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8E6)),
          ),

          // Actions wrap onto a second line on narrow phones
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildPill('Edit', () => openForm(a['id']), icon: Icons.edit_outlined),
              if (!isDefault) buildPill('Set as default', () => setDefault(a), icon: Icons.check_circle_outline),
              buildPill('Delete', () => confirmDelete(a), icon: Icons.delete_outline, color: error),
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
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopBar(title: 'My addresses'),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saved addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
                  Text(list.length == 1 ? '1 address' : '${list.length} addresses',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
                ],
              ),
            ),

            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_off_outlined, size: 44, color: Color(0xFFB5C2BF)),
                            SizedBox(height: 10),
                            Text('No saved addresses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                            SizedBox(height: 4),
                            Text('Add one to use it for delivery.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                          ],
                        ),
                      ),
                    )
                  : ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), children: list.map(buildAddress).toList()),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
              ),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 6),
                      Text('Add address'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}