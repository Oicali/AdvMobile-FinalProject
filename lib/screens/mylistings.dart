import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allsaved.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

// Widget class (XState naming convention)
class MyListingsState extends StatefulWidget {
  const MyListingsState({super.key});

  @override
  State<MyListingsState> createState() => MyListingsPage();
}

// State class (XPage naming convention)
class MyListingsPage extends State<MyListingsState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  // Open the editor: no id = post new, an id = edit; refresh when we come back
  void openEditor(String? id) {
    Navigator.pushNamed(context, '/postedititem', arguments: id).then((_) => setState(() {}));
  }

  // Confirm, then soft-delete (listed = false) so rental history keeps its item
  Future<void> confirmDelete(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${item['name']}?'),
        content: const Text('It will be removed from Browse. Pending requests for it will be declined.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: error))),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() {
      for (final r in AllRentals.rentals) {
        if (r['itemId'] == item['id'] && r['status'] == 'Requested') r['status'] = 'Declined';
      }
      AllSaved.saved.removeWhere((s) => s['itemId'] == item['id']);
      item['listed'] = false;
    });
  }

  // Small outlined pill; onTap null = disabled look
  Widget buildPill(String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: teal,
        disabledForegroundColor: const Color(0xFFA9B6B4),
        side: BorderSide(color: enabled ? teal : const Color(0xFFC9D3D1), width: 1.5),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }


  Map<String, dynamic>? awaitingReturn(String itemId) {
    for (final r in AllRentals.rentals) {
      if (r['itemId'] == itemId && r['status'] == 'Returned' && r['lenderConfirmed'] != true) return r;
    }
    return null;
  }


  Widget buildListing(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final rented = AllItems.currentRental(id) != null;
    final locked = AllItems.isLocked(id);
    final waiting = awaitingReturn(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shared item photo
          ItemPhoto(item: item, width: 52, height: 52, radius: 14, iconSize: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + status tag
                Row(
                  children: [
                    Expanded(child: Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
                    const SizedBox(width: 8),
                    StatusTag(text: rented ? 'Rented out' : 'Listed', attention: rented),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${AppSettings.peso(item['dailyRate'])} / day · Deposit ${AppSettings.peso(item['deposit'])}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                const SizedBox(height: 10),

                // Edit always works; Delete is disabled while a rental commits the item
                Row(
                  children: [
                    buildPill('Edit', () => openEditor(id)),
                    const SizedBox(width: 8),
                    buildPill('Delete', locked ? null : () => confirmDelete(item)),
                  ],
                ),
                if (waiting != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: buildPill('Confirm return', () => Navigator.pushNamed(context, '/confirmreturn', arguments: waiting['id']).then((_) => setState(() {}))),
                  ),
                if (locked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(rented ? 'Delete is blocked while rented out.' : 'Delete is blocked: an approved rental is coming up.',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = AllItems.ownedBy(ActiveUser.username);
    final pending = AllRentals.pendingFor(ActiveUser.username).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      bottomNavigationBar: const SafeArea(child: BottomNav(current: 2)),
      body: SafeArea(
        top: false, // TopBar handles the status bar itself
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shared top bar (tab screen, so no back arrow)
            const TopBar(title: 'My listings', showBack: false),
            const SizedBox(height: 16),

            // Entry point to Incoming Requests, with a pending count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/incomingrequests').then((_) => setState(() {})),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: cardStyle(16),
                  child: Row(
                    children: [
                      const Expanded(child: Text('Booking requests', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink))),
                      if (pending > 0) StatusTag(text: '$pending pending', attention: true),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 18, color: gray),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Listing cards, or an empty message
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text("You haven't listed anything yet. Tap Post new item to start.",
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      children: items.map(buildListing).toList(),
                    ),
            ),

            // Pinned: post a new item
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => openEditor(null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Post new item'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}