import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
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
    if (text == null || text.isEmpty || !mounted) return;
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
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4))],
      );


  Widget grey(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),
      );


  Widget buildStep(String label, String detail, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: done ? teal : Colors.transparent, border: Border.all(color: done ? teal : const Color(0xFF98A4A2), width: 1.5)),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
          const SizedBox(width: 8),
          Flexible(child: Text(detail, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray))),
        ],
      ),
    );
  }


  Widget buildTextCard(String title, String body) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardStyle(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.45)),
        ],
      ),
    );
  }


  Widget pillButton(String label, VoidCallback onTap, {bool filled = false}) {
    const shape = StadiumBorder();
    const text = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    return SizedBox(
      width: double.infinity,
      height: 52,
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



                    Row(
                      children: [
                        Expanded(child: Text(item?['name'] ?? 'Item', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink))),
                        StatusTag(text: status, attention: !resolved),
                      ],
                    ),
                    const SizedBox(height: 12),


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
                          if (resolved) grey('Outcome: ${d['outcome']}') else if (amount > 0) grey('This part of the deposit is held until the dispute is resolved.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),


                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: cardStyle(16),
                      child: Column(
                        children: [
                          buildStep('Submitted', filedOn.isEmpty ? '' : AppSettings.shortDate(filedOn), true),
                          buildStep('Under review', status == 'Submitted' ? 'Pending' : (resolved ? 'Done' : 'Now'), status != 'Submitted'),
                          buildStep('Resolved', resolved ? '${d['outcome']}' : 'Pending', resolved),
                        ],
                      ),
                    ),


                    buildTextCard(isFiler ? 'Your message' : "${nameOf(d['filedBy'])}'s message", d['message']),
                    if (reply.isNotEmpty) buildTextCard(isFiler ? "${nameOf(other)}'s reply" : 'Your reply', reply),
                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
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