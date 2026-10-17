import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allwallets.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

class ConfirmReturnState extends StatefulWidget {
  const ConfirmReturnState({super.key});

  @override
  State<ConfirmReturnState> createState() => ConfirmReturnPage();
}

class ConfirmReturnPage extends State<ConfirmReturnState> {
  Map<String, dynamic>? rental;
  bool loaded = false;

  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);
  static const Color lateFill = Color(0xFFFFE9D6);
  static const Color lateText = Color(0xFF7A3A0B);
  static const Color lateLine = Color(0xFFE8893A);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    AllRentals.syncStatuses();
    final arg = ModalRoute.of(context)?.settings.arguments;
    rental = arg is String ? AllRentals.byId(arg) : null;
  }

  Future<void> confirmReturn() async {
    final r = rental!;
    r['lenderConfirmed'] = true;
    r['status'] = 'Completed';
    final msg = !AllWallets.isWallet(r)
        ? 'Return confirmed. Hand back the deposit in person (simulated).'
        : (AllWallets.isSettled(r) ? 'Return confirmed. P-wallet payout released (simulated).' : 'Return confirmed. Payout waits for the open dispute (simulated).');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    await Navigator.pushNamed(context, '/ratereview', arguments: r['id']);
    if (!mounted) return;
    Navigator.pop(context);
  }

  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );

  Widget buildRow(String label, String value, {bool bold = false, Color color = ink}) {
    final style = TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Flexible(child: Text(label, style: style)), const SizedBox(width: 12), Text(value, style: style)],
      ),
    );
  }

  Widget buildSectionHeader(String title, String trailing, {Color trailingColor = gray}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(999))),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
            ],
          ),
          Text(trailing, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: trailingColor)),
        ],
      ),
    );
  }

  Widget buildAvatar(String name) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
      child: Text(initial, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }

  Widget buildLateCard(Map<String, dynamic> r) {
    final days = RentalFees.daysLate(r);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lateFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lateLine, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20, color: lateLine),
              const SizedBox(width: 6),
              Text('$days ${days == 1 ? 'day' : 'days'} late', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: lateText)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Late fee: ${AppSettings.peso(RentalFees.lateFee(r))}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: lateText)),
          const SizedBox(height: 2),
          Text('Deposit refund: ${AppSettings.peso(RentalFees.depositRefund(r))}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: lateText)),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 44, color: Color(0xFFB5C2BF)),
            SizedBox(height: 10),
            Text('Nothing to confirm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink)),
            SizedBox(height: 4),
            Text('This return is not waiting on you.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
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
    final borrowerName = (AllUsers.byUsername(r['borrower'])?['fullname'] ?? r['borrower']).toString();
    final returnedOn = r['returnedOn'] as String;
    final lateDays = RentalFees.daysLate(r);
    final damage = RentalFees.damageDeduction(r);
    final isLate = lateDays > 0;
    final days = AppSettings.daysBetween(r['start'], r['end']);
    final canConfirm = r['status'] == 'Returned' && r['lender'] == ActiveUser.username;
    final myReports = AllDisputes.forRental(r['id']).where((d) => d['filedBy'] == ActiveUser.username).toList();
    final summaryTag = returnedOn.isEmpty ? 'Not returned' : 'Returned ${AppSettings.shortDate(returnedOn)}';

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
                      padding: const EdgeInsets.all(16),
                      decoration: cardStyle(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              buildAvatar(borrowerName),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Borrower', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: gray)),
                                    Text(borrowerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
                                  ],
                                ),
                              ),
                              StatusTag(text: '${r['status']}'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFE3E8E6)),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ItemPhoto(item: item ?? <String, dynamic>{}, width: 84, height: 84, radius: 16, iconSize: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item?['name'] ?? 'Item', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: ink)),
                                    const SizedBox(height: 3),
                                    Text('${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])} · $days ${days == 1 ? 'day' : 'days'}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isLate) ...[
                      buildLateCard(r),
                      const SizedBox(height: 12),
                    ],
                    buildSectionHeader('Return summary', summaryTag),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          buildRow('Due date', AppSettings.longDate(r['end'])),
                          buildRow('Returned on', returnedOn.isEmpty ? 'Not returned yet' : AppSettings.longDate(returnedOn)),
                          buildRow('Days late', '$lateDays'),
                          buildRow('Late fee', AppSettings.peso(RentalFees.lateFee(r))),
                          if (damage > 0) buildRow('Damage deduction', '− ${AppSettings.peso(damage)}'),
                          buildRow('Deposit held', AppSettings.peso(RentalFees.deposit(r))),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Divider(height: 1, color: Color(0xFFE3E8E6)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(color: tealSoft, borderRadius: BorderRadius.circular(12)),
                            child: buildRow(r['payment'] == 'cash' ? 'Deposit to return in person (simulated)' : 'Deposit refund to P-wallet (simulated)', AppSettings.peso(RentalFees.depositRefund(r)), bold: true, color: teal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (canConfirm) ...[
                      Text(
                        r['payment'] == 'cash'
                            ? 'Confirming records that the deposit was returned in person (simulated). If something is damaged, report it before you confirm.'
                            : 'Confirming releases the P-wallet payout (simulated). If something is damaged, report it before you confirm.',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4),
                      ),
                    ],
                    if (!canConfirm) buildEmpty(),
                  ],
                ),
              ),
            ),
            if (canConfirm)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
                      ),
                      child: ElevatedButton(
                        onPressed: confirmReturn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_outlined, size: 19),
                            SizedBox(width: 8),
                            Text('Confirm return'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, myReports.isEmpty ? '/reportissue' : '/disputedetails', arguments: myReports.isEmpty ? r['id'] : myReports.first['id']).then((_) => setState(() {})),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: teal,
                          side: const BorderSide(color: teal, width: 1.5),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flag_outlined, size: 19),
                            const SizedBox(width: 8),
                            Text(myReports.isEmpty ? 'Report a problem' : 'View my report · ${myReports.first['status']}'),
                          ],
                        ),
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