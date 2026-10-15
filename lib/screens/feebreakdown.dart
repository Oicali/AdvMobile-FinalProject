import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';

// Widget class (XState naming convention)
class FeeBreakdownState extends StatefulWidget {
  const FeeBreakdownState({super.key});

  @override
  State<FeeBreakdownState> createState() => FeeBreakdownPage();
}

// State class (XPage naming convention)
class FeeBreakdownPage extends State<FeeBreakdownState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

  // One label/value line
  Widget buildRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Flexible(child: Text(label, style: style)), const SizedBox(width: 12), Text(value, style: style)],
      ),
    );
  }

  // Deductions show with a minus sign (₱0 stays plain)
  String minus(int n) => n == 0 ? AppSettings.peso(0) : '− ${AppSettings.peso(n)}';

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final r = arg is String ? AllRentals.byId(arg) : null;
    if (r == null) return const Scaffold(body: Center(child: Text('Rental not found.')));

    final started = ['Active', 'Overdue', 'Returned', 'Completed'].contains(r['status']);
    final days = RentalFees.days(r);
    final lateDays = RentalFees.daysLate(r);
    final perDay = RentalFees.dailyRate(r) * AppSettings.lateFeeMultiplier;
    final late = RentalFees.lateFee(r);
    final damage = RentalFees.damageDeduction(r);
    final delivery = RentalFees.deliveryFee(r);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back arrow + title
                    Row(
                      children: [
                        GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: ink)),
                        const SizedBox(width: 8),
                        const Text('Fee breakdown', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Charges card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          buildRow('Rental fee ($days ${days == 1 ? 'day' : 'days'})', AppSettings.peso(RentalFees.rentalFee(r))),
                          if (delivery > 0) buildRow('Delivery fee', AppSettings.peso(delivery)),
                          buildRow('Late fee ($lateDays ${lateDays == 1 ? 'day' : 'days'} × ${AppSettings.peso(perDay)})', AppSettings.peso(late)),
                          buildRow('Damage deduction', AppSettings.peso(damage)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deposit card: what you paid in, what comes out, what comes back
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          buildRow('Deposit held', AppSettings.peso(RentalFees.deposit(r))),
                          buildRow('Less late fee', minus(late)),
                          if (damage > 0) buildRow('Less damage deduction', minus(damage)),
                          buildRow('Deposit refund', AppSettings.peso(RentalFees.depositRefund(r)), bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Explains the cap and when the refund is released
                    Text(
                      'Late fees are capped at the deposit. ${r['lenderConfirmed'] == true ? 'The refund has been released.' : 'The refund is released after the lender confirms the return.'}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            // Pinned actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      // Replace the stack so My rentals refreshes and back doesn't return here
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/myrentals', (route) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Back to my rentals'),
                    ),
                  ),
                  // Disputing only makes sense once there are charges
                  if (started) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/reportissue', arguments: r['id']),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: teal,
                          side: const BorderSide(color: teal, width: 1.5),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Dispute a charge'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}