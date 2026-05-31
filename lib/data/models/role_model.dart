import 'permission_model.dart';

class RoleModel {
  final int id;
  final String name;
  final String guardName;
  final String? createdAt;
  final String? updatedAt;
  final List<PermissionModel> permissions;

  RoleModel({
    required this.id,
    required this.name,
    required this.guardName,
    this.createdAt,
    this.updatedAt,
    this.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      guardName: json['guard_name'] as String? ?? 'web',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) =>
                  PermissionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
