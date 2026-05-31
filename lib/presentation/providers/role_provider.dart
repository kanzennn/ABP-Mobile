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
      _roles = res.data!;
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
