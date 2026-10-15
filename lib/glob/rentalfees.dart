import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';

// Every rental amount, calculated from the item + rental + demo date
class RentalFees {
  static Map<String, dynamic> _item(Map<String, dynamic> r) => AllItems.byId(r['itemId'])!;

  // Late fees only exist once the rental has actually started
  static bool _started(Map<String, dynamic> r) => ['Active', 'Overdue', 'Returned', 'Completed'].contains(r['status']);

  static int days(Map<String, dynamic> r) => AppSettings.daysBetween(r['start'], r['end']);
  static int dailyRate(Map<String, dynamic> r) => _item(r)['dailyRate'];
  static int deposit(Map<String, dynamic> r) => _item(r)['deposit'];
  static int rentalFee(Map<String, dynamic> r) => dailyRate(r) * days(r);
  static int deliveryFee(Map<String, dynamic> r) => r['method'] == 'delivery' ? AppSettings.deliveryFee : 0;

  // Days late = max(0, today - end); once returned, counting stops at the return date
  static int daysLate(Map<String, dynamic> r) {
    if (!_started(r)) return 0;
    final until = (r['returnedOn'] as String).isNotEmpty ? r['returnedOn'] as String : AppSettings.demoDate;
    return AppSettings.daysBetween(r['end'], until);
  }

  // Late fee before any dispute outcome: dailyRate x days late x multiplier, capped at the deposit
  static int rawLateFee(Map<String, dynamic> r) {
    final fee = dailyRate(r) * daysLate(r) * AppSettings.lateFeeMultiplier;
    return fee > deposit(r) ? deposit(r) : fee;
  }

  // Part of the late fee the borrower won back: resolved disputes they filed (Refund borrower = all, Split = half)
  static int lateWaiver(Map<String, dynamic> r) {
    int total = 0;
    for (final d in AllDisputes.forRental(r['id'])) {
      if (d['status'] != 'Resolved' || d['filedBy'] != r['borrower']) continue;
      if (d['outcome'] == 'Refund borrower') total += d['amount'] as int;
      if (d['outcome'] == 'Split') total += (d['amount'] as int) ~/ 2;
    }
    final raw = rawLateFee(r);
    return total > raw ? raw : total;
  }

  // Late fee the borrower actually owes
  static int lateFee(Map<String, dynamic> r) => rawLateFee(r) - lateWaiver(r);

  // Damage = resolved claims filed by the lender: Pay lender = full amount, Split = half
  static int damageDeduction(Map<String, dynamic> r) {
    int total = 0;
    for (final d in AllDisputes.forRental(r['id'])) {
      if (d['status'] != 'Resolved' || d['filedBy'] != r['lender']) continue;
      if (d['outcome'] == 'Pay lender') total += d['amount'] as int;
      if (d['outcome'] == 'Split') total += (d['amount'] as int) ~/ 2;
    }
    final room = deposit(r) - lateFee(r); // can never take more than what is left of the deposit
    return total > room ? room : total;
  }

  // Deposit refund = deposit - late fee - damage deduction
  static int depositRefund(Map<String, dynamic> r) => deposit(r) - lateFee(r) - damageDeduction(r);
}