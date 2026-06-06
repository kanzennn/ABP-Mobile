import 'package:flutter/material.dart';
import '../../data/models/role_model.dart';
import '../../data/repositories/role_repository.dart';

class RoleProvider extends ChangeNotifier {
  final RoleRepository _repo;

  List<RoleModel> _roles = [];
  bool _isLoading = false;
  String? _error;

  RoleProvider(this._repo);

  List<RoleModel> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _repo.getAll();
    if (res.success && res.data != null) {
      final enriched = await Future.wait(
        res.data!.map((role) async {
          final detail = await _repo.getById(role.id);
          if (detail.success && detail.data != null) {
            final roleData =
                detail.data!['role'] as Map<String, dynamic>?;
            if (roleData != null) return RoleModel.fromJson(roleData);
          }
          return role;
        }),
      );
      _roles = enriched;
    } else {
      _error = res.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRole(Map<String, dynamic> data) async {
    final res = await _repo.create(data);
    if (res.success) await fetchRoles();
    return res.success;
  }

  Future<bool> updateRole(int id, Map<String, dynamic> data) async {
    final res = await _repo.update(id, data);
    if (res.success) await fetchRoles();
    return res.success;
  }

  Future<bool> deleteRole(int id) async {
    final res = await _repo.delete(id);
    if (res.success) _roles.removeWhere((r) => r.id == id);
    notifyListeners();
    return res.success;
  }
}
