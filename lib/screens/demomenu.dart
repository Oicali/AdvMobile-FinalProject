import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


class DemoMenuState extends StatefulWidget {
  const DemoMenuState({super.key});

  @override
  State<DemoMenuState> createState() => DemoMenuPage();
}


class DemoMenuPage extends State<DemoMenuState> {
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color tealSoft = Color(0xFFE3F0EE);

  
  static const List<String> clockStatuses = ['Approved', 'Active', 'Overdue', 'Returned'];

 
  void advance(int days) {
    setState(() {
      AppSettings.demoDate = AppSettings.addDays(AppSettings.demoDate, days);
      AllRentals.syncStatuses();
    });
  }


  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );


  Widget buildAdvance(String label, int days) {
    return Expanded(
      child: SizedBox(
        height: 46,
        child: ElevatedButton(
          onPressed: () => advance(days),
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


  Widget buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: teal),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ink)),
      ],
    );
  }

  Widget buildRental(Map<String, dynamic> r) {
    final item = AllItems.byId(r['itemId']);
    final status = r['status'] as String;
    final rawLate = RentalFees.daysLate(r);
    final late = rawLate > 0 ? rawLate : 0;
    final fee = late > 0 ? RentalFees.lateFee(r) : 0;
    final daysText = late == 1 ? '1 day' : '$late days';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r['id']} · ${item?['name'] ?? 'Item'}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                    const SizedBox(height: 3),
                    Text('${r['borrower']} from ${r['lender']} · ${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusTag(text: status, attention: status == 'Overdue'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8E6)),
          ),
          buildInfoRow(Icons.schedule, 'Days late', daysText),
          const SizedBox(height: 10),
          buildInfoRow(Icons.payments_outlined, 'Late fee', '₱$fee'),
        ],
      ),
    );
  }

  void setStage(Map<String, dynamic> d, String status, String outcome) {
    setState(() {
      d['status'] = status;
      d['outcome'] = outcome;
    });
  }

  Widget buildStageButton(String label, bool active, VoidCallback onTap) {
    const shape = StadiumBorder();
    const text = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);
    const pad = EdgeInsets.symmetric(horizontal: 16);
    return SizedBox(
      height: 38,
      child: active
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: teal, foregroundColor: Colors.white, elevation: 0, shape: shape, padding: pad, textStyle: text),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(foregroundColor: teal, side: const BorderSide(color: teal, width: 1.5), shape: shape, padding: pad, textStyle: text),
              child: Text(label),
            ),
    );
  }

  Widget buildDispute(Map<String, dynamic> d) {
    final r = AllRentals.byId(d['rentalId']);
    final item = r == null ? null : AllItems.byId(r['itemId']);
    final status = d['status'] as String;
    final outcome = (d['outcome'] ?? '') as String;
    final amount = d['amount'] as int;
    final resolved = status == 'Resolved';
    final byBorrower = r != null && r['borrower'] == d['filedBy'];
    final outcomes = r == null ? ['Refund borrower', 'Pay lender', 'Split'] : (byBorrower ? ['Refund borrower', 'Split'] : ['Pay lender', 'Split']);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${d['id']} · ${item?['name'] ?? 'Item'}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                    const SizedBox(height: 3),
                    Text('Filed by ${d['filedBy']} · ${d['reason']}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusTag(text: status, attention: !resolved),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8E6)),
          ),
          buildInfoRow(Icons.payments_outlined, 'Amount in question', AppSettings.peso(amount)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildStageButton('Under review', status == 'Under review', () => setStage(d, 'Under review', '')),
              for (final o in outcomes) buildStageButton(o, resolved && outcome == o, () => setStage(d, 'Resolved', o)),
              buildStageButton('Reset', false, () => setStage(d, 'Submitted', '')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final live = AllRentals.rentals.where((r) => clockStatuses.contains(r['status'])).toList();
    final disputes = AllDisputes.disputes;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [

            const TopBar(title: 'Demo menu'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                children: [

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: cardStyle(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Demo date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
                        const SizedBox(height: 2),
                        Text(AppSettings.longDate(AppSettings.demoDate),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        const Text('Simulated clock. Moving it forward flips rentals that are past their end date to Overdue.',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            buildAdvance('+1 day', 1),
                            const SizedBox(width: 8),
                            buildAdvance('+3 days', 3),
                            const SizedBox(width: 8),
                            buildAdvance('+7 days', 7),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),


                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rentals affected by the clock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
                        Text(live.length == 1 ? '1 rental' : '${live.length} rentals',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
                      ],
                    ),
                  ),
                  if (live.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 44, color: Color(0xFFB5C2BF)),
                          SizedBox(height: 10),
                          Text('No active rentals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                          SizedBox(height: 4),
                          Text('Approved, active, overdue and returned rentals show up here.',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                        ],
                      ),
                    )
                  else
                    ...live.map(buildRental),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Disputes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
                        Text(disputes.length == 1 ? '1 dispute' : '${disputes.length} disputes',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
                      ],
                    ),
                  ),
                  if (disputes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.flag_outlined, size: 44, color: Color(0xFFB5C2BF)),
                          SizedBox(height: 10),
                          Text('No disputes yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
                          SizedBox(height: 4),
                          Text('Reports filed from Report an issue show up here so you can set a ruling.',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                        ],
                      ),
                    )
                  else
                    ...disputes.map(buildDispute),
                ],
              ),
            ),


            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
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