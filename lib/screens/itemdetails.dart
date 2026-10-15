import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allsaved.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/itemcard.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';

// Widget class (XState naming convention)
class ItemDetailsState extends StatefulWidget {
  const ItemDetailsState({super.key});

  @override
  State<ItemDetailsState> createState() => ItemDetailsPage();
}

// State class (XPage naming convention)
class ItemDetailsPage extends State<ItemDetailsState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // Text for the "Available ..." line, derived from the current rental
  String availabilityLine(String itemId) {
    final r = AllItems.currentRental(itemId);
    if (r == null) return 'Available now';
    if (r['status'] == 'Overdue') return 'Available once it is returned';
    return 'Available from ${AppSettings.shortDate(r['end'])}';
  }

  @override
  Widget build(BuildContext context) {
    // Argument = item id (String), passed from Browse / Saved items
    final arg = ModalRoute.of(context)?.settings.arguments;
    final item = arg is String ? AllItems.byId(arg) : null;

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found.')));
    }

    final id = item['id'] as String;
    final owner = AllUsers.byUsername(item['owner']);
    final rating = AllReviews.averageFor(item['owner'], 'lender');
    final availability = AllItems.availabilityOf(id);
    final isMine = item['owner'] == ActiveUser.username;
    final saved = AllSaved.isSaved(ActiveUser.username, id);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo placeholder with a back button on top
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(color: const Color(0xFFE3E8E6), borderRadius: BorderRadius.circular(20)),
                          child: Icon(ItemCard.iconFor(item['category']), size: 56, color: const Color(0xFFB5C2BF)),
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.arrow_back, size: 20, color: ink),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Name + availability tag
                    Row(
                      children: [
                        Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3))),
                        const SizedBox(width: 8),
                        StatusTag(text: availability, attention: availability != 'Available'),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Daily rate and refundable deposit
                    Text('${AppSettings.peso(item['dailyRate'])} / day · Deposit ${AppSettings.peso(item['deposit'])}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
                    const SizedBox(height: 14),

                    // Lender card: tap to open their public profile
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile', arguments: item['owner']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(owner?['fullname'] ?? item['owner'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                                  const SizedBox(height: 3),
                                  Text('Lender · ${rating == null ? 'No reviews yet' : 'Rating ${rating.toStringAsFixed(1)}'}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: gray),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description, condition and availability
                    Text(item['description'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray, height: 1.45)),
                    const SizedBox(height: 8),
                    Text('Condition: ${item['condition']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                    const SizedBox(height: 4),
                    Text(availabilityLine(id), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
            ),

            // Pinned actions; your own listing gets a note instead
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: isMine
                  ? const Text("This is your listing. Manage it from the Listings tab.",
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: gray))
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/rentrequest', arguments: id).then((_) => setState(() {})),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            child: const Text('Request to rent'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => setState(() => AllSaved.toggle(ActiveUser.username, id)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: teal,
                              side: const BorderSide(color: teal, width: 1.5),
                              shape: const StadiumBorder(),
                              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            child: Text(saved ? 'Saved' : 'Save item'),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}