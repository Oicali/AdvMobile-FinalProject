import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';
import 'package:advmobile_finalproject/widgets/itemcard.dart';

class HomeState extends StatefulWidget {
  const HomeState({super.key});

  @override
  State<HomeState> createState() => HomePage();
}


class HomePage extends State<HomeState> {
  final TextEditingController searchCtrl = TextEditingController();
  final List<String> categories = ['All', 'Cameras', 'Tools', 'Camping', 'Electronics'];
  String selectedCategory = 'All';
  String query = '';

  static const Color teal = Color(0xFF0F5C5C);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);


  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }


  List<Map<String, dynamic>> get visibleItems {
    return AllItems.items.where((i) {
      final matchesCategory = selectedCategory == 'All' || i['category'] == selectedCategory;
      final matchesQuery = i['name'].toString().toLowerCase().contains(query.trim().toLowerCase());
      final notMine = i['owner'] != ActiveUser.username;
      return i['listed'] == true && notMine && matchesCategory && matchesQuery;
    }).toList();
  }


  // Icon shown inside each category chip
  IconData chipIcon(String label) {
    switch (label) {
      case 'Cameras':
        return Icons.camera_alt_outlined;
      case 'Tools':
        return Icons.handyman_outlined;
      case 'Camping':
        return Icons.terrain;
      case 'Electronics':
        return Icons.headphones_outlined;
      default:
        return Icons.apps;
    }
  }

  // Category chip: icon + label, filled teal when selected
  Widget buildChip(String label) {
    final selected = label == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(color: selected ? teal : tealSoft, borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(chipIcon(label), size: 15, color: selected ? Colors.white : teal),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : teal)),
            ],
          ),
        ),
      ),
    );
  }

  // Greeting with the logged-in user's first name
  Widget buildGreeting() {
    final user = AllUsers.byUsername(ActiveUser.username);
    final first = (user?['fullname'] ?? ActiveUser.username).toString().split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi, $first', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.4)),
          const SizedBox(height: 2),
          const Text('What do you need today?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)),
        ],
      ),
    );
  }

  // Promo card that sends the user to post an item
  Widget buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [teal, Color(0xFF2A8C80)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: Container(width: 120, height: 120, decoration: const BoxDecoration(color: Color(0x1FFFFFFF), shape: BoxShape.circle)),
            ),
            Positioned(
              bottom: -40,
              right: 70,
              child: Container(width: 90, height: 90, decoration: const BoxDecoration(color: Color(0x14FFFFFF), shape: BoxShape.circle)),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Got something sitting around?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('List it and earn a daily rate while others borrow it.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD6ECE6), height: 1.4)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/postedititem').then((_) => setState(() {})),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: teal,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('List an item'),
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

  // "Available to rent" title with the number of matching items
  Widget buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Available to rent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
          Text('$count ${count == 1 ? 'item' : 'items'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
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
            Icon(Icons.search_off, size: 44, color: Color(0xFFB5C2BF)),
            SizedBox(height: 10),
            Text('No items found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            SizedBox(height: 4),
            Text('Try another word or category.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
          ],
        ),
      ),
    );
  }

  Widget buildSearch() {
    return TextField(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = visibleItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      bottomNavigationBar: const SafeArea(child: BottomNav(current: 0)),
      body: SafeArea(
        top: false, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TopBar(
              onReturn: () => setState(() {}),
              child: buildSearch(),
            ),
            const SizedBox(height: 16),




            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: categories.map(buildChip).toList()),
            ),
            const SizedBox(height: 16),


            // Greeting, banner, section title and grid scroll together
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: buildGreeting()),
                  SliverToBoxAdapter(child: buildBanner()),
                  SliverToBoxAdapter(child: buildSectionHeader(items.length)),
                  if (items.isEmpty)
                    SliverFillRemaining(hasScrollBody: false, child: buildEmpty())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 284,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = items[index];
                            return ItemCard(
                              item: item,
                              onTap: () => Navigator.pushNamed(context, '/itemdetails', arguments: item['id'])
                                  .then((_) => setState(() {})),
                            );
                          },
                          childCount: items.length,
                        ),
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