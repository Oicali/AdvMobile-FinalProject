// ===== FILE 3: lib/screens/rentrequest.dart =====
import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/allwallets.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';
 
 
class RentRequestState extends StatefulWidget {
  const RentRequestState({super.key});
 
  @override
  State<RentRequestState> createState() => RentRequestPage();
}
 
 
class RentRequestPage extends State<RentRequestState> {
  final TextEditingController addressCtrl = TextEditingController();
  Map<String, dynamic>? item;
  String start = '';
  String end = '';
  String payment = 'wallet';
  String method = 'pickup'; 
  String? formError; 
  bool loaded = false;
 
  static const Color teal = Color(0xFF0F5C5C);
  static const Color tealSoft = Color(0xFFE3F0EE);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);
 
 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    loaded = true;
 
    final arg = ModalRoute.of(context)?.settings.arguments;
    item = arg is String ? AllItems.byId(arg) : null;
    start = AppSettings.demoDate;
    end = AppSettings.addDays(start, 3);
 
    final mine = AllAddresses.ownedBy(ActiveUser.username).where((a) => a['isDefault'] == true);
    if (mine.isNotEmpty) {
      final a = mine.first;
      addressCtrl.text = '${a['street']}, ${a['barangay']}, ${a['city']}';
    }
  }
 
 
  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }
 
 
  int get days => AppSettings.daysBetween(start, end);
  int get rentalFee => (item!['dailyRate'] as int) * days;
  int get deliveryFee => method == 'delivery' ? AppSettings.deliveryFee : 0;
  int get deposit => item!['deposit'] as int;
  int get total => rentalFee + deliveryFee + deposit;
 
  String pickupArea() {
    final list = AllAddresses.ownedBy(item!['owner']);
    if (list.isEmpty) return 'Lender will share the pickup location';
    final a = list.firstWhere((x) => x['isDefault'] == true, orElse: () => list.first);
    return '${a['barangay']}, ${a['city']}';
  }
 
 
  DateTime local(String ymd) {
    final d = AppSettings.toDate(ymd);
    return DateTime(d.year, d.month, d.day);
  }
 
 
  Future<void> pickDate(bool isStart) async {
    final first = isStart ? AppSettings.demoDate : AppSettings.addDays(start, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: local(isStart ? start : end),
      firstDate: local(first),
      lastDate: local(isStart ? AppSettings.addDays(AppSettings.demoDate, 365) : AppSettings.addDays(start, 7)),
    );
    if (picked == null) return;
 
    setState(() {
      formError = null;
      if (isStart) {
        start = AppSettings.fromDate(picked);
        if (end.compareTo(start) <= 0) {
          end = AppSettings.addDays(start, 1);
        } else if (AppSettings.daysBetween(start, end) > 7) {
          end = AppSettings.addDays(start, 7);
        }
      } else {
        end = AppSettings.fromDate(picked);
      }
    });
  }
 
 
  String? conflictMessage() {
    for (final r in AllRentals.rentals) {
      if (r['itemId'] != item!['id']) continue;
      final s = r['status'];
      if (s == 'Overdue') return "This item hasn't been returned yet.";
      if (s == 'Returned') return 'This item is waiting for the lender to confirm its return.';
      final blocks = s == 'Approved' || s == 'Active' || (s == 'Requested' && r['borrower'] == ActiveUser.username);
      if (blocks && start.compareTo(r['end']) <= 0 && end.compareTo(r['start']) >= 0) {
        return 'Those dates overlap another rental (${AppSettings.shortDate(r['start'])} to ${AppSettings.shortDate(r['end'])}).';
      }
    }
    return null;
  }
 
 
  void sendRequest() {
    // NEW: bring statuses up to date before checking anything
    AllRentals.syncStatuses();
 
    // NEW: the item must still be listed and must not be the user's own
    if (item!['listed'] != true) {
      setState(() => formError = 'This item is no longer available.');
      return;
    }
    if (item!['owner'] == ActiveUser.username) {
      setState(() => formError = "You can't rent your own item.");
      return;
    }
 
    // CHANGED: delivery address must be complete, not just non-empty
    if (method == 'delivery') {
      final addr = addressCtrl.text.trim();
      if (addr.isEmpty) {
        setState(() => formError = 'Enter a delivery address.');
        return;
      }
      if (addr.length < 10) {
        setState(() => formError = 'Enter a complete delivery address (house no., street, barangay, city).');
        return;
      }
    }
    if (days > 7) {
      setState(() => formError = 'Rentals can be at most 7 days.');
      return;
    }
    if (payment == 'wallet' && !AllWallets.canAfford(ActiveUser.username, total)) {
      setState(() => formError = 'Not enough P-wallet balance. Top up or pay with cash.');
      return;
    }
    final conflict = conflictMessage();
    if (conflict != null) {
      setState(() => formError = conflict);
      return;
    }
 
    AllRentals.rentals.add({
      'id': AllRentals.newId(),
      'itemId': item!['id'],
      'borrower': ActiveUser.username,
      'lender': item!['owner'],
      'start': start,
      'end': end,
      'method': method,
      'address': method == 'delivery' ? addressCtrl.text.trim() : '',
      'payment': payment,
      'status': 'Requested',
      'returnedOn': '',
      'lenderConfirmed': false,
      // NEW: price saved at request time so later item edits cannot change this rental
      'dailyRate': item!['dailyRate'],
      'deposit': item!['deposit'],
      'deliveryFee': deliveryFee,
    });
 
    final lender = AllUsers.byUsername(item!['owner'])?['fullname'] ?? item!['owner'];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to $lender.')));
 
    Navigator.pushNamedAndRemoveUntil(context, '/myrentals', (route) => false, arguments: 'Requested');
  }
 
 
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x1A0F5C5C), blurRadius: 18, offset: Offset(0, 6))],
      );
 
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 0, 12),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: teal, borderRadius: BorderRadius.circular(999))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ink)),
        ],
      ),
    );
  }
 
  Widget buildSummary() {
    final owner = AllUsers.byUsername(item!['owner'])?['fullname'] ?? item!['owner'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardStyle(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemPhoto(item: item!, width: 84, height: 84, radius: 16, iconSize: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item!['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3)),
                const SizedBox(height: 6),
                Text('${AppSettings.peso(item!['dailyRate'])} / day · Deposit ${AppSettings.peso(item!['deposit'])}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
                const SizedBox(height: 4),
                Text('Lender: $owner', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
 
  Widget buildDateBox(String label, String value, VoidCallback onTap) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 7),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink)),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: cardStyle(16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: teal),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(AppSettings.longDate(value),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget buildDurationPill() {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: tealSoft, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 14, color: teal),
            const SizedBox(width: 6),
            Text('$days ${days == 1 ? 'day' : 'days'} rental', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: teal)),
          ],
        ),
      ),
    );
  }
 
 
  Widget buildMethodCard(String value, IconData icon, String label, String sub) {
    final selected = method == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() {
          method = value;
          formError = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: cardStyle(16).copyWith(
            color: selected ? const Color(0xFFF1F8F6) : Colors.white,
            border: Border.all(color: selected ? teal : Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                child: Icon(icon, size: 19, color: teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 22, color: selected ? teal : gray),
            ],
          ),
        ),
      ),
    );
  }
 
 
  Widget buildPaymentCard(String value, IconData icon, String label, String sub) {
    final selected = payment == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() {
          payment = value;
          formError = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: cardStyle(16).copyWith(
            color: selected ? const Color(0xFFF1F8F6) : Colors.white,
            border: Border.all(color: selected ? teal : Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: tealSoft, shape: BoxShape.circle),
                child: Icon(icon, size: 19, color: teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                    const SizedBox(height: 2),
                    Text(sub, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                  ],
                ),
              ),
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 22, color: selected ? teal : gray),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget buildCostRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: ink);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
 
  Widget buildBottomBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x1F0F5C5C), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (formError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(formError!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total due', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gray)),
                        const SizedBox(height: 2),
                        Text(AppSettings.peso(total), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: ink)),
                      ],
                    ),
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [BoxShadow(color: Color(0x550F5C5C), blurRadius: 14, offset: Offset(0, 6))],
                    ),
                    child: ElevatedButton(
                      onPressed: sendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Send request'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found.')));
    }
    final lateRate = (item!['dailyRate'] as int) * AppSettings.lateFeeMultiplier;
 
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: Column(
        children: [
          // Shared top bar stays pinned while the form scrolls
          const TopBar(title: 'Rent request'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSummary(),
                  const SizedBox(height: 22),
 
                  buildSectionTitle('Rental dates'),
                  Row(
                    children: [
                      buildDateBox('Start date', start, () => pickDate(true)),
                      const SizedBox(width: 12),
                      buildDateBox('End date', end, () => pickDate(false)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildDurationPill(),
                  const SizedBox(height: 22),
 
                  buildSectionTitle('Get the item'),
                  buildMethodCard('pickup', Icons.storefront_outlined, 'Pick up from lender', 'Free · ${pickupArea()}'),
                  buildMethodCard('delivery', Icons.local_shipping_outlined, 'Deliver to me', AppSettings.peso(AppSettings.deliveryFee)),
 
                  // Delivery address only when delivery is chosen
                  if (method == 'delivery') ...[
                    const SizedBox(height: 4),
                    InputField(
                      label: 'Delivery address',
                      controller: addressCtrl,
                      hint: 'House no., street, barangay, city',
                      icon: Icons.location_on_outlined,
                      onChanged: (_) {
                        if (formError != null) setState(() => formError = null);
                      },
                    ),
                  ],
                  const SizedBox(height: 18),
 
                  buildSectionTitle('Payment method'),
                  buildPaymentCard('wallet', Icons.account_balance_wallet_outlined, 'P-wallet (simulated)', 'Your balance ${AppSettings.peso(AllWallets.available(ActiveUser.username))}'),
                  buildPaymentCard('cash', Icons.money, 'Cash (simulated)', 'Pay the lender in person'),
                  const SizedBox(height: 8),
 
                  buildSectionTitle('Cost summary'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: cardStyle(16),
                    child: Column(
                      children: [
                        buildCostRow('${AppSettings.peso(item!['dailyRate'])} × $days ${days == 1 ? 'day' : 'days'}', AppSettings.peso(rentalFee)),
                        buildCostRow('Delivery fee', AppSettings.peso(deliveryFee)),
                        buildCostRow('Deposit (refundable)', AppSettings.peso(deposit)),
                        const Divider(height: 18, color: Color(0xFFE3E8E6)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: tealSoft, borderRadius: BorderRadius.circular(12)),
                          child: buildCostRow('Total due', AppSettings.peso(total), bold: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
 
            
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFF1E6), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Color(0xFFE8893A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Late return costs ${AppSettings.peso(lateRate)} per extra day, taken from the deposit. Return uses the same method.',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF9A4A0F), height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildBottomBar(),
        ],
      ),
    );
  }
}