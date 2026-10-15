import 'package:advmobile_finalproject/glob/allrentals.dart';

// Disputes start empty; Report an issue adds to this list, the Demo Menu will play platform staff
class AllDisputes {
  static List<Map<String, dynamic>> disputes = [];
  static int nextNumber = 1;

  // New unique id (d1, d2, ...)
  static String newId() => 'd${nextNumber++}';

  // Find one dispute by id (null if missing)
  static Map<String, dynamic>? byId(String id) {
    for (final d in disputes) {
      if (d['id'] == id) return d;
    }
    return null;
  }

  // All disputes filed on one rental
  static List<Map<String, dynamic>> forRental(String rentalId) {
    return disputes.where((d) => d['rentalId'] == rentalId).toList();
  }

  // Disputes on rentals where this user is the borrower or the lender
  static List<Map<String, dynamic>> involving(String? username) {
    return disputes.where((d) {
      final r = AllRentals.byId(d['rentalId']);
      return r != null && (r['borrower'] == username || r['lender'] == username);
    }).toList();
  }

  // Does this user still have an unresolved report on this rental?
  static bool hasOpen(String? username, String rentalId) {
    return disputes.any((d) => d['rentalId'] == rentalId && d['filedBy'] == username && d['status'] != 'Resolved');
  }

  // The other person on the rental (the one who did not file)
  static String otherParty(Map<String, dynamic> d) {
    final r = AllRentals.byId(d['rentalId']);
    if (r == null) return '';
    return r['borrower'] == d['filedBy'] ? r['lender'] : r['borrower'];
  }
}