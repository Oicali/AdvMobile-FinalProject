import 'package:advmobile_finalproject/glob/allrentals.dart';


class AllDisputes {
  static List<Map<String, dynamic>> disputes = [];
  static int nextNumber = 1;

 
  static String newId() => 'd${nextNumber++}';

 
  static Map<String, dynamic>? byId(String id) {
    for (final d in disputes) {
      if (d['id'] == id) return d;
    }
    return null;
  }


  static List<Map<String, dynamic>> forRental(String rentalId) {
    return disputes.where((d) => d['rentalId'] == rentalId).toList();
  }

  
  static List<Map<String, dynamic>> involving(String? username) {
    return disputes.where((d) {
      final r = AllRentals.byId(d['rentalId']);
      return r != null && (r['borrower'] == username || r['lender'] == username);
    }).toList();
  }


  static bool hasOpen(String? username, String rentalId) {
    return disputes.any((d) => d['rentalId'] == rentalId && d['filedBy'] == username && d['status'] != 'Resolved');
  }


  static String otherParty(Map<String, dynamic> d) {
    final r = AllRentals.byId(d['rentalId']);
    if (r == null) return '';
    return r['borrower'] == d['filedBy'] ? r['lender'] : r['borrower'];
  }
}