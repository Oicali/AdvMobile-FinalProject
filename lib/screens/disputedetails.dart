import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/statustag.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';


class DisputeDetailsState extends StatefulWidget {
  const DisputeDetailsState({super.key});

  @override
  State<DisputeDetailsState> createState() => DisputeDetailsPage();
}


class DisputeDetailsPage extends State<DisputeDetailsState> {
  Map<String, dynamic>? dispute;
  bool loaded = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    dispute = arg is String ? AllDisputes.byId(arg) : null;
  }


  String nameOf(String username) => AllUsers.byUsername(username)?['fullname'] ?? username;


  Future<void> addText({required bool isReply}) async {
    final d = dispute!;
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => _TextDialog(
        title: isReply ? 'Your reply' : 'Add more details',
        hint: isReply ? 'Give your side of what happened' : 'Anything the reviewer should know',
        initial: isReply ? (d['reply'] as String) : '',
      ),
    );
    if (text == null || !mounted) return;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Write something before saving.')));
      return;
    }
    setState(() {
      if (isReply) {
        d['reply'] = text;
      } else {
        d['message'] = '${d['message']}\n\n$text';
      }
    });
  }


  Future<void> cancelDispute() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this dispute?'),
        content: const Text('The report will be withdrawn and any held amount goes back to normal.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel dispute', style: TextStyle(color: error))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    AllDisputes.disputes.remove(dispute);
    Navigator.pop(context);
  }


  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );


  Widget grey(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
      );


  Widget buildStep(String label, String detail, bool done, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 14,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? teal : Colors.white,
                    border: Border.all(color: done ? teal : const Color(0xFF98A4A2), width: 2),
                  ),
                  // White check inside finished steps
                  child: done ? const Icon(Icons.check, size: 9, color: Colors.white) : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: done ? teal : const Color(0xFFD5E3E0))),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: done ? ink : gray)),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(detail, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title, [String trailing = '']) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 12),
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
          if (trailing.isNotEmpty) Text(trailing, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
        ],
      ),
    );
  }

  Widget buildCircle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget buildSummary(Map<String, dynamic>? r, Map<String, dynamic>? item, String status, bool resolved) {
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
                StatusTag(text: status, attention: !resolved),
                if (r != null) ...[
                  const SizedBox(height: 8),
                  Text('Rental ${AppSettings.shortDate(r['start'])} – ${AppSettings.shortDate(r['end'])}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHero(Map<String, dynamic> d, int amount) {
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
                const Text('Ruling', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFD6ECE6))),
                const SizedBox(height: 4),
                Text('${d['outcome']}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                if (amount > 0) ...[
                  const SizedBox(height: 10),
                  Text('Amount in question: ${AppSettings.peso(amount)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFD6ECE6), height: 1.4)),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(999)),
                  child: const Text('Simulated admin ruling', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget buildMessageCard(String name, String role, String body, {bool mine = false}) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardStyle(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
                child: Text(initial, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mine ? '$name (you)' : name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
                    Text(role, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: gray)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE3E8E6)),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.45)),
        ],
      ),
    );
  }


  Widget pillButton(String label, VoidCallback onTap, {bool filled = false}) {
    const shape = StadiumBorder();
    const text = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: filled ? const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))] : null,
      ),
      child: filled
          ? ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: teal, foregroundColor: Colors.white, elevation: 0, shape: shape, textStyle: text), child: Text(label))
          : OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(foregroundColor: teal, side: const BorderSide(color: teal, width: 1.5), shape: shape, textStyle: text), child: Text(label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = dispute;
    if (d == null) return const Scaffold(body: Center(child: Text('Dispute not found.')));

    final r = AllRentals.byId(d['rentalId']);
    final item = r == null ? null : AllItems.byId(r['itemId']);
    final isFiler = d['filedBy'] == ActiveUser.username;
    final String status = d['status'];
    final resolved = status == 'Resolved';
    final amount = d['amount'] as int;
    final filedOn = (d['filedOn'] ?? '') as String;
    final other = AllDisputes.otherParty(d);
    final reply = (d['reply'] ?? '') as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        top: false,
        child: Column(
          children: [

            const TopBar(title: 'Dispute'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [



                    buildSummary(r, item, status, resolved),
                    const SizedBox(height: 16),
                    if (resolved) ...[
                      buildHero(d, amount),
                      const SizedBox(height: 16),
                    ],


                    buildSectionHeader('Report'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: cardStyle(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          grey('Reason: ${d['reason']}'),
                          grey(isFiler || filedOn.isEmpty ? 'Filed ${filedOn.isEmpty ? '' : AppSettings.shortDate(filedOn)}' : 'Filed ${AppSettings.shortDate(filedOn)} by ${nameOf(d['filedBy'])}'),
                          if (amount > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Amount in question', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                                  Text(AppSettings.peso(amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ink)),
                                ],
                              ),
                            ),
                          if (!resolved && amount > 0) grey('This part of the deposit is held until the dispute is resolved.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),


                    buildSectionHeader('Progress'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: cardStyle(20),
                      child: Column(
                        children: [
                          buildStep('Submitted', filedOn.isEmpty ? '' : AppSettings.shortDate(filedOn), true, false),
                          buildStep('Admin review ', status == 'Submitted' ? 'Pending' : (resolved ? 'Done' : 'Now'), status != 'Submitted', false),
                          buildStep('Resolved', resolved ? '${d['outcome']}' : 'Pending', resolved, true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),


                    buildSectionHeader('Messages', reply.isEmpty ? '1 message' : '2 messages'),
                    buildMessageCard(nameOf(d['filedBy']), 'Report', d['message'], mine: isFiler),
                    if (reply.isNotEmpty) buildMessageCard(nameOf(other), 'Reply', reply, mine: !isFiler),
                  ],
                ),
              ),
            ),


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
                  if (!resolved && isFiler) ...[
                    pillButton('Add more details', () => addText(isReply: false)),
                    const SizedBox(height: 12),
                    pillButton('Cancel dispute', cancelDispute),
                  ],
                  if (!resolved && !isFiler) pillButton(reply.isEmpty ? 'Reply' : 'Edit your reply', () => addText(isReply: true), filled: true),
                  if (resolved) pillButton('Back', () => Navigator.pop(context), filled: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TextDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String initial;
  const _TextDialog({required this.title, required this.hint, required this.initial});

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final TextEditingController ctrl = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(controller: ctrl, maxLines: 4, autofocus: true, decoration: InputDecoration(hintText: widget.hint)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Save')),
      ],
    );
  }
}