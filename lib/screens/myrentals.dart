import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


class MyRentalsState extends StatefulWidget {
  const MyRentalsState({super.key});

  @override
  State<MyRentalsState> createState() => MyRentalsPage();
}


class MyRentalsPage extends State<MyRentalsState> {
  final List<String> tabs = ['Requested', 'Active', 'Overdue', 'Done'];
  String tab = 'Active';
  bool loaded = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);
  static const Color warn = Color(0xFFE8893A);


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


  List<Map<String, dynamic>> rentalsIn(String t) {
    final list = AllRentals.rentals.where((r) => r['borrower'] == ActiveUser.username && inTab(r, t)).toList();
    list.sort((a, b) => (a['end'] as String).compareTo(b['end'] as String));
    return t == 'Done' ? list.reversed.toList() : list;
  }


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


  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );


  IconData tabIcon(String t) {
    switch (t) {
      case 'Requested':
        return Icons.hourglass_empty;
      case 'Active':
        return Icons.play_circle_outline;
      case 'Overdue':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_outline;
    }
  }


  String tabTitle(String t) => t == 'Done' ? 'Past rentals' : '$t rentals';


  Widget buildChip(String label) {
    final selected = label == tab;
    final count = rentalsIn(label).length;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => tab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(color: selected ? teal : tealSoft, borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tabIcon(label), size: 15, color: selected ? Colors.white : teal),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : teal)),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0x33FFFFFF) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: selected ? Colors.white : teal)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tabTitle(tab), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
          Text('$count ${count == 1 ? 'rental' : 'rentals'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    String title;
    String hint;
    switch (tab) {
      case 'Requested':
        title = 'No pending requests';
        hint = 'Found something you like? Send a request to the owner.';
        break;
      case 'Active':
        title = 'Nothing rented right now';
        hint = 'Items you borrow will show up here.';
        break;
      case 'Overdue':
        title = 'Nothing overdue';
        hint = 'Every item is back on time.';
        break;
      default:
        title = 'No past rentals yet';
        hint = 'Finished rentals and their refunds appear here.';
    }
    final showBrowse = tab == 'Requested' || tab == 'Active';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tabIcon(tab), size: 44, color: const Color(0xFFB5C2BF)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 4),
            Text(hint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
            if (showBrowse) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Browse items'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget buildRental(Map<String, dynamic> r) {
    final item = AllItems.byId(r['itemId']);
    final String status = r['status'];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/rentaldetails', arguments: r['id']).then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: cardStyle(20).copyWith(border: status == 'Overdue' ? Border.all(color: warn, width: 1.5) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
     
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemPhoto(item: item ?? <String, dynamic>{'image': '', 'category': ''}, width: 64, height: 64, radius: 14, iconSize: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item?['name'] ?? 'Item',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                          ),
                          const SizedBox(width: 8),
                          StatusTag(text: status, attention: status == 'Overdue'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...detailLines(r).map((l) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(l, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                          )),
                    ],
                  ),
                ),
              ],
            ),

     
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
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            const TopBar(title: 'My rentals', showBack: false),
            const SizedBox(height: 14),

            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: tabs.map(buildChip).toList()),
            ),
            const SizedBox(height: 16),

        
            buildSectionHeader(list.length),

      
            Expanded(
              child: list.isEmpty
                  ? buildEmpty()
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