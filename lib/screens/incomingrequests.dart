import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';

import 'package:advmobile_finalproject/widgets/topbar.dart';

class IncomingRequestsState extends StatefulWidget {
  const IncomingRequestsState({super.key});

  @override
  State<IncomingRequestsState> createState() => IncomingRequestsPage();
}


class IncomingRequestsPage extends State<IncomingRequestsState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);


  String? conflictFor(Map<String, dynamic> r) {
    for (final o in AllRentals.rentals) {
      if (o['id'] == r['id'] || o['itemId'] != r['itemId']) continue;
      final s = o['status'];
      if (s == 'Overdue') return "This item hasn't been returned yet.";
      if (s == 'Returned') return 'This item is waiting for you to confirm its return.';
      if ((s == 'Approved' || s == 'Active') && (r['start'] as String).compareTo(o['end']) <= 0 && (r['end'] as String).compareTo(o['start']) >= 0) {
        return 'Overlaps another rental (${AppSettings.shortDate(o['start'])} to ${AppSettings.shortDate(o['end'])}).';
      }
    }
    return null;
  }


  void approve(Map<String, dynamic> r) {
    final conflict = conflictFor(r);
    if (conflict != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(conflict)));
      return;
    }
    setState(() {
      r['status'] = 'Approved';
      AllRentals.syncStatuses();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request approved.')));
  }


  void decline(Map<String, dynamic> r) {
    setState(() => r['status'] = 'Declined');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request declined.')));
  }


  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );


  Widget buildRequest(Map<String, dynamic> r) {
    final borrower = AllUsers.byUsername(r['borrower']);
    final item = AllItems.byId(r['itemId']);
    final rating = AllReviews.averageFor(r['borrower'], 'borrower');
    final days = AppSettings.daysBetween(r['start'], r['end']);
    final how = r['method'] == 'delivery' ? 'Delivery to ${r['address']}' : 'Pickup';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardStyle(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
                child: Text(initialOf((borrower?['fullname'] ?? r['borrower']).toString()),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile', arguments: r['borrower']),
                  child: Text(borrower?['fullname'] ?? r['borrower'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
                ),
              ),
              // Star pill with the borrower's rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: tealSoft, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: rating == null ? const Color(0xFFB5C2BF) : const Color(0xFFF5A623)),
                    const SizedBox(width: 4),
                    Text(rating == null ? 'No reviews yet' : rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: teal)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE3E8E6)),
          const SizedBox(height: 12),
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemPhoto(item: item ?? <String, dynamic>{}, width: 84, height: 84, radius: 16, iconSize: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item?['name'] ?? 'Item', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
                    const SizedBox(height: 3),
                    Text('${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])} · $days ${days == 1 ? 'day' : 'days'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                    const SizedBox(height: 3),
                    Text(how, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(999)),
                      child: Text('Total ${AppSettings.peso(AllItems.totalDue(r))} incl. deposit',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),


          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 12, offset: Offset(0, 5))],
                  ),
                  child: ElevatedButton(
                    onPressed: () => approve(r),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 6),
                        Text('Approve'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () => decline(r),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD64545),
                      side: const BorderSide(color: Color(0xFFD64545), width: 1.5),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: 6),
                        Text('Decline'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String initialOf(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  Widget buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(999))),
              const SizedBox(width: 8),
              const Text('Pending requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
            ],
          ),
          Text('$count ${count == 1 ? 'request' : 'requests'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
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
            CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFFE3F0EE),
              child: Icon(Icons.inbox_outlined, size: 38, color: Color(0xFF0F5C5C)),
            ),
            SizedBox(height: 10),
            Text('No pending requests', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            SizedBox(height: 4),
            Text('New booking requests for your items will show up here.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = AllRentals.pendingFor(ActiveUser.username);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      bottomNavigationBar: const SafeArea(child: BottomNav(current: 2)),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const TopBar(title: 'Booking requests'),
            const SizedBox(height: 16),
            buildSectionHeader(requests.length),

            Expanded(
              child: requests.isEmpty
                  ? buildEmpty()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      children: requests.map(buildRequest).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}