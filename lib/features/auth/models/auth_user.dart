class AuthUser {
  final int id;
  final String name;
  final String email;
  final String? phone;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
    );
  }
}
