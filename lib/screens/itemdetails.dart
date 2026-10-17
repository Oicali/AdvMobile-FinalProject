import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allsaved.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


class ItemDetailsState extends StatefulWidget {
  const ItemDetailsState({super.key});

  @override
  State<ItemDetailsState> createState() => ItemDetailsPage();
}


class ItemDetailsPage extends State<ItemDetailsState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);


  String availabilityLine(String itemId) {
    final r = AllItems.currentRental(itemId);
    if (r == null) return 'Available now';
    if (r['status'] == 'Overdue') return 'Available once it is returned';
    return 'Available from ${AppSettings.shortDate(r['end'])}';
  }

  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );

  String initialOf(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  Widget buildSection(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: teal),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
        ],
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
              const SizedBox(height: 1),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

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
        top: false,
        child: Column(
          children: [

            const TopBar(title: 'Item details'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Shadow wrapper so the photo lifts off the page
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Color(0x290F5C5C), blurRadius: 22, offset: Offset(0, 10))],
                      ),
                      child: ItemPhoto(item: item, height: 280, width: double.infinity, radius: 20, iconSize: 72),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3))),
                        const SizedBox(width: 8),
                        StatusTag(text: availability, attention: availability != 'Available'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Quick-glance chips: category and condition
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in [
                          [Icons.category_outlined, '${item['category']}'],
                          [Icons.verified_outlined, '${item['condition']}'],
                        ])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: tealSoft, borderRadius: BorderRadius.circular(999)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(c[0] as IconData, size: 14, color: teal),
                                const SizedBox(width: 5),
                                Text(c[1] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: teal)),
                              ],
                            ),
                          ),
                      ],
                    ),


                    const SizedBox(height: 8),


                    const SizedBox(height: 10),
                    buildSection(Icons.person_outline, 'Lender'),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile', arguments: item['owner']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: cardStyle(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
                              child: Text(initialOf((owner?['fullname'] ?? item['owner']).toString()),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(owner?['fullname'] ?? item['owner'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded, size: 15, color: rating == null ? const Color(0xFFC5CFCD) : const Color(0xFFF5A623)),
                                      const SizedBox(width: 3),
                                      Text(rating == null ? 'No reviews yet' : '${rating.toStringAsFixed(1)} lender rating',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: gray),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildSection(Icons.info_outline, 'About this item'),


                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: cardStyle(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['description'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray, height: 1.45)),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8E6)),
                          ),
                          buildInfoRow(Icons.verified_outlined, 'Condition', '${item['condition']}'),
                          const SizedBox(height: 12),
                          buildInfoRow(Icons.category_outlined, 'Category', '${item['category']}'),
                          const SizedBox(height: 12),
                          buildInfoRow(Icons.event_available_outlined, 'Availability', availabilityLine(id)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky bottom bar: price on the left, actions on the right
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(text: AppSettings.peso(item['dailyRate']), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink)),
                          const TextSpan(text: ' / day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                        ])),
                        const SizedBox(height: 2),
                        Text('Deposit ${AppSettings.peso(item['deposit'])}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                      ],
                    ),
                  ),
                  if (isMine)
                    const Text('Your listing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gray))
                  else ...[
                    // Round heart button: tap to save or unsave
                    GestureDetector(
                      onTap: () => setState(() => AllSaved.toggle(ActiveUser.username, id)),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: saved ? tealSoft : Colors.white,
                          border: Border.all(color: teal, width: 1.5),
                        ),
                        child: Icon(saved ? Icons.favorite : Icons.favorite_border, size: 22, color: teal),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Main action
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/rentrequest', arguments: id).then((_) => setState(() {})),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Request to rent'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}