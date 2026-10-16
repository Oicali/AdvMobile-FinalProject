import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
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


  Widget buildRental(Map<String, dynamic> r) {
    final item = AllItems.byId(r['itemId']);
    final status = r['status'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(16),
      child: Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final live = AllRentals.rentals.where((r) => clockStatuses.contains(r['status'])).toList();

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


                  const Padding(
                    padding: EdgeInsets.only(left: 2, bottom: 10),
                    child: Text('Rentals affected by the clock', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ink)),
                  ),
                  if (live.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No active rentals right now.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: gray)),
                    )
                  else
                    ...live.map(buildRental),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
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