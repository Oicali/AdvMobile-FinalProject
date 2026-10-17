// ===== FILE 1: lib/glob/rentalfees.dart =====
import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';
 
 
class RentalFees {
  static Map<String, dynamic> _item(Map<String, dynamic> r) => AllItems.byId(r['itemId'])!;
 
 
  static bool _started(Map<String, dynamic> r) => ['Active', 'Overdue', 'Returned', 'Completed'].contains(r['status']);
 
  static int days(Map<String, dynamic> r) => AppSettings.daysBetween(r['start'], r['end']);
 
  // CHANGED: read the price saved in the rental; older rentals without it fall back to the live item
  static int dailyRate(Map<String, dynamic> r) => (r['dailyRate'] as int?) ?? (_item(r)['dailyRate'] as int);
  static int deposit(Map<String, dynamic> r) => (r['deposit'] as int?) ?? (_item(r)['deposit'] as int);
  static int rentalFee(Map<String, dynamic> r) => dailyRate(r) * days(r);
  static int deliveryFee(Map<String, dynamic> r) =>
      (r['deliveryFee'] as int?) ?? (r['method'] == 'delivery' ? AppSettings.deliveryFee : 0);
 
 
  static int daysLate(Map<String, dynamic> r) {
    if (!_started(r)) return 0;
    final until = (r['returnedOn'] as String).isNotEmpty ? r['returnedOn'] as String : AppSettings.demoDate;
    return AppSettings.daysBetween(r['end'], until);
  }
 
 
  static int rawLateFee(Map<String, dynamic> r) {
    final fee = dailyRate(r) * daysLate(r) * AppSettings.lateFeeMultiplier;
    return fee > deposit(r) ? deposit(r) : fee;
  }
 
 
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
 
 
  static int lateFee(Map<String, dynamic> r) => rawLateFee(r) - lateWaiver(r);
 
  static bool capReached(Map<String, dynamic> r) => r['status'] == 'Overdue' && rawLateFee(r) >= deposit(r);
 
  static int damageDeduction(Map<String, dynamic> r) {
    int total = 0;
    for (final d in AllDisputes.forRental(r['id'])) {
      if (d['status'] != 'Resolved' || d['filedBy'] != r['lender']) continue;
      if (d['outcome'] == 'Pay lender') total += d['amount'] as int;
      if (d['outcome'] == 'Split') total += (d['amount'] as int) ~/ 2;
    }
    final room = deposit(r) - lateFee(r); 
    return total > room ? room : total;
  }
 
 
  static int depositRefund(Map<String, dynamic> r) => deposit(r) - lateFee(r) - damageDeduction(r);
}