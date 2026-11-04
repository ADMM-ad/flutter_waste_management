import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/utils/location_helper.dart';
import '../models/ai_prediction_model.dart';
import '../models/report_model.dart';
import '../models/waste_category_model.dart';
import '../services/report_service.dart';

class ReportFormProvider with ChangeNotifier {
  final ReportService _reportService;

  ReportFormProvider({ReportService? reportService})
      : _reportService = reportService ?? ReportService();

  File? _imageFile;
  int? _selectedCategoryId;
  String _description = '';
  String _scale = 'medium'; // small, medium, large
  String _urgency = 'medium'; // low, medium, high
  double? _latitude;
  double? _longitude;
  String? _address;
  AiPredictionModel? _aiPrediction;

  bool _isSubmitting = false;
  bool _isLocating = false;
  String? _errorMessage;

  // Getters
  File? get imageFile => _imageFile;
  int? get selectedCategoryId => _selectedCategoryId;
  String get description => _description;
  String get scale => _scale;
  String get urgency => _urgency;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  AiPredictionModel? get aiPrediction => _aiPrediction;
  bool get isSubmitting => _isSubmitting;
  bool get isLocating => _isLocating;
  String? get errorMessage => _errorMessage;

  void setImageFile(File file) {
    _imageFile = file;
    notifyListeners();
  }

  void setCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setDescription(String desc) {
    _description = desc;
    notifyListeners();
  }

  void setScale(String scaleVal) {
    _scale = scaleVal;
    notifyListeners();
  }

  void setUrgency(String urgencyVal) {
    _urgency = urgencyVal;
    notifyListeners();
  }

  void setAiPrediction(AiPredictionModel? prediction, List<WasteCategoryModel> categories) {
    _aiPrediction = prediction;
    if (prediction != null) {
      // Robust fuzzy matching across keywords (organic, plastic, paper, etc.)
      final normalizedPred = prediction.predictedClass.toLowerCase();
      final keywords = ['organic', 'organik', 'plastic', 'plastik', 'paper', 'kertas'];
      String? matchedKeyword;

      for (final kw in keywords) {
        if (normalizedPred.contains(kw)) {
          matchedKeyword = kw;
          break;
        }
      }

      for (final cat in categories) {
        final catLower = cat.name.toLowerCase();
        if (catLower.contains(normalizedPred) || normalizedPred.contains(catLower)) {
          _selectedCategoryId = cat.id;
          break;
        }
        if (matchedKeyword != null && catLower.contains(matchedKeyword)) {
          _selectedCategoryId = cat.id;
          break;
        }
        // Indonesian translation alias check
        if ((matchedKeyword == 'organic' || matchedKeyword == 'organik') &&
            (catLower.contains('organik') || catLower.contains('organic'))) {
          _selectedCategoryId = cat.id;
          break;
        }
        if ((matchedKeyword == 'plastic' || matchedKeyword == 'plastik') &&
            (catLower.contains('plastik') || catLower.contains('plastic'))) {
          _selectedCategoryId = cat.id;
          break;
        }
        if ((matchedKeyword == 'paper' || matchedKeyword == 'kertas') &&
            (catLower.contains('kertas') || catLower.contains('paper'))) {
          _selectedCategoryId = cat.id;
          break;
        }
      }
    }
    notifyListeners();
  }

  /// Fetch user location via GPS and reverse geocode
  Future<void> fetchLocation() async {
    _isLocating = true;
    notifyListeners();

    try {
      final locResult = await LocationHelper.getCurrentLocation();
      _latitude = locResult.latitude;
      _longitude = locResult.longitude;
      _address = locResult.address;
    } catch (_) {
      // Keep silent or leave address empty
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  /// Submit report preserving all state if it fails
  Future<ReportModel?> submitReport() async {
    if (_imageFile == null) {
      _errorMessage = 'Silakan pilih foto sampah terlebih dahulu.';
      notifyListeners();
      return null;
    }
    if (_selectedCategoryId == null) {
      _errorMessage = 'Silakan pilih kategori sampah.';
      notifyListeners();
      return null;
    }
    if (_description.trim().isEmpty) {
      _errorMessage = 'Silakan masukkan deskripsi laporan.';
      notifyListeners();
      return null;
    }
    if (_latitude == null || _longitude == null) {
      _errorMessage = 'Lokasi GPS belum tersedia. Silakan tekan tombol deteksi lokasi.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _reportService.submitReport(
      categoryId: _selectedCategoryId!,
      description: _description.trim(),
      photoFile: _imageFile!,
      latitude: _latitude!,
      longitude: _longitude!,
      address: _address,
      scale: _scale,
      urgency: _urgency,
      aiPredictedCategory: _aiPrediction?.predictedClass,
      aiConfidenceScore: _aiPrediction?.confidenceScore,
    );

    _isSubmitting = false;

    if (response.isSuccess) {
      clearForm();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  void initForEdit(ReportModel report) {
    _imageFile = null;
    _selectedCategoryId = report.category?.id;
    _description = report.description;
    _scale = report.scale;
    _urgency = report.urgency;
    _latitude = report.latitude;
    _longitude = report.longitude;
    _address = report.address;
    if (report.aiPredictedCategory != null) {
      _aiPrediction = AiPredictionModel(
        predictedClass: report.aiPredictedCategory!,
        confidenceScore: report.aiConfidenceScore ?? 0.0,
        probabilities: {},
      );
    } else {
      _aiPrediction = null;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<ReportModel?> updateExistingReport(int reportId) async {
    if (_selectedCategoryId == null) {
      _errorMessage = 'Silakan pilih kategori sampah.';
      notifyListeners();
      return null;
    }
    if (_description.trim().isEmpty) {
      _errorMessage = 'Silakan masukkan deskripsi laporan.';
      notifyListeners();
      return null;
    }
    if (_latitude == null || _longitude == null) {
      _errorMessage = 'Lokasi GPS belum tersedia.';
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _reportService.updateReport(
      reportId: reportId,
      categoryId: _selectedCategoryId!,
      description: _description.trim(),
      photoFile: _imageFile,
      latitude: _latitude!,
      longitude: _longitude!,
      address: _address,
      scale: _scale,
      urgency: _urgency,
      aiPredictedCategory: _aiPrediction?.predictedClass,
      aiConfidenceScore: _aiPrediction?.confidenceScore,
    );

    _isSubmitting = false;

    if (response.isSuccess) {
      clearForm();
      return response.data;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  void clearForm() {
    _imageFile = null;
    _selectedCategoryId = null;
    _description = '';
    _scale = 'medium';
    _urgency = 'medium';
    _latitude = null;
    _longitude = null;
    _address = null;
    _aiPrediction = null;
    _isSubmitting = false;
    _isLocating = false;
    _errorMessage = null;
    notifyListeners();
  }
}
