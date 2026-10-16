import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
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
  // Condition checklist is visual only (no data key for it); resets when you leave
  final List<bool> checks = [true, true, false];
  final List<String> checkLabels = ['Item matches its description', 'Accessories and charger included', 'Photos taken at return'];

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

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
    if (!ok) return;
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
    if (!ok) return;
    rental!['status'] = 'Cancelled';
    Navigator.pop(context);
  }

  // Timeline rows built from the rental's status (no stored event dates, so only known dates show)
  List<Map<String, dynamic>> buildSteps(Map<String, dynamic> r) {
    final String s = r['status'];
    final started = ['Active', 'Overdue', 'Returned', 'Completed'].contains(s);
    final approved = started || s == 'Approved';
    final returned = s == 'Returned' || s == 'Completed';
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
      {'label': 'Returned by you', 'detail': returned ? AppSettings.shortDate(r['returnedOn']) : 'Due ${AppSettings.shortDate(r['end'])}', 'done': returned},
      {'label': 'Confirmed by lender', 'detail': confirmed ? 'Done' : 'Pending', 'done': confirmed},
    ]);
    return steps;
  }

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  // One timeline row: filled dot when done, hollow when not
  Widget buildStep(Map<String, dynamic> st) {
    final done = st['done'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? teal : Colors.transparent,
              border: Border.all(color: done ? teal : const Color(0xFF98A4A2), width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(st['label'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
          const SizedBox(width: 8),
          Flexible(child: Text(st['detail'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray))),
        ],
      ),
    );
  }

  // Filled / outlined pill buttons used in the pinned action area
  Widget filledButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
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

    if (s == 'Active' || s == 'Overdue') add(filledButton("I've returned it", submitReturn));
    if (s == 'Completed' && !AllReviews.hasReviewed(ActiveUser.username, r['id'])) {
      add(filledButton('Rate this rental', () => Navigator.pushNamed(context, '/ratereview', arguments: r['id']).then((_) => setState(() {}))));
    }
    if (s == 'Requested') add(outlinedButton('Cancel request', cancelRequest));
    if (['Approved', 'Active', 'Overdue', 'Returned', 'Completed'].contains(s)) {
      add(outlinedButton('Report an issue', () => Navigator.pushNamed(context, '/reportissue', arguments: r['id']).then((_) => setState(() {}))));
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
    final showChecklist = ['Approved', 'Active', 'Overdue', 'Returned', 'Completed'].contains(s);
    final showReturnNote = s == 'Active' || s == 'Overdue' || s == 'Returned';

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
                    // Item name as the heading (the arrow now lives in the TopBar)
                    Text(item?['name'] ?? 'Rental', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.4)),
                    const SizedBox(height: 10),

                    // Status tag + the demo date everything is measured against
                    Row(
                      children: [
                        StatusTag(text: s, attention: s == 'Overdue'),
                        const Spacer(),
                        Text('Today (demo date): ${AppSettings.shortDate(AppSettings.demoDate)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                      ],
                    ),
                    const SizedBox(height: 14),

                  
                    if (s == 'Overdue') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFFFE9D6), borderRadius: BorderRadius.circular(20)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: cardStyle(20),
                      child: Column(children: buildSteps(r).map(buildStep).toList()),
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

                    // Condition checklist card
                    if (showChecklist)
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                        decoration: cardStyle(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Condition checklist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ink)),
                            const SizedBox(height: 4),
                            ...List.generate(checks.length, (i) {
                              return InkWell(
                                onTap: () => setState(() => checks[i] = !checks[i]),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(checks[i] ? Icons.check_box : Icons.check_box_outline_blank, size: 22, color: checks[i] ? teal : gray),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(checkLabels[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ink))),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
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

            // Pinned actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: buildActions(r),
            ),
          ],
        ),
      ),
    );
  }
}