class ApiConstants {
  // Ganti IP sesuai environment:
  // Android Emulator → http://10.0.2.2:8000/api
  // Real device      → http://192.168.x.x:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  static const String users = '/users';
  static const String roles = '/roles';
  static const String permissions = '/permissions';
  static const String permissionGroups = '/permission-groups';
}
