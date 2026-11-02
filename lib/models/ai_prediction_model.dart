class AiPredictionModel {
  final String predictedClass;
  final double confidenceScore;
  final Map<String, double> probabilities;
  final double inferenceTimeMs;

  AiPredictionModel({
    required this.predictedClass,
    required this.confidenceScore,
    required this.probabilities,
    this.inferenceTimeMs = 0.0,
  });

  factory AiPredictionModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> probs = {};
    if (json['probabilities'] != null && json['probabilities'] is Map) {
      json['probabilities'].forEach((k, v) {
        probs[k.toString()] = v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
      });
    }

    return AiPredictionModel(
      predictedClass: json['predicted_class']?.toString() ?? 'Unknown',
      confidenceScore: json['confidence_score'] is num
          ? (json['confidence_score'] as num).toDouble()
          : double.tryParse(json['confidence_score']?.toString() ?? '0.0') ?? 0.0,
      probabilities: probs,
      inferenceTimeMs: json['inference_time_ms'] is num
          ? (json['inference_time_ms'] as num).toDouble()
          : double.tryParse(json['inference_time_ms']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  String get confidencePercent => '${(confidenceScore * 100).toStringAsFixed(1)}%';

  Map<String, dynamic> toJson() {
    return {
      'predicted_class': predictedClass,
      'confidence_score': confidenceScore,
      'probabilities': probabilities,
      'inference_time_ms': inferenceTimeMs,
    };
  }
}
