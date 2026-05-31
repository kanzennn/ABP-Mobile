import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repo;

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  UserProvider(this._repo);

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await _repo.getAll();
    if (res.success && res.data != null) {
      _users = res.data!;
    } else {
      _error = res.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    final res = await _repo.create(data);
    if (res.success) await fetchUsers();
    return res.success;
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    final res = await _repo.update(id, data);
    if (res.success) await fetchUsers();
    return res.success;
  }

  Future<bool> deleteUser(int id) async {
    final res = await _repo.delete(id);
    if (res.success) _users.removeWhere((u) => u.id == id);
    notifyListeners();
    return res.success;
  }
}
