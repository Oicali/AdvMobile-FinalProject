
class AllReviews {
  static List<Map<String, dynamic>> reviews = [
    {'id': 'v1', 'rentalId': 'r3', 'from': 'juan', 'to': 'jon', 'role': 'lender', 'score': 5, 'comment': 'Drill worked great and delivery was on time.'},
    {'id': 'v2', 'rentalId': 'r4', 'from': 'jon', 'to': 'mika', 'role': 'lender', 'score': 4, 'comment': 'Bright picture. Pickup was smooth.'},
    {'id': 'v3', 'rentalId': 'r6', 'from': 'mika', 'to': 'jon', 'role': 'lender', 'score': 5, 'comment': 'Camera was clean and fully charged.'},
    {'id': 'v4', 'rentalId': 'r7', 'from': 'juan', 'to': 'mika', 'role': 'lender', 'score': 4, 'comment': 'Sturdy tripod. A bit scuffed.'},
    {'id': 'v5', 'rentalId': 'r8', 'from': 'jon', 'to': 'mika', 'role': 'lender', 'score': 5, 'comment': 'Great condition, easy to deal with.'},
    {'id': 'v6', 'rentalId': 'r8', 'from': 'mika', 'to': 'jon', 'role': 'borrower', 'score': 5, 'comment': 'Returned on time and in good shape.'},
  ];

  static double? averageFor(String username, String role) {
    final scores = reviews.where((v) => v['to'] == username && v['role'] == role).map((v) => v['score'] as int).toList();
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }


  static bool hasReviewed(String? username, String rentalId) {
    return reviews.any((v) => v['from'] == username && v['rentalId'] == rentalId);
  }
}