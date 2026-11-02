class ReportStatusLogModel {
  final int id;
  final String fromStatus;
  final String toStatus;
  final String? notes;
  final String? changedBy;
  final DateTime? createdAt;

  ReportStatusLogModel({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    this.notes,
    this.changedBy,
    this.createdAt,
  });

  factory ReportStatusLogModel.fromJson(Map<String, dynamic> json) {
    return ReportStatusLogModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      fromStatus: json['from_status']?.toString() ?? '',
      toStatus: json['to_status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      changedBy: json['changed_by_user'] != null && json['changed_by_user'] is Map
          ? json['changed_by_user']['name']?.toString()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_status': fromStatus,
      'to_status': toStatus,
      'notes': notes,
      'changed_by': changedBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
