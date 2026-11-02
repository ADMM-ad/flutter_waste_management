class WasteCategoryModel {
  final int id;
  final String name;
  final String? description;

  WasteCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory WasteCategoryModel.fromJson(Map<String, dynamic> json) {
    return WasteCategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WasteCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
