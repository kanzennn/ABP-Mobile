import 'permission_model.dart';
import 'permission_group_model.dart';

class PermissionLabelModel {
  final int id;
  final String name;
  final int permissionGroupId;
  final String? createdAt;
  final String? updatedAt;
  final PermissionGroupModel? permissionGroup;
  final List<PermissionModel> permissions;

  PermissionLabelModel({
    required this.id,
    required this.name,
    required this.permissionGroupId,
    this.createdAt,
    this.updatedAt,
    this.permissionGroup,
    this.permissions = const [],
  });

  factory PermissionLabelModel.fromJson(Map<String, dynamic> json) {
    return PermissionLabelModel(
      id: json['id'] as int,
      name: json['name'] as String,
      permissionGroupId: json['permission_group_id'] as int,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      permissionGroup: json['permission_group'] != null
          ? PermissionGroupModel.fromJson(
              json['permission_group'] as Map<String, dynamic>)
          : null,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) =>
                  PermissionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
