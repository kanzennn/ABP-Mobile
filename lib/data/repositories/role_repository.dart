import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/api_response.dart';
import '../models/role_model.dart';

class RoleRepository {
  late final Dio _dio;

  RoleRepository(SecureStorage storage) {
    _dio = DioClient(storage).dio;
  }

  Future<ApiResponse<List<RoleModel>>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.roles);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => (d as List).map((e) => RoleModel.fromJson(e)).toList());
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getById(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.roles}/$id');
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => d as Map<String, dynamic>);
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<RoleModel>> create(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.roles, data: data);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => RoleModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<RoleModel>> update(
      int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('${ApiConstants.roles}/$id', data: data);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => RoleModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<void>> delete(int id) async {
    try {
      final res = await _dio.delete('${ApiConstants.roles}/$id');
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
