
class AllSaved {
  static List<Map<String, dynamic>> saved = [
    {'username': 'juan', 'itemId': 'i3'},
  ];

 
  static bool isSaved(String? username, String itemId) {
    return saved.any((s) => s['username'] == username && s['itemId'] == itemId);
  }

 
  static void toggle(String? username, String itemId) {
    if (isSaved(username, itemId)) {
      saved.removeWhere((s) => s['username'] == username && s['itemId'] == itemId);
    } else {
      saved.add({'username': username, 'itemId': itemId});
    }
  }
}