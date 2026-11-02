import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/report_model.dart';
import '../models/waste_category_model.dart';

class ReportService {
  final DioClient _dioClient;

  ReportService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  bool _isSuccess(Map<String, dynamic> data) {
    return data['success'] == true || data['status'] == 'success';
  }

  /// Get waste categories
  Future<ApiResponse<List<WasteCategoryModel>>> getCategories() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.categories);
      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final list = (data['data'] as List)
            .map((item) => WasteCategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(list);
      } else {
        return ApiResponse.error(data['message'] ?? 'Gagal mengambil kategori sampah');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get user reports list with optional pagination & status filter
  Future<ApiResponse<List<ReportModel>>> getReports({
    int page = 1,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _dioClient.dio.get(
        ApiConstants.reports,
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        // Laravel paginate wrapper: data.data.data or data.data
        final items = data['data'] is Map && data['data']['data'] != null
            ? data['data']['data'] as List
            : data['data'] as List;

        final reports = items
            .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(reports);
      } else {
        return ApiResponse.error(data['message'] ?? 'Gagal mengambil daftar laporan');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get report detail
  Future<ApiResponse<ReportModel>> getReportDetail(int id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.reports}/$id');
      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final report = ReportModel.fromJson(data['data']);
        return ApiResponse.success(report);
      } else {
        return ApiResponse.error(data['message'] ?? 'Gagal mengambil detail laporan');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Submit a new report
  Future<ApiResponse<ReportModel>> submitReport({
    required int categoryId,
    required String description,
    required File photoFile,
    required double latitude,
    required double longitude,
    String? address,
    required String scale,
    required String urgency,
    String? aiPredictedCategory,
    double? aiConfidenceScore,
  }) async {
    try {
      final fileName = photoFile.path.split(Platform.pathSeparator).last;
      final formDataMap = <String, dynamic>{
        'category_id': categoryId,
        'description': description,
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: fileName,
        ),
        'latitude': latitude,
        'longitude': longitude,
        'scale': scale,
        'urgency': urgency,
      };

      if (address != null && address.isNotEmpty) {
        formDataMap['address'] = address;
      }
      if (aiPredictedCategory != null) {
        formDataMap['ai_predicted_category'] = aiPredictedCategory;
      }
      if (aiConfidenceScore != null) {
        formDataMap['ai_confidence_score'] = aiConfidenceScore;
      }

      final response = await _dioClient.dio.post(
        ApiConstants.reports,
        data: FormData.fromMap(formDataMap),
      );

      final data = response.data as Map<String, dynamic>;
      if (_isSuccess(data)) {
        final report = ReportModel.fromJson(data['data']);
        return ApiResponse.success(report, message: data['message']);
      } else {
        return ApiResponse.error(data['message'] ?? 'Gagal mengirim laporan');
      }
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map) {
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          final firstKey = errors.keys.first;
          return errors[firstKey][0].toString();
        }
      }
    }
    return e.message ?? 'Terjadi kesalahan pada jaringan';
  }
}
