import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


class FeeBreakdownState extends StatefulWidget {
  const FeeBreakdownState({super.key});

  @override
  State<FeeBreakdownState> createState() => FeeBreakdownPage();
}


class FeeBreakdownPage extends State<FeeBreakdownState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color warn = Color(0xFF7A3A0B);


  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );

  Widget buildRow(String label, String value, {bool bold = false, Color? valueColor}) {
    final style = TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: ink);
    final valueStyle = TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: valueColor ?? ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Flexible(child: Text(label, style: style)), const SizedBox(width: 12), Text(value, style: valueStyle)],
      ),
    );
  }

  String minus(int n) => n == 0 ? AppSettings.peso(0) : '− ${AppSettings.peso(n)}';

  Widget buildDivider() => const Divider(height: 8, color: Color(0xFFE3E8E6));

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(999))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
        ],
      ),
    );
  }

  Widget buildCircle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget buildHero(Map<String, dynamic> r) {
    final released = r['lenderConfirmed'] == true;
    final cash = r['payment'] == 'cash';
    final closed = r['status'] == 'Completed' && (r['returnedOn'] as String).isEmpty;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x4D0F5C5C), blurRadius: 20, offset: Offset(0, 10))],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, Color(0xFF2A8C80)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -30, right: -20, child: buildCircle(120, const Color(0x1FFFFFFF))),
          Positioned(bottom: -40, right: 70, child: buildCircle(90, const Color(0x14FFFFFF))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Deposit refund', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFD6ECE6))),
                const SizedBox(height: 4),
                Text(AppSettings.peso(RentalFees.depositRefund(r)),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 10),
                Text(closed ? 'The item was not returned. The lender keeps the deposit.' : cash ? 'Handed back by the lender in person.' : (released ? 'The refund has been released.' : 'Released after the lender confirms the return.'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD6ECE6), height: 1.4)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(999)),
                  child: Text(closed ? 'Closed as not returned ' : cash ? 'Settled in person ' : 'Simulated refund', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
    final total = RentalFees.rentalFee(r) + delivery + late + damage;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [

            const TopBar(title: 'Fee breakdown'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


        
                    buildHero(r),
                    const SizedBox(height: 18),
                    buildSectionTitle('Charges'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          buildRow('Rental fee ($days ${days == 1 ? 'day' : 'days'})', AppSettings.peso(RentalFees.rentalFee(r))),
                          if (delivery > 0) buildRow('Delivery fee', AppSettings.peso(delivery)),
                          buildRow('Late fee ($lateDays ${lateDays == 1 ? 'day' : 'days'} × ${AppSettings.peso(perDay)})', AppSettings.peso(late), valueColor: late > 0 ? warn : null),
                          buildRow('Damage deduction', AppSettings.peso(damage)),
                          buildDivider(),
                          buildRow('Total charges', AppSettings.peso(total), bold: true, valueColor: teal),
                          buildRow('Paid with', r['payment'] == 'cash' ? 'Cash ' : 'P-wallet '),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

               
                    const SizedBox(height: 6),
                    buildSectionTitle('Deposit'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          buildRow('Deposit held', AppSettings.peso(RentalFees.deposit(r))),
                          buildRow('Less late fee', minus(late)),
                          if (damage > 0) buildRow('Less damage deduction', minus(damage)),
                          buildDivider(),
                         
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFE3F0EE), borderRadius: BorderRadius.circular(12)),
                            child: buildRow('Deposit refund', AppSettings.peso(RentalFees.depositRefund(r)), bold: true, valueColor: teal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),


                    const Text(
                      'Late fees are capped at the deposit.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),


            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
                    ),
                    child: ElevatedButton(
                
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
         
                  if (started && (late > 0 || damage > 0)) ...[
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