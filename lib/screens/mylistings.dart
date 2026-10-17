import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allsaved.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
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
  static const Color tealSoft = Color(0xFFE3F0EE);

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
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

  
  Widget buildPill(String label, VoidCallback? onTap, {IconData? icon, Color color = teal}) {
    final enabled = onTap != null;
    final style = OutlinedButton.styleFrom(
      foregroundColor: color,
      disabledForegroundColor: const Color(0xFFA9B6B4),
      backgroundColor: enabled ? color.withAlpha(20) : Colors.transparent,
      side: BorderSide(color: enabled ? color : const Color(0xFFC9D3D1), width: 1.5),
      shape: const StadiumBorder(),
      minimumSize: const Size(0, 36),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    );
    if (icon == null) return OutlinedButton(onPressed: onTap, style: style, child: Text(label));
    return OutlinedButton.icon(onPressed: onTap, style: style, icon: Icon(icon, size: 16), label: Text(label));
  }


  Map<String, dynamic>? awaitingReturn(String itemId) {
    for (final r in AllRentals.rentals) {
      if (r['itemId'] == itemId && r['status'] == 'Returned' && r['lenderConfirmed'] != true) return r;
    }
    return null;
  }

  Map<String, dynamic>? closable(String itemId) {
    for (final r in AllRentals.rentals) {
      if (r['itemId'] == itemId && r['lender'] == ActiveUser.username && RentalFees.capReached(r)) return r;
    }
    return null;
  }

  Future<void> closeNotReturned(Map<String, dynamic> r) async {
    final amount = AppSettings.peso(RentalFees.deposit(r));
    final where = r['payment'] == 'cash' ? 'stays with you ' : 'is paid to your P-wallet ';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close as not returned?'),
        content: Text('The borrower loses the full deposit of $amount. It $where. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not yet')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Close rental', style: TextStyle(color: error))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      r['status'] = 'Completed';
      r['lenderConfirmed'] = true;
    });
  }

  Map<String, dynamic>? awaitingRating(String itemId) {
    for (final r in AllRentals.rentals) {
      if (r['itemId'] == itemId && r['lender'] == ActiveUser.username && r['status'] == 'Completed' && !AllReviews.hasReviewed(ActiveUser.username, r['id'])) return r;
    }
    return null;
  }


  Widget buildListing(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final current = AllItems.currentRental(id);
    final rented = current != null;
    final locked = AllItems.isLocked(id);
    final waiting = awaitingReturn(id);
    final toRate = awaitingRating(id);
    final toClose = closable(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemPhoto(item: item, width: 84, height: 84, radius: 16, iconSize: 32),
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
                if (current != null) ...[
                  const SizedBox(height: 4),
                  Text('Rented by ${AllUsers.byUsername(current['borrower'])?['fullname'] ?? current['borrower']} · ${AppSettings.shortDate(current['start'])} – ${AppSettings.shortDate(current['end'])}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
                ],
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    buildPill('Edit', () => openEditor(id), icon: Icons.edit_outlined),
                    buildPill('Delete', locked ? null : () => confirmDelete(item), icon: Icons.delete_outline, color: error),
                  ],
                ),
                if (waiting != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: buildPill('Confirm return', () => Navigator.pushNamed(context, '/confirmreturn', arguments: waiting['id']).then((_) => setState(() {}))),
                  ),
                if (toClose != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: buildPill('Close as not returned', () => closeNotReturned(toClose), icon: Icons.block, color: error),
                  ),
                if (toRate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: buildPill('Rate borrower', () => Navigator.pushNamed(context, '/ratereview', arguments: toRate['id']).then((_) => setState(() {}))),
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

  Widget buildSectionHeader(List<Map<String, dynamic>> items) {
    final count = items.length;
    final out = items.where((i) => AllItems.currentRental(i['id']) != null).length;
    final summary = '$count ${count == 1 ? 'item' : 'items'}${out > 0 ? ' · $out rented out' : ''}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Your items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
          Text(summary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 44, color: Color(0xFFB5C2BF)),
            SizedBox(height: 10),
            Text('Nothing listed yet', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            SizedBox(height: 4),
            Text('Post an item with a daily rate and deposit, and others can start renting it.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
          ],
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: cardStyle(22),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
                        child: const Icon(Icons.inbox_outlined, size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Booking requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
                            SizedBox(height: 3),
                            Text('Approve or decline rentals of your items', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.3)),
                          ],
                        ),
                      ),
                      if (pending > 0) StatusTag(text: '$pending pending', attention: true),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 24, color: gray),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            buildSectionHeader(items),
            Expanded(
              child: items.isEmpty
                  ? buildEmpty()
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 6),
                      Text('Post new item'),
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