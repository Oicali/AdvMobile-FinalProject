class AllUsers {
  static List<Map<String, dynamic>> users = [
    {'fullname': 'Juan Dela Cruz', 'username': 'juan', 'password': 'password123', 'email': 'juan@email.com', 'phone': '09171234567', 'joined': '2026-08-01', 'verified': true},
    {'fullname': 'Mika Santos', 'username': 'mika', 'password': 'password123', 'email': 'mika@email.com', 'phone': '09181234567', 'joined': '2026-07-15', 'verified': true},
    {'fullname': 'Jon Reyes', 'username': 'jon', 'password': 'password123', 'email': 'jon@email.com', 'phone': '09191234567', 'joined': '2026-08-20', 'verified': false},
    {'fullname': 'Ana Lim', 'username': 'ana', 'password': 'password123', 'email': 'ana@email.com', 'phone': '09201234567', 'joined': '2026-09-02', 'verified': true},
    {'fullname': 'Admin', 'username': 'admin', 'password': 'admin', 'email': 'admin@rentahan.app', 'phone': '', 'joined': '2026-01-01', 'verified': true},
  ];

  // Find one user by username (null if missing)
  static Map<String, dynamic>? byUsername(String? username) {
    for (final u in users) {
      if (u['username'] == username) return u;
    }
    return null;
  }
}