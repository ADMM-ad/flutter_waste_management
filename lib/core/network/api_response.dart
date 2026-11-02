class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  bool get isSuccess => success;

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error(String message, {dynamic errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['status'] == 'success' || (json['success'] == true),
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      errors: json['errors'],
    );
  }
}
