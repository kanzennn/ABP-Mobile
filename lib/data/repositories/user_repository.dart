import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class UserRepository {
  late final Dio _dio;

  UserRepository(SecureStorage storage) {
    _dio = DioClient(storage).dio;
  }

  Future<ApiResponse<List<UserModel>>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.users);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => (d as List).map((e) => UserModel.fromJson(e)).toList());
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<UserModel>> getById(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.users}/$id');
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => UserModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<UserModel>> create(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.users, data: data);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => UserModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<UserModel>> update(
      int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('${ApiConstants.users}/$id', data: data);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => UserModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<void>> delete(int id) async {
    try {
      final res = await _dio.delete('${ApiConstants.users}/$id');
      return ApiResponse.fromJson(res.data as Map<String, dynamic>, null);
    } on DioException catch (e) {
      return _error(e);
    }
  }

  ApiResponse<T> _error<T>(DioException e) {
    final body = e.response?.data as Map<String, dynamic>?;
    return ApiResponse<T>(
        success: false,
        message: body?['message'] as String? ?? 'Terjadi kesalahan',
        errors: body?['errors']);
  }
}
