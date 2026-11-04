import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  bool _isSuccess(Map<String, dynamic> data) {
    return data['success'] == true || data['status'] == 'success';
  }

  /// Register user
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone_number': phoneNumber,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final token = data['data']['token'];
        final user = UserModel.fromJson(data['data']['user']);
        await LocalStorageService.setToken(token);
        return ApiResponse.success(user, message: data['message'] ?? 'Registrasi berhasil');
      } else {
        return ApiResponse.error(data['message'] ?? 'Registrasi gagal');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Login user
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final token = data['data']['token'];
        final user = UserModel.fromJson(data['data']['user']);
        await LocalStorageService.setToken(token);
        return ApiResponse.success(user, message: data['message'] ?? 'Login berhasil');
      } else {
        return ApiResponse.error(data['message'] ?? 'Login gagal');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get current user profile
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.me);
      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final user = UserModel.fromJson(data['data']);
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error(data['message'] ?? 'Gagal mengambil profil');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Update profile
  Future<ApiResponse<UserModel>> updateProfile({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'phone_number': phoneNumber,
      };
      if (email != null && email.trim().isNotEmpty) {
        payload['email'] = email.trim();
      }

      final response = await _dioClient.dio.put(
        ApiConstants.updateProfile,
        data: payload,
      );
      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final user = UserModel.fromJson(data['data']);
        return ApiResponse.success(user, message: data['message'] ?? 'Profil berhasil diperbarui');
      } else {
        return ApiResponse.error(data['message'] ?? 'Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        ApiConstants.updatePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        return ApiResponse.success(null, message: data['message'] ?? 'Kata sandi berhasil diperbarui');
      } else {
        return ApiResponse.error(data['message'] ?? 'Gagal memperbarui kata sandi');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Logout
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.logout);
      await LocalStorageService.clear();
      final data = response.data is Map ? response.data as Map<String, dynamic> : {};
      return ApiResponse.success(null, message: data['message'] ?? 'Logout berhasil');
    } on DioException catch (e) {
      await LocalStorageService.clear();
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      await LocalStorageService.clear();
      return ApiResponse.error(e.toString());
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return e.message ?? 'Terjadi kesalahan pada jaringan';
  }
}
