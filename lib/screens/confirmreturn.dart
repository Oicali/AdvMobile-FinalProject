import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


class ConfirmReturnState extends StatefulWidget {
  const ConfirmReturnState({super.key});

  @override
  State<ConfirmReturnState> createState() => ConfirmReturnPage();
}

class ConfirmReturnPage extends State<ConfirmReturnState> {
  Map<String, dynamic>? rental;
  bool loaded = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    AllRentals.syncStatuses();
    final arg = ModalRoute.of(context)?.settings.arguments;
    rental = arg is String ? AllRentals.byId(arg) : null;
  }


  void confirmReturn() {
    final r = rental!;
    r['lenderConfirmed'] = true;
    r['status'] = 'Completed';
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return confirmed. The deposit refund is released.')));
    Navigator.pop(context);
  }


  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );

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

  @override
  Widget build(BuildContext context) {
    final r = rental;
    if (r == null) return const Scaffold(body: Center(child: Text('Rental not found.')));

    final item = AllItems.byId(r['itemId']);
    final borrower = AllUsers.byUsername(r['borrower'])?['fullname'] ?? r['borrower'];
    final returnedOn = r['returnedOn'] as String;
    final lateDays = RentalFees.daysLate(r);
    final canConfirm = r['status'] == 'Returned' && r['lender'] == ActiveUser.username;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false, 
        child: Column(
          children: [

            const TopBar(title: 'Confirm return'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: cardStyle(20),
                      child: Row(
                        children: [
                          ItemPhoto(item: item ?? <String, dynamic>{}, width: 52, height: 52, radius: 14, iconSize: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item?['name'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                                const SizedBox(height: 2),
                                Text('Borrower: $borrower', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),


                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          buildRow('Due date', AppSettings.longDate(r['end'])),
                          buildRow('Returned on', returnedOn.isEmpty ? 'Not returned yet' : AppSettings.longDate(returnedOn)),
                          buildRow('Days late', '$lateDays'),
                          buildRow('Late fee', AppSettings.peso(RentalFees.lateFee(r))),
                          buildRow('Deposit held', AppSettings.peso(RentalFees.deposit(r))),
                          buildRow('Deposit refund to borrower', AppSettings.peso(RentalFees.depositRefund(r)), bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),


                    Text(
                      canConfirm
                          ? 'Check the item first. Confirming releases the deposit refund. If something is damaged, report it before you confirm.'
                          : 'There is nothing to confirm on this rental.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),


            if (canConfirm)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: confirmReturn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Confirm return'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/reportissue', arguments: r['id']).then((_) => setState(() {})),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: teal,
                          side: const BorderSide(color: teal, width: 1.5),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Report a problem'),
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