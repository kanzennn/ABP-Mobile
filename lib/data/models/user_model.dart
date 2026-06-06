import 'role_model.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? status;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<RoleModel> roles;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.roles = const [],
  });

  bool get isActive {
    final s = status?.toLowerCase();
    return s != '0' && s != 'false' && s != 'inactive';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      status: json['status']?.toString(),
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
