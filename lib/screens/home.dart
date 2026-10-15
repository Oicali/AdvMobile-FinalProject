import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/itemcard.dart';

// Widget class (XState naming convention)
class HomeState extends StatefulWidget {
  const HomeState({super.key});

  @override
  State<HomeState> createState() => HomePage();
}

// State class (XPage naming convention)
class HomePage extends State<HomeState> {
  final TextEditingController searchCtrl = TextEditingController();
  final List<String> categories = ['All', 'Cameras', 'Tools', 'Camping', 'Electronics'];
  String selectedCategory = 'All';
  String query = '';

  static const Color teal = Color(0xFF0F5C5C);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // Free the controller when the screen is removed
  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // Listed items, not mine, matching the chip and search text
  List<Map<String, dynamic>> get visibleItems {
    return AllItems.items.where((i) {
      final matchesCategory = selectedCategory == 'All' || i['category'] == selectedCategory;
      final matchesQuery = i['name'].toString().toLowerCase().contains(query.trim().toLowerCase());
      final notMine = i['owner'] != ActiveUser.username;
      return i['listed'] == true && notMine && matchesCategory && matchesQuery;
    }).toList();
  }

  // One category chip (selected = solid teal)
  Widget buildChip(String label) {
    final selected = label == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: selected ? teal : tealSoft, borderRadius: BorderRadius.circular(999)),
          child: Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : teal)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = visibleItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      bottomNavigationBar: const SafeArea(child: BottomNav(current: 0)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen title
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 14),
              child: Text('Browse', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
            ),

            // Search bar (filters the grid as you type)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: searchCtrl,
                onChanged: (v) => setState(() => query = v),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ink),
                decoration: InputDecoration(
                  hintText: 'Search items to rent',
                  hintStyle: const TextStyle(color: Color(0xFF98A4A2)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: gray),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Category chips (scroll sideways if they overflow)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: categories.map(buildChip).toList()),
            ),
            const SizedBox(height: 16),

            // Item grid, or an empty message when nothing matches
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No items match. Try another word or category.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 232,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ItemCard(
                          item: item,
                          // Pass only the id; the details screen looks the item up itself
                          onTap: () => Navigator.pushNamed(context, '/itemdetails', arguments: item['id'])
                              .then((_) => setState(() {})),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}