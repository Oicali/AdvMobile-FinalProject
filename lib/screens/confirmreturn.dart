import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
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
  final List<bool> checks = [false, false, false];

  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);
  static const Color lateFill = Color(0xFFFDECEC);


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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Return confirmed. The deposit refund is released (simulated).')));
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
        border: Border.all(color: error, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20, color: error),
              const SizedBox(width: 6),
              Text('$days ${days == 1 ? 'day' : 'days'} late', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: error)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Late fee: ${AppSettings.peso(RentalFees.lateFee(r))}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: error)),
          const SizedBox(height: 2),
          Text('Deposit refund after late fee: ${AppSettings.peso(RentalFees.depositRefund(r))}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: error)),
        ],
      ),
    );
  }

  Widget buildCheckRow(int index, String label) {
    final checked = checks[index];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => checks[index] = !checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: checked ? teal : tealSoft, shape: BoxShape.circle),
              child: Icon(Icons.check, size: 19, color: checked ? Colors.white : const Color(0xFFB5C2BF)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink))),
          ],
        ),
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
    final isLate = lateDays > 0;
    final days = AppSettings.daysBetween(r['start'], r['end']);
    final canConfirm = r['status'] == 'Returned' && r['lender'] == ActiveUser.username;
    final allChecked = checks.every((c) => c);
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
                          buildRow('Deposit held', AppSettings.peso(RentalFees.deposit(r))),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Divider(height: 1, color: Color(0xFFE3E8E6)),
                          ),
                          // Final refund sits in a tinted pill so it stands out from the lines above it
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(color: tealSoft, borderRadius: BorderRadius.circular(12)),
                            child: buildRow('Deposit refund to borrower (simulated)', AppSettings.peso(RentalFees.depositRefund(r)), bold: true, color: teal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),


                    if (canConfirm) ...[
                      buildSectionHeader('Before you confirm', '${checks.where((c) => c).length} of ${checks.length}'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                        decoration: cardStyle(16),
                        child: Column(
                          children: [
                            buildCheckRow(0, 'The item was handed back to me'),
                            const Divider(height: 1, color: Color(0xFFE3E8E6)),
                            buildCheckRow(1, 'It matches the condition in the listing'),
                            const Divider(height: 1, color: Color(0xFFE3E8E6)),
                            buildCheckRow(2, 'There is no damage or missing part'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Confirming releases the deposit refund (simulated). If something is damaged, report it before you confirm.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4),
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
                        boxShadow: allChecked ? const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))] : null,
                      ),
                      child: ElevatedButton(
                        onPressed: allChecked ? confirmReturn : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFD5E3E0),
                          disabledForegroundColor: Colors.white,
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
                        onPressed: () => Navigator.pushNamed(context, '/reportissue', arguments: r['id']).then((_) => setState(() {})),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: teal,
                          side: const BorderSide(color: teal, width: 1.5),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag_outlined, size: 19),
                            SizedBox(width: 8),
                            Text('Report a problem'),
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