import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const ItemCard({super.key, required this.item, required this.onTap});


  static IconData iconFor(String category) => ItemPhoto.iconFor(category);

   @override
  Widget build(BuildContext context) {
    final rating = AllItems.ratingOf(item['id']);
    final availability = AllItems.availabilityOf(item['id']);
    final available = availability == 'Available';
    final ownerName = AllUsers.byUsername(item['owner'])?['fullname'];
    final host = (ownerName ?? item['owner'])?.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                ItemPhoto(item: item, height: 108, width: double.infinity, iconSize: 32),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F5C5C),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '₱${item['dailyRate']}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                        const TextSpan(text: ' /day', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xCCFFFFFF))),
                      ]),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name
                  Text(item['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1B2626))),
                  const SizedBox(height: 4),

                  // Star rating, or a muted note when there are no reviews
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: rating == null ? const Color(0xFFC5CFCD) : const Color(0xFFF5A623)),
                      const SizedBox(width: 3),
                      Text(rating == null ? 'No reviews yet' : rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6A7776))),
                    ],
                  ),

                  // Host row (only if the item has an owner)
                  if (host != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: Color(0xFF6A7776)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text('Hosted by $host',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6A7776))),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Availability tag
                  StatusTag(text: availability, attention: !available),
                  const SizedBox(height: 10),

                  // Button look only; the whole card is tappable, so it opens the item
                  Container(
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: available ? const Color(0xFF0F5C5C) : Colors.transparent,
                      border: available ? null : Border.all(color: const Color(0xFF0F5C5C), width: 1.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(available ? 'Rent Now' : 'View details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: available ? Colors.white : const Color(0xFF0F5C5C),
                        )),
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