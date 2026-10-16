import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

// Widget class (XState naming convention)
class MyReportsState extends StatefulWidget {
  const MyReportsState({super.key});

  @override
  State<MyReportsState> createState() => MyReportsPage();
}

// State class (XPage naming convention)
class MyReportsPage extends State<MyReportsState> {
  final List<String> tabs = ['All', 'Open', 'Resolved'];
  String tab = 'All';

  static const Color teal = Color(0xFF0F5C5C);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  bool inTab(Map<String, dynamic> d, String t) {
    if (t == 'Open') return d['status'] != 'Resolved';
    if (t == 'Resolved') return d['status'] == 'Resolved';
    return true;
  }

  List<Map<String, dynamic>> reportsIn(String t) {
    return AllDisputes.involving(ActiveUser.username).reversed.where((d) => inTab(d, t)).toList();
  }

  IconData tabIcon(String t) {
    switch (t) {
      case 'Open':
        return Icons.hourglass_empty;
      case 'Resolved':
        return Icons.check_circle_outline;
      default:
        return Icons.flag_outlined;
    }
  }

  String tabTitle(String t) => t == 'All' ? 'All reports' : '$t reports';

  Widget buildChip(String label) {
    final selected = label == tab;
    final count = reportsIn(label).length;
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
          Text('$count ${count == 1 ? 'report' : 'reports'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    String title;
    String hint;
    switch (tab) {
      case 'Open':
        title = 'No open reports';
        hint = 'Reports waiting for a ruling show up here.';
        break;
      case 'Resolved':
        title = 'No resolved reports';
        hint = 'Rulings appear here once the simulated admin reviews a report.';
        break;
      default:
        title = 'No reports yet';
        hint = 'Use Report an issue on any rental.';
    }
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
          ],
        ),
      ),
    );
  }

  Widget buildReport(Map<String, dynamic> d) {
    final r = AllRentals.byId(d['rentalId']);
    final item = r == null ? null : AllItems.byId(r['itemId']);
    final isFiler = d['filedBy'] == ActiveUser.username;
    final who = isFiler ? 'You filed this' : '${AllUsers.byUsername(d['filedBy'])?['fullname'] ?? d['filedBy']} filed this';
    final amount = d['amount'] as int;
    final filedOn = (d['filedOn'] ?? '') as String;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/disputedetails', arguments: d['id']).then((_) => setState(() {})),
      child: Container(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemPhoto(item: item ?? <String, dynamic>{'image': '', 'category': ''}, width: 84, height: 84, radius: 16, iconSize: 32),
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
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
                          ),
                          const SizedBox(width: 8),
                          StatusTag(text: d['status'], attention: d['status'] != 'Resolved'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${d['reason']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
                      const SizedBox(height: 3),
                      Text(who, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                      if (filedOn.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text('Filed ${AppSettings.shortDate(filedOn)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                      ],
                      if (amount > 0) ...[
                        const SizedBox(height: 6),
                        Text('${AppSettings.peso(amount)} in question', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: teal)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = reportsIn(tab);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TopBar(title: 'My reports'),
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
                  : ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), children: list.map(buildReport).toList()),
            ),
          ],
        ),
      ),
    );
  }
}