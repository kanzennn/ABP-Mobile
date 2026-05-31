import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/api_response.dart';
import '../models/permission_label_model.dart';

class PermissionRepository {
  late final Dio _dio;

  PermissionRepository(SecureStorage storage) {
    _dio = DioClient(storage).dio;
  }

  Future<ApiResponse<List<PermissionLabelModel>>> getAll() async {
    try {
      final res = await _dio.get(ApiConstants.permissions);
      return ApiResponse.fromJson(
          res.data as Map<String, dynamic>,
          (d) => (d as List)
              .map((e) => PermissionLabelModel.fromJson(e))
              .toList());
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<PermissionLabelModel>> getById(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.permissions}/$id');
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => PermissionLabelModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<PermissionLabelModel>> create(
      Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(ApiConstants.permissions, data: data);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => PermissionLabelModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<PermissionLabelModel>> update(
      int id, Map<String, dynamic> data) async {
    try {
      final res =
          await _dio.put('${ApiConstants.permissions}/$id', data: data);
      return ApiResponse.fromJson(res.data as Map<String, dynamic>,
          (d) => PermissionLabelModel.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _error(e);
    }
  }

  Future<ApiResponse<void>> delete(int id) async {
    try {
      final res = await _dio.delete('${ApiConstants.permissions}/$id');
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
