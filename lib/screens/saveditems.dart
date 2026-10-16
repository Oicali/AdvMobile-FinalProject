import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allsaved.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

// Widget class (XState naming convention)
class SavedItemsState extends StatefulWidget {
  const SavedItemsState({super.key});

  @override
  State<SavedItemsState> createState() => SavedItemsPage();
}

// State class (XPage naming convention)
class SavedItemsPage extends State<SavedItemsState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // My saved rows turned into live items; deleted listings are skipped
  List<Map<String, dynamic>> get items {
    return AllSaved.saved
        .where((s) => s['username'] == ActiveUser.username)
        .map((s) => AllItems.byId(s['itemId'] as String))
        .whereType<Map<String, dynamic>>()
        .where((i) => i['listed'] == true)
        .toList();
  }

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  // Small pill button; filled = primary
  Widget buildPill(String label, VoidCallback onTap, {bool filled = false}) {
    const shape = StadiumBorder();
    const text = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
    const size = Size(0, 38);
    const pad = EdgeInsets.symmetric(horizontal: 22);
    return filled
        ? ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: teal, foregroundColor: Colors.white, elevation: 0, shape: shape, minimumSize: size, padding: pad, textStyle: text),
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(foregroundColor: teal, side: const BorderSide(color: teal, width: 1.5), shape: shape, minimumSize: size, padding: pad, textStyle: text),
            child: Text(label),
          );
  }

  // One saved item card: tap opens details; Rent only while the item is free
  Widget buildSaved(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final availability = AllItems.availabilityOf(id);
    final free = availability == 'Available';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/itemdetails', arguments: id).then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: cardStyle(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemPhoto(item: item, width: 84, height: 84, radius: 16, iconSize: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + availability tag
                  Row(
                    children: [
                      Expanded(child: Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
                      const SizedBox(width: 8),
                      StatusTag(text: availability, attention: !free),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${AppSettings.peso(item['dailyRate'])} / day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  const SizedBox(height: 10),

                  // Actions
                  Row(
                    children: [
                      if (free) ...[
                        buildPill('Rent', () => Navigator.pushNamed(context, '/rentrequest', arguments: id).then((_) => setState(() {})), filled: true),
                        const SizedBox(width: 8),
                      ],
                      buildPill('Remove', () => setState(() => AllSaved.toggle(ActiveUser.username, id))),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
          const Text('Your favorites', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
          Text('$count ${count == 1 ? 'item' : 'items'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 44, color: Color(0xFFB5C2BF)),
            const SizedBox(height: 10),
            const Text('Nothing saved yet', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 4),
            const Text('Tap the heart on any listing to keep it here.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
            const SizedBox(height: 16),
            buildPill('Browse items', () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false), filled: true),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = items;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned shared top bar (back arrow, logo, big title)
            const TopBar(title: 'Saved items'),
            const SizedBox(height: 16),

            buildSectionHeader(list.length),
            Expanded(
              child: list.isEmpty
                  ? buildEmpty()
                  : ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 16), children: list.map(buildSaved).toList()),
            ),
          ],
        ),
      ),
    );
  }
}