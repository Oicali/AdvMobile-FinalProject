import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
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
                        mainAxisExtent: 272,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ItemCard(
                          item: item,

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