class AuthUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? defaultDeliveryAddress;
  final String? defaultFulfilmentType;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.defaultDeliveryAddress,
    this.defaultFulfilmentType,
  });

  factory AuthUser.fromJson(
    Map<String, dynamic> userJson, {
    Map<String, dynamic>? profileJson,
  }) {
    return AuthUser(
      id: _asInt(userJson['id']) ?? 0,
      name: userJson['name']?.toString() ?? '',
      email: userJson['email']?.toString() ?? '',
      phone: profileJson?['phone']?.toString(),
      defaultDeliveryAddress: profileJson?['default_delivery_address']
          ?.toString(),
      defaultFulfilmentType: profileJson?['default_fulfilment_type']
          ?.toString(),
    );
  }

  AuthUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? defaultDeliveryAddress,
    String? defaultFulfilmentType,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      defaultDeliveryAddress:
          defaultDeliveryAddress ?? this.defaultDeliveryAddress,
      defaultFulfilmentType:
          defaultFulfilmentType ?? this.defaultFulfilmentType,
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
