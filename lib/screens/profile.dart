import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';


// Widget class (XState naming convention); serves own AND public profile
class ProfileState extends StatefulWidget {
  const ProfileState({super.key});

  @override
  State<ProfileState> createState() => ProfilePage();
}

// State class (XPage naming convention)
class ProfilePage extends State<ProfileState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // Sign out and clear the whole stack so back can't re-enter the app
  void logout() {
    ActiveUser.username = null;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // Completed rentals where the user was borrower or lender
  int rentalCount(String username) {
    return AllRentals.rentals.where((r) => r['status'] == 'Completed' && (r['borrower'] == username || r['lender'] == username)).length;
  }

  // Shared white rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  // One column inside the stats card
  Widget buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
        ],
      ),
    );
  }

  // One tappable row; refreshes this screen when you come back
  Widget buildMenuRow(String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route).then((_) => setState(() {})),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: cardStyle(16),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink))),
              const Icon(Icons.chevron_right, size: 18, color: gray),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Argument = username to show; none = my own profile
    final arg = ModalRoute.of(context)?.settings.arguments;
    final username = arg is String ? arg : ActiveUser.username;
    final isOwn = username == ActiveUser.username;
    final user = AllUsers.byUsername(username);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found.')));
    }

    final lender = AllReviews.averageFor(username!, 'lender');
    final borrower = AllReviews.averageFor(username, 'borrower');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      // Tab bar only on my own profile; public view has a back arrow instead
      bottomNavigationBar: isOwn ? const SafeArea(child: BottomNav(current: 3)) : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (with back arrow on someone else's profile)
                    Row(
                      children: [
                        if (!isOwn)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: ink)),
                          ),
                        const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Identity card: avatar placeholder, name, member since, verified tag
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: cardStyle(20),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 32, backgroundColor: Color(0xFFE3E8E6), child: Icon(Icons.person, size: 30, color: Color(0xFFB5C2BF))),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['fullname'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
                                const SizedBox(height: 2),
                                Text('Member since ${AppSettings.monthYear(user['joined'])}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Stats card: lender rating, borrower rating, completed rentals
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: cardStyle(20),
                      child: Row(
                        children: [
                          buildStat(lender == null ? '–' : lender.toStringAsFixed(1), 'Lender rating'),
                          buildStat(borrower == null ? '–' : borrower.toStringAsFixed(1), 'Borrower rating'),
                          buildStat('${rentalCount(username)}', 'Rentals'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Menu rows: own profile only
                    if (isOwn) ...[
                      buildMenuRow('Edit profile', '/editprofile'),
                      buildMenuRow('Saved items', '/saveditems'),
                      buildMenuRow('My addresses', '/myaddresses'),
                      buildMenuRow('My reports', '/myreports'),
                    ],
                  ],
                ),
              ),
            ),

            // Log out pinned above the tab bar (own profile only)
            if (isOwn)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: teal,
                      side: const BorderSide(color: teal, width: 1.5),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Log out'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}