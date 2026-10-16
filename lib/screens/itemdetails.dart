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


  String availabilityLine(String itemId) {
    final r = AllItems.currentRental(itemId);
    if (r == null) return 'Available now';
    if (r['status'] == 'Overdue') return 'Available once it is returned';
    return 'Available from ${AppSettings.shortDate(r['end'])}';
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

                    ItemPhoto(item: item, height: 280, width: double.infinity, radius: 20, iconSize: 72),
                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3))),
                        const SizedBox(width: 8),
                        StatusTag(text: availability, attention: availability != 'Available'),
                      ],
                    ),
                    const SizedBox(height: 6),


                    const SizedBox(height: 8),


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


                    Text(item['description'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray, height: 1.45)),
                    const SizedBox(height: 8),
                    Text('Condition: ${item['condition']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                    const SizedBox(height: 4),
                    Text(availabilityLine(id), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
            ),

            // Sticky bottom bar: price on the left, actions on the right
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))],
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
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: teal, width: 1.5)),
                        child: Icon(saved ? Icons.favorite : Icons.favorite_border, size: 22, color: teal),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Main action
                    SizedBox(
                      height: 48,
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