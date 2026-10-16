import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/glob/activeuser.dart';
import 'package:advmobile_finalproject/glob/alladdresses.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allusers.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
import 'package:advmobile_finalproject/widgets/inputfield.dart';
import 'package:advmobile_finalproject/widgets/itemphoto.dart';
import 'package:advmobile_finalproject/widgets/topbar.dart';

// Widget class (XState naming convention)
class RentRequestState extends StatefulWidget {
  const RentRequestState({super.key});

  @override
  State<RentRequestState> createState() => RentRequestPage();
}

// State class (XPage naming convention)
class RentRequestPage extends State<RentRequestState> {
  final TextEditingController addressCtrl = TextEditingController();
  Map<String, dynamic>? item;
  String start = '';
  String end = '';
  String method = 'pickup'; // 'pickup' or 'delivery'
  String? formError; // message shown above the buttons
  bool loaded = false;

  static const Color teal = Color(0xFF0F5C5C);
  static const Color ink = Color(0xFF1B2626);
  static const Color gray = Color(0xFF6A7776);
  static const Color error = Color(0xFFD64545);

  // Read the item id once, then set default dates and prefill the delivery address
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

  // Free the controller when the screen is removed
  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }

  // Calculated money (never stored)
  int get days => AppSettings.daysBetween(start, end);
  int get rentalFee => (item!['dailyRate'] as int) * days;
  int get deliveryFee => method == 'delivery' ? AppSettings.deliveryFee : 0;
  int get deposit => item!['deposit'] as int;
  int get total => rentalFee + deliveryFee + deposit;

  // Local DateTime for the picker (the picker wants local, not UTC)
  DateTime local(String ymd) {
    final d = AppSettings.toDate(ymd);
    return DateTime(d.year, d.month, d.day);
  }

  // Open the calendar; keep end after start
  Future<void> pickDate(bool isStart) async {
    final first = isStart ? AppSettings.demoDate : AppSettings.addDays(start, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: local(isStart ? start : end),
      firstDate: local(first),
      lastDate: local(AppSettings.addDays(AppSettings.demoDate, 365)),
    );
    if (picked == null) return;

    setState(() {
      formError = null;
      if (isStart) {
        start = AppSettings.fromDate(picked);
        if (end.compareTo(start) <= 0) end = AppSettings.addDays(start, 1);
      } else {
        end = AppSettings.fromDate(picked);
      }
    });
  }

  // Why these dates can't be booked (null = fine)
  String? conflictMessage() {
    for (final r in AllRentals.rentals) {
      if (r['itemId'] != item!['id']) continue;
      final s = r['status'];
      if (s == 'Overdue') return "This item hasn't been returned yet.";
      final blocks = s == 'Approved' || s == 'Active' || (s == 'Requested' && r['borrower'] == ActiveUser.username);
      // Strict compare so a same-day handoff (one ends, one starts) is allowed
      if (blocks && start.compareTo(r['end']) < 0 && end.compareTo(r['start']) > 0) {
        return 'Those dates overlap another rental (${AppSettings.shortDate(r['start'])} to ${AppSettings.shortDate(r['end'])}).';
      }
    }
    return null;
  }

  // Validate, then create the rental as "Requested"
  void sendRequest() {
    if (method == 'delivery' && addressCtrl.text.trim().isEmpty) {
      setState(() => formError = 'Enter a delivery address.');
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
      'status': 'Requested',
      'returnedOn': '',
      'lenderConfirmed': false,
    });

    final lender = AllUsers.byUsername(item!['owner'])?['fullname'] ?? item!['owner'];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent to $lender.')));
    // Open My rentals on the Requested tab so the new request is visible
    Navigator.pushNamedAndRemoveUntil(context, '/myrentals', (route) => false, arguments: 'Requested');
  }

  // White rounded card style
  BoxDecoration cardStyle(double radius) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3))],
      );

  // Tappable date box with a label above
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: cardStyle(16),
              child: Text(AppSettings.longDate(value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ink)),
            ),
          ),
        ],
      ),
    );
  }

  // Radio-style option card for pickup / delivery
  Widget buildMethodCard(String value, String label) {
    final selected = method == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() {
          method = value;
          formError = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: cardStyle(16).copyWith(border: Border.all(color: selected ? teal : Colors.transparent, width: 1.5)),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: selected ? teal : gray),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink)),
            ],
          ),
        ),
      ),
    );
  }

  // One line of the cost summary
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
            child: SafeArea(
        top: false, // TopBar handles the status bar itself
        // LayoutBuilder + IntrinsicHeight keeps the buttons at the bottom but lets the page scroll
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [


                      // Item summary card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: cardStyle(20),
                        child: Row(
                          children: [ItemPhoto(item: item!, width: 52, height: 52, radius: 14, iconSize: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item!['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink)),
                                const SizedBox(height: 2),
                                Text('${AppSettings.peso(item!['dailyRate'])} / day', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Start and end dates
                      Row(
                        children: [
                          buildDateBox('Start date', start, () => pickDate(true)),
                          const SizedBox(width: 12),
                          buildDateBox('End date', end, () => pickDate(false)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pickup or delivery
                      const Padding(
                        padding: EdgeInsets.only(left: 2, bottom: 8),
                        child: Text('Get the item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gray)),
                      ),
                      buildMethodCard('pickup', 'Pick up from lender · Free'),
                      buildMethodCard('delivery', 'Deliver to me · ${AppSettings.peso(AppSettings.deliveryFee)}'),

                      // Delivery address only when delivery is chosen
                      if (method == 'delivery') ...[
                        const SizedBox(height: 4),
                        InputField(
                          label: 'Delivery address',
                          controller: addressCtrl,
                          hint: 'House no., street, barangay, city',
                          onChanged: (_) {
                            if (formError != null) setState(() => formError = null);
                          },
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Cost summary (all calculated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: cardStyle(16),
                        child: Column(
                          children: [
                            buildCostRow('${AppSettings.peso(item!['dailyRate'])} × $days ${days == 1 ? 'day' : 'days'}', AppSettings.peso(rentalFee)),
                            buildCostRow('Delivery fee', AppSettings.peso(deliveryFee)),
                            buildCostRow('Deposit (refundable)', AppSettings.peso(deposit)),
                            buildCostRow('Total due', AppSettings.peso(total), bold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Late fee + return method note
                      Text('Late return costs ${AppSettings.peso(lateRate)} per extra day, taken from the deposit. Return uses the same method.',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: gray, height: 1.4)),

                      const Spacer(),
                      const SizedBox(height: 16),

                      // Validation / conflict message
                      if (formError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(formError!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: error)),
                        ),

                      // Filled pill: send
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: sendRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: teal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Send request'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Outlined pill: cancel
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: teal,
                            side: const BorderSide(color: teal, width: 1.5),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
          ),
        ],
      ),
    );
  }
}