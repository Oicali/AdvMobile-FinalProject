// Saved addresses; one default per owner
class AllAddresses {
  static List<Map<String, dynamic>> addresses = [
    {'id': 'a1', 'owner': 'juan', 'label': 'Home', 'street': 'Blk 5 Lot 2, Mabini St.', 'barangay': 'Brgy. San Roque', 'city': 'Quezon City', 'phone': '09171234567', 'isDefault': true},
  ];
  static int nextNumber = 2;

  // New unique id (a2, a3, ...)
  static String newId() => 'a${nextNumber++}';

  // Find one address by id (null if missing)
  static Map<String, dynamic>? byId(String id) {
    for (final a in addresses) {
      if (a['id'] == id) return a;
    }
    return null;
  }

  // All addresses belonging to one user
  static List<Map<String, dynamic>> ownedBy(String? username) {
    return addresses.where((a) => a['owner'] == username).toList();
  }
}