import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/allwallets.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/bottomnav.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


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
  static const Color tealSoft = Color(0xFFE3F0EE);

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
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );

  // One column inside the stats card
  Widget buildStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: teal)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
        ],
      ),
    );
  }

  String initialOf(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  List<Map<String, dynamic>> reviewsFor(String username) {
    return AllReviews.reviews.where((v) => v['to'] == username).toList().reversed.toList();
  }

  Widget buildStars(int score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(Icons.star_rounded, size: 14, color: i < score ? teal : const Color(0xFFD5E3E0))),
    );
  }

  Widget buildReview(Map<String, dynamic> v) {
    final from = AllUsers.byUsername(v['from']);
    final name = (from?['fullname'] ?? v['from']).toString();
    final comment = (v['comment'] ?? '').toString();
    final role = v['role'] == 'lender' ? 'As lender' : 'As borrower';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardStyle(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
                child: Text(initialOf(name), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        buildStars(v['score'] as int),
                        const SizedBox(width: 8),
                        Text(role, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: gray)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8E6)),
            ),
            Text(comment, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ink, height: 1.45)),
          ],
        ],
      ),
    );
  }

  Widget buildReviewsSection(String username) {
    final list = reviewsFor(username);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
              Text(list.length == 1 ? '1 review' : '${list.length} reviews', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
            ],
          ),
        ),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.star_outline_rounded, size: 44, color: Color(0xFFB5C2BF)),
                  SizedBox(height: 10),
                  Text('No reviews yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                  SizedBox(height: 4),
                  Text('Reviews from completed rentals show up here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                ],
              ),
            ),
          )
        else
          ...list.map(buildReview),
      ],
    );
  }

  Widget buildDivider() {
    return Container(width: 1, height: 34, color: const Color(0xFFE3E8E6));
  }

  Widget buildTag(String text, bool good) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: good ? tealSoft : const Color(0xFFF1F3F2), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(good ? Icons.verified_outlined : Icons.schedule, size: 13, color: good ? teal : gray),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: good ? teal : gray)),
        ],
      ),
    );
  }

  Widget buildTopUp(String label, int amount) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: ElevatedButton(
          onPressed: () => setState(() => AllWallets.topUp(ActiveUser.username, amount)),
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget buildWalletCard() {
    final me = ActiveUser.username;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardStyle(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_outlined, size: 19, color: teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('P-wallet ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: gray)),
                    const SizedBox(height: 1),
                    Text(AppSettings.peso(AllWallets.available(me)), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Held for open rentals ${AppSettings.peso(AllWallets.held(me))}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
          const SizedBox(height: 14),
          Row(
            children: [
              buildTopUp('+₱1,000', 1000),
              const SizedBox(width: 8),
              buildTopUp('+₱5,000', 5000),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMenuRow(IconData icon, String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route).then((_) => setState(() {})),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: cardStyle(18),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                child: Icon(icon, size: 19, color: teal),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink))),
              const Icon(Icons.chevron_right, size: 22, color: gray),
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
        top: false, // TopBar handles the status bar itself
        child: Column(
          children: [
            // Shared top bar: back arrow only on someone else's profile
            TopBar(title: 'Profile', showBack: !isOwn),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Identity card: avatar placeholder, name, member since, verified tag
                    Container(
                      padding: const EdgeInsets.all(16),
                      // Soft mint-to-white gradient so the identity card stands out from the others
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFD5EFE6), Colors.white],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [BoxShadow(color: Color(0x330F5C5C), blurRadius: 10, offset: Offset(0, 4))],
                            ),
                            child: Text(initialOf(user['fullname'].toString()), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
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
                          buildDivider(),
                          buildStat(borrower == null ? '–' : borrower.toStringAsFixed(1), 'Borrower rating'),
                          buildDivider(),
                          buildStat('${rentalCount(username)}', 'Rentals'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isOwn) ...[
                      buildWalletCard(),
                      const SizedBox(height: 12),
                    ],
                    if (isOwn) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(2, 8, 0, 12),
                        child: Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
                      ),
                      buildMenuRow(Icons.person_outline, 'Edit profile', '/editprofile'),
                      buildMenuRow(Icons.favorite_border, 'Saved items', '/saveditems'),
                      buildMenuRow(Icons.location_on_outlined, 'My addresses', '/myaddresses'),
                      buildMenuRow(Icons.flag_outlined, 'My reports', '/myreports'),
                    ],
                    buildReviewsSection(username),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('Log out'),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}