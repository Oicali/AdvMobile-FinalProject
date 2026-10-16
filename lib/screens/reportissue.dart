import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/dashedbox.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

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
  final Map<String, String> errors = {};
  Map<String, dynamic>? rental;
  String? reason;
  bool loaded = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);
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

  List<String> get reasons => isLender ? ['Item damaged', 'Item not returned'] : ['A charge is wrong', 'Other'];

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

  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

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

  Widget buildSummary(Map<String, dynamic> r, Map<String, dynamic>? item) {
    final days = AppSettings.daysBetween(r['start'], r['end']);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemPhoto(item: item ?? <String, dynamic>{}, width: 84, height: 84, radius: 16, iconSize: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item?['name'] ?? 'Item',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3)),
                const SizedBox(height: 8),
                StatusTag(text: isLender ? 'You are the lender' : 'You are the borrower'),
                const SizedBox(height: 8),
                Text('${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])} · $days ${days == 1 ? 'day' : 'days'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        top: false,
        child: Column(
          children: [
            const TopBar(title: 'Report an issue'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [


                    buildSummary(r, item),
                    const SizedBox(height: 22),

                    buildSection(Icons.help_outline, 'What happened?'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          for (var i = 0; i < reasons.length; i++) ...[
                            if (i > 0) const Divider(height: 1, color: Color(0xFFE3E8E6)),
                            buildReason(reasons[i]),
                          ],
                        ],
                      ),
                    ),
                    if (errors['reason'] != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 2, top: 4),
                        child: Text(errors['reason']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                      ),
                    const SizedBox(height: 14),

                    if (needsAmount) ...[
                      buildSection(Icons.payments_outlined, 'Your claim'),
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

                    if (disputesCharge) ...[
                      buildSection(Icons.receipt_long_outlined, 'Charge in question'),
                      Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 14),
                        child: Text('Amount in question: ${AppSettings.peso(chargeAmount)} (late fee and damage taken from your deposit)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray, height: 1.4)),
                      ),
                    ],

                    buildSection(Icons.notes, 'Tell us more'),
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

                    buildSection(Icons.photo_camera_outlined, 'Photos'),
                    DashedBox(
                      text: 'Add photos (simulated)',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo upload is simulated in this demo.'))),
                    ),
                    const SizedBox(height: 16),
                    const Text('Reports are reviewed by a simulated admin in this demo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
                  ],
                ),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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