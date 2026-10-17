import 'package:advmobile_finalproject/glob/alldisputes.dart';
import 'package:advmobile_finalproject/glob/allitems.dart';
import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/rentalfees.dart';


class AllWallets {
  static List<Map<String, dynamic>> wallets = [
    {'username': 'juan', 'base': 20000},
    {'username': 'mika', 'base': 8000},
    {'username': 'jon', 'base': 5000},
    {'username': 'ana', 'base': 5000},
  ];

  static const List<String> _holding = ['Requested', 'Approved', 'Active', 'Overdue', 'Returned'];


  static bool isWallet(Map<String, dynamic> r) => r['payment'] != 'cash';


  static bool isSettled(Map<String, dynamic> r) => r['status'] == 'Completed' && !AllDisputes.anyOpen(r['id']);


  static int settledAmount(Map<String, dynamic> r) =>
      RentalFees.rentalFee(r) + RentalFees.deliveryFee(r) + RentalFees.lateFee(r) + RentalFees.damageDeduction(r);


  static int baseOf(String? username) {
    for (final w in wallets) {
      if (w['username'] == username) return w['base'] as int;
    }
    return 0;
  }


  static void topUp(String? username, int amount) {
    if (username == null) return;
    for (final w in wallets) {
      if (w['username'] == username) {
        w['base'] = (w['base'] as int) + amount;
        return;
      }
    }
    wallets.add({'username': username, 'base': amount});
  }


  static String stateOf(Map<String, dynamic> r) {
    if (!isWallet(r)) return '';
    final s = r['status'];
    if (s == 'Declined' || s == 'Cancelled') return '';
    if (s == 'Completed') return isSettled(r) ? 'Paid out' : 'Payout on hold (dispute open)';
    return 'Held until the return is confirmed';
  }


  static int held(String? username) {
    int total = 0;
    for (final r in AllRentals.rentals) {
      if (r['borrower'] != username || !isWallet(r)) continue;
      final pending = _holding.contains(r['status']) || (r['status'] == 'Completed' && !isSettled(r));
      if (pending) total += AllItems.totalDue(r);
    }
    return total;
  }


  static int paid(String? username) {
    int total = 0;
    for (final r in AllRentals.rentals) {
      if (r['borrower'] == username && isWallet(r) && isSettled(r)) total += settledAmount(r);
    }
    return total;
  }


  static int earned(String? username) {
    int total = 0;
    for (final r in AllRentals.rentals) {
      if (r['lender'] == username && isWallet(r) && isSettled(r)) total += settledAmount(r);
    }
    return total;
  }


  static int available(String? username) => baseOf(username) - held(username) - paid(username) + earned(username);


  static bool canAfford(String? username, int amount) => available(username) >= amount;
}