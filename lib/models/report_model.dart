import 'waste_category_model.dart';
import 'report_status_log_model.dart';

class ReportModel {
  final int id;
  final String trackingCode;
  final int categoryId;
  final WasteCategoryModel? category;
  final String description;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final String? address;
  final String scale;
  final String urgency;
  final String status;
  final String? rejectionNote;
  final String? aiPredictedCategory;
  final double? aiConfidenceScore;
  final DateTime? createdAt;
  final List<ReportStatusLogModel> statusLogs;

  ReportModel({
    required this.id,
    required this.trackingCode,
    required this.categoryId,
    this.category,
    required this.description,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.scale,
    required this.urgency,
    required this.status,
    this.rejectionNote,
    this.aiPredictedCategory,
    this.aiConfidenceScore,
    this.createdAt,
    this.statusLogs = const [],
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    List<ReportStatusLogModel> logs = [];
    if (json['status_logs'] != null && json['status_logs'] is List) {
      logs = (json['status_logs'] as List)
          .map((item) => ReportStatusLogModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ReportModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      trackingCode: json['tracking_code']?.toString() ?? '',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id'].toString()) ?? 0,
      category: json['category'] != null && json['category'] is Map
          ? WasteCategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      description: json['description']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? '0.0') ?? 0.0,
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? '0.0') ?? 0.0,
      address: json['address']?.toString(),
      scale: json['scale']?.toString() ?? 'small',
      urgency: json['urgency']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'pending',
      rejectionNote: json['rejection_note']?.toString(),
      aiPredictedCategory: json['ai_predicted_category']?.toString(),
      aiConfidenceScore: json['ai_confidence_score'] != null
          ? (json['ai_confidence_score'] is num
              ? (json['ai_confidence_score'] as num).toDouble()
              : double.tryParse(json['ai_confidence_score'].toString()))
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      statusLogs: logs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_code': trackingCode,
      'category_id': categoryId,
      'category': category?.toJson(),
      'description': description,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'scale': scale,
      'urgency': urgency,
      'status': status,
      'rejection_note': rejectionNote,
      'ai_predicted_category': aiPredictedCategory,
      'ai_confidence_score': aiConfidenceScore,
      'created_at': createdAt?.toIso8601String(),
      'status_logs': statusLogs.map((e) => e.toJson()).toList(),
    };
  }
}
