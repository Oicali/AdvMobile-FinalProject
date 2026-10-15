import 'package:flutter/material.dart';

// Flat full-width nav bar with icons: Browse, Rentals, Listings, Profile
class BottomNav extends StatelessWidget {
  final int current;
  const BottomNav({super.key, required this.current});

  static const List<String> labels = ['Browse', 'Rentals', 'Listings', 'Profile'];
  static const List<String> routes = ['/home', '/myrentals', '/mylistings', '/profile'];
  // Outlined icon when idle, filled icon when selected
  static const List<IconData> icons = [Icons.explore_outlined, Icons.inventory_2_outlined, Icons.storefront_outlined, Icons.person_outline];
  static const List<IconData> activeIcons = [Icons.explore, Icons.inventory_2, Icons.storefront, Icons.person];

  static const Color teal = Color(0xFF0F5C5C);
  static const Color gray = Color(0xFF6A7776);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Square corners, white bar, soft shadow on the top edge only
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, -4))],
      ),
      child: Row(
        children: List.generate(4, (i) {
          final active = i == current;
          return Expanded(
            child: InkWell(
              // Replace (not push) so switching tabs never stacks screens
              onTap: () {
                if (!active) Navigator.pushReplacementNamed(context, routes[i]);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Teal line above the active tab
                    Container(
                      height: 3,
                      width: 28,
                      margin: const EdgeInsets.only(bottom: 7),
                      color: active ? teal : Colors.transparent,
                    ),
                    Icon(active ? activeIcons[i] : icons[i], size: 24, color: active ? teal : gray),
                    const SizedBox(height: 3),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                        color: active ? teal : gray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}