import 'package:advmobile_finalproject/glob/allrentals.dart';
import 'package:advmobile_finalproject/glob/allreviews.dart';
import 'package:advmobile_finalproject/glob/appsettings.dart';

// Sample items i1-i7 plus lookups derived from rentals and reviews
class AllItems {
  static List<Map<String, dynamic>> items = [
    {'id': 'i1', 'owner': 'mika', 'name': 'Canon EOS 200D', 'category': 'Cameras', 'dailyRate': 350, 'deposit': 3000, 'condition': 'Good', 'description': 'DSLR with 18-55mm kit lens, battery, charger and SD card.', 'listed': true},
    {'id': 'i2', 'owner': 'jon', 'name': 'Cordless Drill', 'category': 'Tools', 'dailyRate': 150, 'deposit': 1000, 'condition': 'Good', 'description': '18V drill with two batteries and a bit set.', 'listed': true},
    {'id': 'i3', 'owner': 'mika', 'name': 'Projector (HD)', 'category': 'Electronics', 'dailyRate': 400, 'deposit': 4000, 'condition': 'Like new', 'description': '1080p projector with HDMI cable and carry bag.', 'listed': true},
    {'id': 'i4', 'owner': 'mika', 'name': '4-Person Tent', 'category': 'Camping', 'dailyRate': 200, 'deposit': 1500, 'condition': 'Good', 'description': 'Waterproof dome tent with poles, stakes and rainfly.', 'listed': true},
    {'id': 'i5', 'owner': 'ana', 'name': 'Sony A6000', 'category': 'Cameras', 'dailyRate': 500, 'deposit': 5000, 'condition': 'Like new', 'description': 'Mirrorless body with 16-50mm lens and two batteries.', 'listed': true},
    {'id': 'i6', 'owner': 'jon', 'name': 'Action Cam', 'category': 'Cameras', 'dailyRate': 300, 'deposit': 2500, 'condition': 'Good', 'description': '4K action camera with waterproof case and mounts.', 'listed': true},
    {'id': 'i7', 'owner': 'mika', 'name': 'Tripod', 'category': 'Cameras', 'dailyRate': 100, 'deposit': 500, 'condition': 'Fair', 'description': 'Aluminum tripod, extends to 1.6m, with phone clamp.', 'listed': true},
  ];

  // Find one item by id (null if missing)
  static Map<String, dynamic>? byId(String id) {
    for (final i in items) {
      if (i['id'] == id) return i;
    }
    return null;
  }

  // Average score of lender-role reviews on this item's rentals (null = no reviews yet)
  static double? ratingOf(String itemId) {
    final rentalIds = AllRentals.rentals.where((r) => r['itemId'] == itemId).map((r) => r['id']).toSet();
    final scores = AllReviews.reviews
        .where((v) => v['role'] == 'lender' && rentalIds.contains(v['rentalId']))
        .map((v) => v['score'] as int)
        .toList();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  // The rental currently holding this item (Active or Overdue), null = free
  static Map<String, dynamic>? currentRental(String itemId) {
    for (final r in AllRentals.rentals) {
      if (r['itemId'] == itemId && (r['status'] == 'Active' || r['status'] == 'Overdue')) return r;
    }
    return null;
  }

  // Tag text for cards: Available / Back Oct 12 / Unavailable
  static String availabilityOf(String itemId) {
    final r = currentRental(itemId);
    if (r == null) return 'Available';
    if (r['status'] == 'Overdue') return 'Unavailable';
    return 'Back ${AppSettings.shortDate(r['end'])}';
  }

  static int nextNumber = 8;

  // New unique id (i8, i9, ...)
  static String newId() => 'i${nextNumber++}';

  // Listed items owned by one user (soft-deleted items have listed = false)
  static List<Map<String, dynamic>> ownedBy(String? username) {
    return items.where((i) => i['owner'] == username && i['listed'] == true).toList();
  }

  // True while a rental commits the item: Approved, Active or Overdue
  static bool isLocked(String itemId) {
    return AllRentals.rentals.any((r) => r['itemId'] == itemId && (r['status'] == 'Approved' || r['status'] == 'Active' || r['status'] == 'Overdue'));
  }

  // Total due for a rental, calculated (never stored): fee + delivery + deposit
  static int totalDue(Map<String, dynamic> rental) {
    final item = byId(rental['itemId'])!;
    final days = AppSettings.daysBetween(rental['start'], rental['end']);
    final delivery = rental['method'] == 'delivery' ? AppSettings.deliveryFee : 0;
    return (item['dailyRate'] as int) * days + delivery + (item['deposit'] as int);
  }
}