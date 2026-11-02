import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ai_prediction_model.dart';
import '../services/ai_inference_service.dart';

class AiDetectionProvider with ChangeNotifier {
  final AiInferenceService _aiService;

  AiDetectionProvider({AiInferenceService? aiService})
      : _aiService = aiService ?? AiInferenceService();

  bool _isAnalyzing = false;
  AiPredictionModel? _prediction;
  String? _errorMessage;

  bool get isAnalyzing => _isAnalyzing;
  AiPredictionModel? get prediction => _prediction;
  String? get errorMessage => _errorMessage;

  /// Trigger prediction on an image file
  Future<AiPredictionModel?> analyzeImage(File imageFile) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _aiService.predictWaste(imageFile);
      _isAnalyzing = false;

      if (response.isSuccess) {
        _prediction = response.data;
        notifyListeners();
        return _prediction;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isAnalyzing = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearPrediction() {
    _prediction = null;
    _errorMessage = null;
    _isAnalyzing = false;
    notifyListeners();
  }
}
