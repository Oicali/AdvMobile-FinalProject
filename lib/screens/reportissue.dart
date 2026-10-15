import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/dashedbox.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/itemcard.dart';

// Widget class (XState naming convention)
class ReportIssueState extends StatefulWidget {
  const ReportIssueState({super.key});

  @override
  State<ReportIssueState> createState() => ReportIssuePage();
}

// State class (XPage naming convention)
class ReportIssuePage extends State<ReportIssueState> {
  final TextEditingController detailsCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final List<String> reasons = ['Item damaged', 'Item not returned', 'A charge is wrong', 'Other'];
  final Map<String, String> errors = {};
  Map<String, dynamic>? rental;
  String? reason;
  bool loaded = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

  // Read the rental id once and look the rental up
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    rental = arg is String ? AllRentals.byId(arg) : null;
  }

  // Free the controllers when the screen is removed
  @override
  void dispose() {
    detailsCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  bool get isLender => rental!['lender'] == ActiveUser.username;

  // Lenders claim a money amount for damage or a missing item
  bool get needsAmount => isLender && (reason == 'Item damaged' || reason == 'Item not returned');

  // Borrowers disputing a charge contest everything taken from their deposit so far
  bool get disputesCharge => !isLender && reason == 'A charge is wrong';
  int get chargeAmount => RentalFees.deposit(rental!) - RentalFees.depositRefund(rental!);

  // Validate, create the dispute, and open it
  void submit() {
    final r = rental!;
    final details = detailsCtrl.text.trim();
    int amount = 0;

    setState(() {
      errors.clear();
      if (reason == null) errors['reason'] = 'Pick what happened.';
      if (details.isEmpty) errors['details'] = 'Tell us what happened.';

      if (needsAmount) {
        final a = int.tryParse(amountCtrl.text.replaceAll(',', '').trim());
        if (a == null || a < 1 || a > RentalFees.deposit(r)) {
          errors['amount'] = 'Enter an amount from ₱1 to ${AppSettings.peso(RentalFees.deposit(r))}.';
        } else {
          amount = a;
        }
      } else if (disputesCharge) {
        amount = chargeAmount;
        if (amount <= 0) errors['form'] = 'There is no charge on this rental to dispute.';
      }

      if (errors.isEmpty && AllDisputes.hasOpen(ActiveUser.username, r['id'])) {
        errors['form'] = 'You already have an open report on this rental. Find it under Profile > My reports.';
      }
    });
    if (errors.isNotEmpty) return;

    final id = AllDisputes.newId();
    AllDisputes.disputes.add({
      'id': id,
      'rentalId': r['id'],
      'filedBy': ActiveUser.username,
      'reason': reason,
      'message': details,
      'reply': '',
      'amount': amount,
      'status': 'Submitted',
      'outcome': '',
      'filedOn': AppSettings.demoDate,
    });

    // Replace this screen so Back returns to the rental, not the form
    Navigator.pushReplacementNamed(context, '/disputedetails', arguments: id);
  }

  // Clears one error as soon as the user fixes it
  void clearError(String key) {
    if (errors.containsKey(key) || errors.containsKey('form')) {
      setState(() {
        errors.remove(key);
        errors.remove('form');
      });
    }
  }

  // One radio row
  Widget buildReason(String label) {
    final selected = reason == label;
    return InkWell(
      onTap: () => setState(() {
        reason = label;
        errors.remove('reason');
        errors.remove('amount');
        errors.remove('form');
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: selected ? teal : gray),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = rental;
    if (r == null) return const Scaffold(body: Center(child: Text('Rental not found.')));
    final item = AllItems.byId(r['itemId']);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Screen title
                    const Text('Report an issue', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                    const SizedBox(height: 16),

                    // Which rental this is about
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: const Color(0xFFE3E8E6), borderRadius: BorderRadius.circular(14)),
                            child: Icon(ItemCard.iconFor(item?['category'] ?? ''), size: 22, color: const Color(0xFFB5C2BF)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item?['name'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                              const SizedBox(height: 2),
                              Text('Rented ${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Reason radios
                    const Padding(
                      padding: EdgeInsets.only(left: 2, bottom: 4),
                      child: Text('What happened?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
                    ),
                    ...reasons.map(buildReason),
                    if (errors['reason'] != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 2, top: 4),
                        child: Text(errors['reason']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                      ),
                    const SizedBox(height: 14),

                    // Lender: how much they are claiming
                    if (needsAmount) ...[
                      InputField(
                        label: 'Amount you are claiming (₱)',
                        controller: amountCtrl,
                        hint: 'Up to ${AppSettings.peso(RentalFees.deposit(r))}',
                        keyboard: TextInputType.number,
                        errorText: errors['amount'],
                        onChanged: (_) => clearError('amount'),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Borrower: the amount is whatever was taken from the deposit
                    if (disputesCharge) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 14),
                        child: Text('Amount in question: ${AppSettings.peso(chargeAmount)} (late fee and damage taken from your deposit)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray, height: 1.4)),
                      ),
                    ],

                    // Details
                    InputField(
                      label: 'Details',
                      controller: detailsCtrl,
                      hint: 'Explain what happened and when',
                      keyboard: TextInputType.multiline,
                      maxLines: 4,
                      errorText: errors['details'],
                      onChanged: (_) => clearError('details'),
                    ),
                    const SizedBox(height: 14),

                    // Simulated photos
                    DashedBox(
                      text: 'Add photos (placeholder)',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo upload is simulated in this demo.'))),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned: form-level error + submit / cancel
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  if (errors['form'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(errors['form']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Submit report'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: teal,
                        side: const BorderSide(color: teal, width: 1.5),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Cancel'),
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