// Saved Items: one row per (username, itemId) pair
class AllSaved {
  static List<Map<String, dynamic>> saved = [
    {'username': 'juan', 'itemId': 'i3'},
  ];

  // Has this user saved this item?
  static bool isSaved(String? username, String itemId) {
    return saved.any((s) => s['username'] == username && s['itemId'] == itemId);
  }

  // Save if not saved, remove if already saved
  static void toggle(String? username, String itemId) {
    if (isSaved(username, itemId)) {
      saved.removeWhere((s) => s['username'] == username && s['itemId'] == itemId);
    } else {
      saved.add({'username': username, 'itemId': itemId});
    }
  }
}