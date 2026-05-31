class PermissionGroupModel {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  PermissionGroupModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory PermissionGroupModel.fromJson(Map<String, dynamic> json) {
    return PermissionGroupModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
