class AppUser {
  final String id;
  final String email;
  final String role;
  final String displayName;

  AppUser({required this.id, required this.email, required this.role, required this.displayName});

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      role: map['role'],
      displayName: map['display_name'],
    );
  }
}