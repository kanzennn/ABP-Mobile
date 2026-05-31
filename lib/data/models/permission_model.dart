class PermissionModel {
  final int id;
  final String name;
  final String guardName;
  final int? permissionLabelId;
  final String? createdAt;
  final String? updatedAt;

  PermissionModel({
    required this.id,
    required this.name,
    required this.guardName,
    this.permissionLabelId,
    this.createdAt,
    this.updatedAt,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      guardName: json['guard_name'] as String? ?? 'web',
      permissionLabelId: json['permission_label_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
