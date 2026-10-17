
class AllAddresses {
  static List<Map<String, dynamic>> addresses = [
    {'id': 'a1', 'owner': 'juan', 'label': 'Home', 'street': 'Blk 5 Lot 2, Mabini St.', 'barangay': 'Brgy. San Roque', 'city': 'Quezon City', 'phone': '09171234567', 'isDefault': true},
    {'id': 'a2', 'owner': 'mika', 'label': 'Home', 'street': '14 Sampaguita St.', 'barangay': 'Brgy. Bagumbayan', 'city': 'Quezon City', 'phone': '09181234567', 'isDefault': true},
    {'id': 'a3', 'owner': 'jon', 'label': 'Home', 'street': '27 Rizal Ave.', 'barangay': 'Brgy. Poblacion', 'city': 'Makati City', 'phone': '09191234567', 'isDefault': true},
    {'id': 'a4', 'owner': 'ana', 'label': 'Home', 'street': '9 Narra Rd.', 'barangay': 'Brgy. Kapitolyo', 'city': 'Pasig City', 'phone': '09201234567', 'isDefault': true},
  ];
  static int nextNumber = 5;


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