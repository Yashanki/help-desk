class AppUser {
  final String uid;
  final String role; // "customer" | "employee"
  final String email;
  final String displayName;

  const AppUser({
    required this.uid,
    required this.role,
    required this.email,
    required this.displayName,
  });

  // Accepts both camelCase and your current "Display Name" style keys
  factory AppUser.fromMap(String uid, Map<String, dynamic> d) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = d[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return '';
    }

    return AppUser(
      uid: uid,
      role: pick(['role', 'Role']),
      email: pick(['email', 'Email']),
      displayName: pick(['displayName', 'Display Name']),
    );
  }
}
