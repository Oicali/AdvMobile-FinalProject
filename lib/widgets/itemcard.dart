import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

ItemPhoto(item: item, height: 140, width: double.infinity, iconSize: 34),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1B2626))),
                  const SizedBox(height: 3),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: '₱${item['dailyRate']}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1B2626))),
                    const TextSpan(text: ' / day', style: TextStyle(color: Color(0xFF6A7776))),
                  ]), style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(rating == null ? 'No reviews yet' : 'Rating ${rating.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6A7776))),
                  const SizedBox(height: 8),
                  StatusTag(text: availability, attention: availability != 'Available'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}