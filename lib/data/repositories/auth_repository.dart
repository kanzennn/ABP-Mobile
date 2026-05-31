import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class AuthLoginData {
  final UserModel user;
  final String accessToken;

  AuthLoginData({required this.user, required this.accessToken});

  factory AuthLoginData.fromJson(Map<String, dynamic> json) => AuthLoginData(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        accessToken: json['access_token'] as String,
      );
}

class AuthRepository {
  final SecureStorage _storage;
  late final Dio _dio;

  AuthRepository(this._storage) {
    _dio = DioClient(_storage).dio;
  }

  Future<ApiResponse<AuthLoginData>> login(
      String email, String password) async {
    try {
      final res = await _dio
          .post(ApiConstants.login, data: {'email': email, 'password': password});
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => AuthLoginData.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      final body = e.response?.data as Map<String, dynamic>?;
      return ApiResponse(
          success: false,
          message: body?['message'] as String? ?? 'Login gagal',
          errors: body?['errors']);
    }
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final res = await _dio.get(ApiConstants.profile);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => UserModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      final body = e.response?.data as Map<String, dynamic>?;
      return ApiResponse(
          success: false,
          message: body?['message'] as String? ?? 'Gagal mengambil profil');
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final res = await _dio.post(ApiConstants.logout);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>, null);
    } on DioException catch (e) {
      final body = e.response?.data as Map<String, dynamic>?;
      return ApiResponse(
          success: false,
          message: body?['message'] as String? ?? 'Logout gagal');
    }
  }
}
