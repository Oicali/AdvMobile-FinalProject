import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/allwallets.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

// Widget class (XState naming convention)
class RentalDetailsState extends StatefulWidget {
  const RentalDetailsState({super.key});

  @override
  State<RentalDetailsState> createState() => RentalDetailsPage();
}

// State class (XPage naming convention)
class RentalDetailsPage extends State<RentalDetailsState> {
  Map<String, dynamic>? rental;
  bool loaded = false;


  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);
  static const Color tealSoft = Color(0xFFE3F0EE);

  // Read the rental id once, bring statuses up to date, then look the rental up
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    AllRentals.syncStatuses();
    final arg = ModalRoute.of(context)?.settings.arguments;
    rental = arg is String ? AllRentals.byId(arg) : null;
  }

  // Generic yes/no dialog; true only if confirmed and the screen is still alive
  Future<bool> confirm(String title, String body, String yes, {bool danger = false}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not yet')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(yes, style: TextStyle(color: danger ? error : teal))),
        ],
      ),
    );
    return ok == true && mounted;
  }

  // Step 1 of a return: the borrower says it's returned; the lender confirms later
  Future<void> submitReturn() async {
    final r = rental!;
    final ok = await confirm(
      'Submit your return?',
      'Your lender will check the item and confirm it. Late days stop counting as of today (${AppSettings.shortDate(AppSettings.demoDate)}).',
      "I've returned it",
    );
    if (!ok || !mounted) return;
    setState(() {
      r['returnedOn'] = AppSettings.demoDate;
      r['status'] = 'Returned';
      r['lenderConfirmed'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return submitted. Waiting for the lender to confirm.')));
  }

  // Withdraw a pending request, then leave this screen
  Future<void> cancelRequest() async {
    final ok = await confirm('Cancel this request?', 'Your request will be withdrawn.', 'Cancel request', danger: true);
    if (!ok || !mounted) return;
    rental!['status'] = 'Cancelled';
    Navigator.pop(context);
  }

  // Timeline rows built from the rental's status (no stored event dates, so only known dates show)
  List<Map<String, dynamic>> buildSteps(Map<String, dynamic> r) {
    final String s = r['status'];
    final started = ['Active', 'Overdue', 'Returned', 'Completed'].contains(s);
    final approved = started || s == 'Approved';
    final returned = s == 'Returned' || s == 'Completed';
    final closed = s == 'Completed' && (r['returnedOn'] as String).isEmpty;
    final confirmed = r['lenderConfirmed'] == true;
    final start = AppSettings.shortDate(r['start']);

    final steps = <Map<String, dynamic>>[
      {'label': 'Requested', 'detail': '', 'done': true},
    ];
    if (s == 'Declined') {
      steps.add({'label': 'Declined by owner', 'detail': '', 'done': true});
      return steps;
    }
    if (s == 'Cancelled') {
      steps.add({'label': 'Cancelled by you', 'detail': '', 'done': true});
      return steps;
    }
    steps.addAll([
      {'label': 'Approved', 'detail': '', 'done': approved},
      {'label': r['method'] == 'delivery' ? 'Delivered' : 'Picked up', 'detail': started ? start : 'Starts $start', 'done': started},
      {'label': closed ? 'Not returned' : 'Returned by you', 'detail': closed ? 'Closed by lender' : (returned ? AppSettings.shortDate(r['returnedOn']) : 'Due ${AppSettings.shortDate(r['end'])}'), 'done': returned},
      {'label': 'Confirmed by lender', 'detail': confirmed ? 'Done' : 'Pending', 'done': confirmed},
    ]);
    return steps;
  }

  String paymentLabel(Map<String, dynamic> r) => r['payment'] == 'cash' ? 'Cash (simulated)' : 'P-wallet (simulated)';

  String pickupAddress(Map<String, dynamic> r) {
    final list = AllAddresses.ownedBy(r['lender']);
    if (list.isEmpty) return 'Lender will share the pickup location';
    final a = list.firstWhere((x) => x['isDefault'] == true, orElse: () => list.first);
    return '${a['street']}, ${a['barangay']}, ${a['city']}';
  }

  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );

  Widget buildStep(Map<String, dynamic> st, bool isLast) {
    final done = st['done'] == true;
    final String detail = st['detail'];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 14,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? teal : Colors.white,
                    border: Border.all(color: done ? teal : const Color(0xFF98A4A2), width: 2),
                  ),
                  // White check inside finished steps
                  child: done ? const Icon(Icons.check, size: 9, color: Colors.white) : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: done ? teal : const Color(0xFFD5E3E0))),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(st['label'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: done ? ink : gray)),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(detail, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 0, 12),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(999))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
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

  // Filled / outlined pill buttons used in the pinned action area
  Widget filledButton(String label, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }

  Widget outlinedButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: teal,
          side: const BorderSide(color: teal, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }

  // Which buttons show depends on where the rental is in its life
  Widget buildActions(Map<String, dynamic> r) {
    final String s = r['status'];
    final buttons = <Widget>[];
    void add(Widget w) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(height: 12));
      buttons.add(w);
    }

    if ((s == 'Active' || s == 'Overdue') && r['borrower'] == ActiveUser.username) add(filledButton("I've returned it", submitReturn));
    if (s == 'Completed' && !AllReviews.hasReviewed(ActiveUser.username, r['id'])) {
      add(filledButton('Rate this rental', () => Navigator.pushNamed(context, '/ratereview', arguments: r['id']).then((_) => setState(() {}))));
    }
    if (s == 'Requested') add(outlinedButton('Cancel request', cancelRequest));
    if (['Approved', 'Active', 'Overdue', 'Returned', 'Completed'].contains(s)) {
      final mine = AllDisputes.forRental(r['id']).where((d) => d['filedBy'] == ActiveUser.username).toList();
      if (mine.isEmpty) {
        add(outlinedButton('Report an issue', () => Navigator.pushNamed(context, '/reportissue', arguments: r['id']).then((_) => setState(() {}))));
      } else {
        add(outlinedButton('View my report · ${mine.first['status']}', () => Navigator.pushNamed(context, '/disputedetails', arguments: mine.first['id']).then((_) => setState(() {}))));
      }
    }
    return Column(children: buttons);
  }

  @override
  Widget build(BuildContext context) {
    final r = rental;
    if (r == null) return const Scaffold(body: Center(child: Text('Rental not found.')));

    final item = AllItems.byId(r['itemId']);
    final String s = r['status'];
    final started = ['Active', 'Overdue', 'Returned', 'Completed'].contains(s);

    final showReturnNote = s == 'Active' || s == 'Overdue' || s == 'Returned';
    final steps = buildSteps(r);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false, // TopBar handles the status bar itself
        child: Column(
          children: [
            // Shared top bar (back arrow, logo, title)
            const TopBar(title: 'Rental details'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSummary(r, item, s),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text('Today (simulated demo date): ${AppSettings.shortDate(AppSettings.demoDate)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                    ),
                    const SizedBox(height: 16),

                    // Overdue banner with late fee and refund so far
                    if (s == 'Overdue') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9D6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8893A), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${RentalFees.daysLate(r)} ${RentalFees.daysLate(r) == 1 ? 'day' : 'days'} late',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF7A3A0B))),
                            const SizedBox(height: 6),
                            Text('Late fee: ${AppSettings.peso(RentalFees.lateFee(r))}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A3A0B))),
                            const SizedBox(height: 2),
                            Text('Deposit refund if returned today: ${AppSettings.peso(RentalFees.depositRefund(r))}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF7A3A0B))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: cardStyle(16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                            child: const Icon(Icons.person_outline, size: 18, color: teal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lender', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                                const SizedBox(height: 1),
                                Text(AllUsers.byUsername(r['lender'])?['fullname'] ?? r['lender'],
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                                const SizedBox(height: 2),
                                Text('@${r['lender']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (r['method'] == 'pickup' && ['Approved', 'Active', 'Overdue'].contains(s)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: cardStyle(16),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                              child: const Icon(Icons.location_on_outlined, size: 18, color: teal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pickup address', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                                  const SizedBox(height: 1),
                                  Text(pickupAddress(r), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: cardStyle(16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                            child: Icon(r['payment'] == 'cash' ? Icons.money : Icons.account_balance_wallet_outlined, size: 18, color: teal),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Payment method', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                                const SizedBox(height: 1),
                                Text(paymentLabel(r), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                                if (AllWallets.stateOf(r).isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(AllWallets.stateOf(r), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: teal)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildSectionTitle('Progress'),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: cardStyle(20),
                      child: Column(
                        children: [
                          for (var i = 0; i < steps.length; i++) buildStep(steps[i], i == steps.length - 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Link to the fee breakdown (only once the rental has started)
                    if (started)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/feebreakdown', arguments: r['id']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: cardStyle(16),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                                child: const Icon(Icons.receipt_long_outlined, size: 18, color: teal),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('Fee breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
                              Text(
                                s == 'Overdue' ? 'Late fee ${AppSettings.peso(RentalFees.lateFee(r))}' : 'Refund ${AppSettings.peso(RentalFees.depositRefund(r))}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: s == 'Overdue' ? const Color(0xFF7A3A0B) : gray),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right, size: 18, color: gray),
                            ],
                          ),
                        ),
                      ),

                    // Explains the two-step return
                    if (showReturnNote) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'You submit the return. The lender checks the item and confirms it, and only then is your deposit released.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (s != 'Declined' && s != 'Cancelled')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
                ),
                child: buildActions(r),
              ),
          ],
        ),
      ),
    );
  }
}