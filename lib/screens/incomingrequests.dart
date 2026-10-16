import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

// Widget class (XState naming convention)
class IncomingRequestsState extends StatefulWidget {
  const IncomingRequestsState({super.key});

  @override
  State<IncomingRequestsState> createState() => IncomingRequestsPage();
}

// State class (XPage naming convention)
class IncomingRequestsPage extends State<IncomingRequestsState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // Why this request can't be approved right now (null = fine)
  String? conflictFor(Map<String, dynamic> r) {
    for (final o in AllRentals.rentals) {
      if (o['id'] == r['id'] || o['itemId'] != r['itemId']) continue;
      final s = o['status'];
      if (s == 'Overdue') return "This item hasn't been returned yet.";
      if ((s == 'Approved' || s == 'Active') && (r['start'] as String).compareTo(o['end']) < 0 && (r['end'] as String).compareTo(o['start']) > 0) {
        return 'Overlaps another rental (${AppSettings.shortDate(o['start'])} to ${AppSettings.shortDate(o['end'])}).';
      }
    }
    return null;
  }

  // Approve unless it clashes; then promote to Active if the start date has arrived
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

  // Decline the request
  void decline(Map<String, dynamic> r) {
    setState(() => r['status'] = 'Declined');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request declined.')));
  }

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  // One request card: borrower + rating, item, dates, how + total, Approve / Decline
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
          // Borrower name (opens their public profile) + borrower rating
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile', arguments: r['borrower']),
                  child: Text(borrower?['fullname'] ?? r['borrower'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                ),
              ),
              StatusTag(text: rating == null ? 'No reviews yet' : 'Rating ${rating.toStringAsFixed(1)}'),
            ],
          ),
          const SizedBox(height: 6),
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemPhoto(item: item ?? <String, dynamic>{}, width: 52, height: 52, radius: 14, iconSize: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item?['name'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
                    const SizedBox(height: 3),
                    Text('${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])} · $days ${days == 1 ? 'day' : 'days'}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                    const SizedBox(height: 3),
                    Text('$how · Total ${AppSettings.peso(AllItems.totalDue(r))} incl. deposit',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Approve (filled) / Decline (outlined)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () => approve(r),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Approve'),
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
                      foregroundColor: teal,
                      side: const BorderSide(color: teal, width: 1.5),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
              ),
            ],
          ),
        ],
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
            // Pinned shared top bar (back arrow, logo, big title)
            const TopBar(title: 'Requests'),
            const SizedBox(height: 16),

            // Request cards, or an empty message
            Expanded(
              child: requests.isEmpty
                  ? const Center(
                      child: Text('No pending requests.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)),
                    )
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