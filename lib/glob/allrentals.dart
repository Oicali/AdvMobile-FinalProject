import 'package:advmobile_finalproject/glob/appsettings.dart';


class AllRentals {
  static int nextNumber = 9;

 
  static String newId() => 'r${nextNumber++}';

  // Find one rental by id (null if missing)
  static Map<String, dynamic>? byId(String id) {
    for (final r in rentals) {
      if (r['id'] == id) return r;
    }
    return null;
  }

  static List<Map<String, dynamic>> pendingFor(String? lender) {
    return rentals.where((r) => r['lender'] == lender && r['status'] == 'Requested').toList();
  }


  static void syncStatuses() {
    final today = AppSettings.demoDate;
    for (final r in rentals) {
      if (r['status'] == 'Approved' && (r['start'] as String).compareTo(today) <= 0) r['status'] = 'Active';
      if (r['status'] == 'Active' && (r['end'] as String).compareTo(today) < 0) r['status'] = 'Overdue';
      // Returned -> Completed automatically after 2 demo days without lender confirmation
      if (r['status'] == 'Returned' && AppSettings.daysBetween(r['returnedOn'], today) >= 2) {
        r['status'] = 'Completed';
        r['lenderConfirmed'] = true;
      }
    }
  }
  static List<Map<String, dynamic>> rentals = [
    {'id': 'r1', 'itemId': 'i1', 'borrower': 'juan', 'lender': 'mika', 'start': '2026-10-15', 'end': '2026-10-17', 'method': 'pickup', 'address': '', 'status': 'Active', 'returnedOn': '', 'lenderConfirmed': false},
    {'id': 'r2', 'itemId': 'i4', 'borrower': 'ana', 'lender': 'mika', 'start': '2026-10-19', 'end': '2026-10-22', 'method': 'pickup', 'address': '', 'status': 'Approved', 'returnedOn': '', 'lenderConfirmed': false},
    {'id': 'r3', 'itemId': 'i2', 'borrower': 'juan', 'lender': 'jon', 'start': '2026-09-30', 'end': '2026-10-02', 'method': 'delivery', 'address': 'Blk 5 Lot 2, Brgy. San Roque, Quezon City', 'status': 'Completed', 'returnedOn': '2026-10-02', 'lenderConfirmed': true},
    {'id': 'r4', 'itemId': 'i3', 'borrower': 'jon', 'lender': 'mika', 'start': '2026-10-05', 'end': '2026-10-07', 'method': 'pickup', 'address': '', 'status': 'Completed', 'returnedOn': '2026-10-07', 'lenderConfirmed': true},
    {'id': 'r5', 'itemId': 'i5', 'borrower': 'juan', 'lender': 'ana', 'start': '2026-10-22', 'end': '2026-10-24', 'method': 'pickup', 'address': '', 'status': 'Requested', 'returnedOn': '', 'lenderConfirmed': false},
    {'id': 'r6', 'itemId': 'i6', 'borrower': 'mika', 'lender': 'jon', 'start': '2026-09-20', 'end': '2026-09-22', 'method': 'pickup', 'address': '', 'status': 'Completed', 'returnedOn': '2026-09-22', 'lenderConfirmed': true},
    {'id': 'r7', 'itemId': 'i7', 'borrower': 'juan', 'lender': 'mika', 'start': '2026-10-11', 'end': '2026-10-13', 'method': 'pickup', 'address': '', 'status': 'Completed', 'returnedOn': '2026-10-13', 'lenderConfirmed': true},
    {'id': 'r8', 'itemId': 'i1', 'borrower': 'jon', 'lender': 'mika', 'start': '2026-09-11', 'end': '2026-09-13', 'method': 'pickup', 'address': '', 'status': 'Completed', 'returnedOn': '2026-09-13', 'lenderConfirmed': true},
  ];
}