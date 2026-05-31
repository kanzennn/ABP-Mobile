import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final SecureStorage _storage;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthProvider(this._repo, this._storage);

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final hasToken = await _storage.hasToken();
    if (!hasToken) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final res = await _repo.getProfile();
    if (res.success && res.data != null) {
      _user = res.data;
      _status = AuthStatus.authenticated;
    } else {
      await _storage.deleteToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final res = await _repo.login(email, password);
    if (res.success && res.data != null) {
      await _storage.saveToken(res.data!.accessToken);
      _user = res.data!.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _error = res.message;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _repo.logout();
    await _storage.deleteToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
