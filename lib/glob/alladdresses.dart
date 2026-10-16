
class AllAddresses {
  static List<Map<String, dynamic>> addresses = [
    {'id': 'a1', 'owner': 'juan', 'label': 'Home', 'street': 'Blk 5 Lot 2, Mabini St.', 'barangay': 'Brgy. San Roque', 'city': 'Quezon City', 'phone': '09171234567', 'isDefault': true},
  ];
  static int nextNumber = 2;


  static String newId() => 'a${nextNumber++}';


  static Map<String, dynamic>? byId(String id) {
    for (final a in addresses) {
      if (a['id'] == id) return a;
    }
    return null;
  }


  static List<Map<String, dynamic>> ownedBy(String? username) {
    return addresses.where((a) => a['owner'] == username).toList();
  }
}