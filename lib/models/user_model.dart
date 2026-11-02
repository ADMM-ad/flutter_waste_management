class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final bool isActive;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.isActive = true,
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedRoles = [];
    if (json['roles'] != null) {
      if (json['roles'] is List) {
        parsedRoles = (json['roles'] as List)
            .map((r) => r is Map ? (r['name'] ?? '').toString() : r.toString())
            .where((r) => r.isNotEmpty)
            .toList();
      }
    }

    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      roles: parsedRoles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'roles': roles,
    };
  }
}
