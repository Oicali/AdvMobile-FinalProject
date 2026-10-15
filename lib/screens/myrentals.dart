import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';

// Widget class (XState naming convention)
class MyRentalsState extends StatefulWidget {
  const MyRentalsState({super.key});

  @override
  State<MyRentalsState> createState() => MyRentalsPage();
}

// State class (XPage naming convention)
class MyRentalsPage extends State<MyRentalsState> {
  final List<String> tabs = ['Requested', 'Active', 'Overdue', 'Done'];
  String tab = 'Active';
  bool loaded = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

  // Bring statuses up to date, then open on the tab passed in (or the most urgent non-empty one)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    AllRentals.syncStatuses();

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && tabs.contains(arg)) {
      tab = arg;
    } else {
      for (final t in ['Overdue', 'Active', 'Requested', 'Done']) {
        if (rentalsIn(t).isNotEmpty) {
          tab = t;
          break;
        }
      }
    }
  }

  // Which statuses belong to which tab
  bool inTab(Map<String, dynamic> r, String t) {
    final s = r['status'];
    switch (t) {
      case 'Requested':
        return s == 'Requested';
      case 'Active':
        return s == 'Approved' || s == 'Active' || s == 'Returned';
      case 'Overdue':
        return s == 'Overdue';
      default:
        return s == 'Completed' || s == 'Declined' || s == 'Cancelled';
    }
  }

  // My rentals as borrower in one tab: soonest due first, newest first on Done
  List<Map<String, dynamic>> rentalsIn(String t) {
    final list = AllRentals.rentals.where((r) => r['borrower'] == ActiveUser.username && inTab(r, t)).toList();
    list.sort((a, b) => (a['end'] as String).compareTo(b['end'] as String));
    return t == 'Done' ? list.reversed.toList() : list;
  }

  // The grey lines under the item name, depending on status
  List<String> detailLines(Map<String, dynamic> r) {
    final String status = r['status'];
    final end = AppSettings.shortDate(r['end']);
    final range = '${AppSettings.shortDate(r['start'])} – $end';
    final returned = (r['returnedOn'] as String).isEmpty ? end : AppSettings.shortDate(r['returnedOn']);

    switch (status) {
      case 'Overdue':
        final late = RentalFees.daysLate(r);
        return ['Due $end · $late ${late == 1 ? 'day' : 'days'} late', 'Late fee so far: ${AppSettings.peso(RentalFees.lateFee(r))}'];
      case 'Active':
        return [r['end'] == AppSettings.demoDate ? 'Due today · $end' : 'Due $end'];
      case 'Approved':
        return ['Starts ${AppSettings.shortDate(r['start'])} · Due $end'];
      case 'Requested':
        return ['Waiting for owner · $range'];
      case 'Returned':
        return ['Returned $returned · Waiting for lender to confirm'];
      case 'Completed':
        return ['Returned $returned · Deposit refund ${AppSettings.peso(RentalFees.depositRefund(r))}'];
      case 'Declined':
        return ['Declined by owner · $range'];
      default:
        return ['Cancelled · $range'];
    }
  }

  // Confirm, then withdraw a pending request
  Future<void> cancelRequest(Map<String, dynamic> r) async {
    final item = AllItems.byId(r['itemId']);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: Text('Your request for ${item?['name'] ?? 'this item'} will be withdrawn.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel request', style: TextStyle(color: error))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => r['status'] = 'Cancelled');
  }

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  // One tab chip (selected = solid teal)
  Widget buildChip(String label) {
    final selected = label == tab;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => tab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: selected ? teal : tealSoft, borderRadius: BorderRadius.circular(999)),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : teal)),
        ),
      ),
    );
  }

  // One rental card; tapping it opens Rental details
  Widget buildRental(Map<String, dynamic> r) {
    final item = AllItems.byId(r['itemId']);
    final String status = r['status'];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/rentaldetails', arguments: r['id']).then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: cardStyle(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name + status tag (orange when overdue)
            Row(
              children: [
                Expanded(child: Text(item?['name'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
                const SizedBox(width: 8),
                StatusTag(text: status, attention: status == 'Overdue'),
              ],
            ),
            const SizedBox(height: 6),
            ...detailLines(r).map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(l, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                )),

            // Pending requests can be withdrawn right from the list
            if (status == 'Requested') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => cancelRequest(r),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: teal,
                    side: const BorderSide(color: teal, width: 1.5),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Cancel request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = rentalsIn(tab);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      bottomNavigationBar: const SafeArea(child: BottomNav(current: 1)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen title
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 14),
              child: Text('My rentals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
            ),

            // Tab chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: tabs.map(buildChip).toList()),
            ),
            const SizedBox(height: 16),

            // Rental cards, or an empty message
            Expanded(
              child: list.isEmpty
                  ? Center(child: Text('No ${tab.toLowerCase()} rentals.', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      children: list.map(buildRental).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}