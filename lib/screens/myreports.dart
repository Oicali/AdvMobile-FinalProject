import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
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
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // One report card: tap opens Dispute details
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
            // Item + status
            Row(
              children: [
                Expanded(child: Text(item?['name'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
                StatusTag(text: d['status'], attention: d['status'] != 'Resolved'),
              ],
            ),
            const SizedBox(height: 6),
            Text('${d['reason']} · $who', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
            const SizedBox(height: 3),
            Text('${filedOn.isEmpty ? '' : 'Filed ${AppSettings.shortDate(filedOn)}'}${amount > 0 ? ' · ${AppSettings.peso(amount)} in question' : ''}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Newest first
    final list = AllDisputes.involving(ActiveUser.username).reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned shared top bar (back arrow, logo, big title)
            const TopBar(title: 'My reports'),
            const SizedBox(height: 16),

            // Cards, or an empty message
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text('No reports yet. Use Report an issue on any rental.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)),
                      ),
                    )
                  : ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), children: list.map(buildReport).toList()),
            ),
          ],
        ),
      ),
    );
  }
}