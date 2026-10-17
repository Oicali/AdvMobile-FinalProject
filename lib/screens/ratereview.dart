import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

class RateReviewState extends StatefulWidget {
  const RateReviewState({super.key});

  @override
  State<RateReviewState> createState() => RateReviewPage();
}

class RateReviewPage extends State<RateReviewState> {
  final TextEditingController commentCtrl = TextEditingController();
  Map<String, dynamic>? rental;
  String? target;
  String role = '';
  bool loaded = false;
  int score = 0;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const List<String> scoreLabels = ['Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    rental = arg is String ? AllRentals.byId(arg) : null;
    final r = rental;
    if (r == null) return;
    if (r['borrower'] == ActiveUser.username) {
      target = r['lender'];
      role = 'lender';
    } else if (r['lender'] == ActiveUser.username) {
      target = r['borrower'];
      role = 'borrower';
    }
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  void submit() {
    final r = rental!;
    AllReviews.reviews.add({
      'id': 'v${AllReviews.reviews.length + 1}',
      'rentalId': r['id'],
      'from': ActiveUser.username,
      'to': target,
      'role': role,
      'score': score,
      'comment': commentCtrl.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for your review.')));
    Navigator.pop(context);
  }

  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );

  String initialOf(String name) {
    final n = name.trim();
    return n.isEmpty ? '?' : n[0].toUpperCase();
  }

  Widget buildSection(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: teal),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
        ],
      ),
    );
  }

  Widget buildSummary(Map<String, dynamic> r, Map<String, dynamic>? item, String s) {
    final method = r['method'] == 'delivery' ? 'Delivery' : 'Pickup';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemPhoto(item: item ?? <String, dynamic>{'image': '', 'category': ''}, width: 84, height: 84, radius: 16, iconSize: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item?['name'] ?? 'Rental',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3)),
                const SizedBox(height: 8),
                StatusTag(text: s, attention: s == 'Overdue'),
                const SizedBox(height: 8),
                Text('${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])} · $method',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final on = i < score;
        return GestureDetector(
          onTap: () => setState(() => score = i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            // Selected stars turn gold and grow slightly
            child: AnimatedScale(
              scale: on ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(on ? Icons.star_rounded : Icons.star_outline_rounded, size: 40, color: on ? const Color(0xFFF5A623) : const Color(0xFFB5C2BF)),
            ),
          ),
        );
      }),
    );
  }

  Widget buildRatingCard(String name) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardStyle(20),
      child: Column(
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
                    const SizedBox(height: 2),
                    Text(role == 'lender' ? 'Lender' : 'Borrower', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8E6)),
          ),
          buildStars(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: score == 0 ? const Color(0xFFF1F3F2) : tealSoft, borderRadius: BorderRadius.circular(999)),
            child: Text(score == 0 ? 'Tap a star to rate' : scoreLabels[score - 1],
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: score == 0 ? gray : teal)),
          ),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_outline_rounded, size: 44, color: Color(0xFFB5C2BF)),
            SizedBox(height: 10),
            Text('Nothing to rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            SizedBox(height: 4),
            Text('This rental could not be found.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = rental;
    final who = target;

    if (r == null || who == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              const TopBar(title: 'Rate rental'),
              Expanded(child: buildEmpty()),
            ],
          ),
        ),
      );
    }

    final item = AllItems.byId(r['itemId']);
    final user = AllUsers.byUsername(who);
    final name = user?['fullname']?.toString() ?? who;
    final String s = r['status'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const TopBar(title: 'Rate rental'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSummary(r, item, s),
                    const SizedBox(height: 22),
                    buildSection(Icons.star_outline_rounded, role == 'lender' ? 'Rate your lender' : 'Rate your borrower'),
                    buildRatingCard(name),
                    const SizedBox(height: 22),
                    buildSection(Icons.chat_bubble_outline, 'Add a comment'),
                    InputField(label: 'Comment (optional)', controller: commentCtrl, hint: 'Share how it went', maxLines: 4),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: score == 0 ? null : const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
                ),
                child: ElevatedButton(
                  onPressed: score == 0 ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD5E3E0),
                    disabledForegroundColor: gray,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Submit review'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}