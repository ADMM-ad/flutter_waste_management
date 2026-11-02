import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../models/ai_prediction_model.dart';

class AiInferenceService {
  final Dio _dio;

  AiInferenceService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.aiBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  bool _isSuccess(Map<String, dynamic> data) {
    return data['success'] == true || data['status'] == 'success';
  }

  /// Call FastAPI microservice POST /predict
  Future<ApiResponse<AiPredictionModel>> predictWaste(File imageFile) async {
    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiConstants.aiPredict,
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final prediction = AiPredictionModel.fromJson(data['data']);
        return ApiResponse.success(prediction, message: data['message'] ?? 'Klasifikasi berhasil');
      } else {
        return ApiResponse.error(data['message'] ?? 'Klasifikasi AI gagal');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final err = e.response?.data;
        if (err is Map && err.containsKey('message')) {
          return ApiResponse.error(err['message'].toString());
        }
      }
      return ApiResponse.error(e.message ?? 'Gagal menghubungi server klasifikasi AI');
    } catch (e) {
      return ApiResponse.error('Gagal memproses gambar: $e');
    }
  }

  /// Check AI service health
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(ApiConstants.aiHealth);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
