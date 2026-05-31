import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/api_response.dart';
import '../models/permission_group_model.dart';

class PermissionGroupRepository {
  late final Dio _dio;

  PermissionGroupRepository(SecureStorage storage) {
    _dio = DioClient(storage).dio;
  }

  Future<ApiResponse<List<PermissionGroupModel>>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.permissionGroups);
      return ApiResponse.fromJson(
          res.data as Map<String, dynamic>,
          (d) => (d as List)
              .map((e) => PermissionGroupModel.fromJson(e))
              .toList());
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<PermissionGroupModel>> create(String name) async {
    try {
      final res = await _dio
          .post(ApiConstants.permissionGroups, data: {'name': name});
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => PermissionGroupModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<PermissionGroupModel>> update(
      int id, String name) async {
    try {
      final res = await _dio
          .put('${ApiConstants.permissionGroups}/$id', data: {'name': name});
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => PermissionGroupModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<void>> delete(int id) async {
    try {
      final res =
          await _dio.delete('${ApiConstants.permissionGroups}/$id');
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
