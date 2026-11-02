import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _laravelDio;
  late final Dio _fastApiDio;

  DioClient._internal() {
    // 1. Laravel API Client
    _laravelDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.laravelBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    _laravelDio.interceptors.add(AuthInterceptor());

    // 2. FastAPI ML Client
    _fastApiDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.fastApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Dio get dio => laravelDio;

  Dio get laravelDio {
    // Dynamically update baseUrl in case it was reconfigured
    _laravelDio.options.baseUrl = ApiConstants.laravelBaseUrl;
    return _laravelDio;
  }

  Dio get fastApiDio {
    _fastApiDio.options.baseUrl = ApiConstants.fastApiBaseUrl;
    return _fastApiDio;
  }
}
