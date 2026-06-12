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
  bool _isLoggingIn = false;

  AuthProvider(this._repo, this._storage);

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoggingIn;

  bool get isAdmin =>
      _user?.roles.any((r) => r.name.toLowerCase() == 'administrator') ?? false;

  bool get isLogistik => !_hasAdminPermissions(_user);

  bool _hasAdminPermissions(UserModel? user) {
    if (user == null) return false;
    const adminPerms = {
      'user-view', 'role-view', 'permission-view', 'permissiongroup-view',
    };
    final userPerms = user.roles
        .expand((r) => r.permissions)
        .map((p) => p.name)
        .toSet();
    return adminPerms.any((p) => userPerms.contains(p));
  }

  bool _isAllowedRole(UserModel user) => !_hasAdminPermissions(user);

  bool hasPermission(String permission) {
    if (_user == null) return false;
    if (isAdmin) return true;
    // roles.permissions sudah di-load dari API saat login/profile
    return _user!.roles
        .any((r) => r.permissions.any((p) => p.name == permission));
  }

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
    if (res.success && res.data != null && _isAllowedRole(res.data!)) {
      _user = res.data;
      _status = AuthStatus.authenticated;
    } else {
      await _storage.deleteToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoggingIn = true;
    _error = null;
    notifyListeners();

    final res = await _repo.login(email, password);
    _isLoggingIn = false;

    if (res.success && res.data != null) {
      if (!_isAllowedRole(res.data!.user)) {
        _error = 'Akses ditolak. Aplikasi ini hanya untuk pengguna Logistik.';
        notifyListeners();
        return false;
      }
      await _storage.saveToken(res.data!.accessToken);
      _user = res.data!.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _error = res.message;
    notifyListeners();
    return false;
  }

  Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    final res = await _repo.changePassword(currentPassword, newPassword);
    return res.success ? null : res.message;
  }

  Future<void> logout() async {
    await _repo.logout();
    await _storage.deleteToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
