import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_waste_management/models/ai_prediction_model.dart';
import 'package:flutter_waste_management/models/user_model.dart';
import 'package:flutter_waste_management/models/waste_category_model.dart';

void main() {
  group('Model Serialization Tests', () {
    test('UserModel parse json correctly', () {
      final json = {
        'id': 1,
        'name': 'Warga Test',
        'email': 'warga@banksampah.id',
        'phone_number': '08123456789',
        'is_active': 1,
        'roles': [{'name': 'user'}],
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 1);
      expect(user.name, 'Warga Test');
      expect(user.email, 'warga@banksampah.id');
      expect(user.isActive, true);
      expect(user.roles.contains('user'), true);
    });

    test('WasteCategoryModel parse json correctly', () {
      final json = {
        'id': 2,
        'name': 'Plastic Waste',
        'description': 'Botol dan kemasan plastik',
      };

      final cat = WasteCategoryModel.fromJson(json);
      expect(cat.id, 2);
      expect(cat.name, 'Plastic Waste');
    });

    test('AiPredictionModel parse json and computes confidence string', () {
      final json = {
        'predicted_class': 'Plastic Waste',
        'confidence_score': 0.954,
        'probabilities': {
          'Organic Waste': 0.02,
          'Plastic Waste': 0.954,
          'Paper Waste': 0.026,
        },
        'inference_time_ms': 42.5,
      };

      final pred = AiPredictionModel.fromJson(json);
      expect(pred.predictedClass, 'Plastic Waste');
      expect(pred.confidencePercent, '95.4%');
      expect(pred.inferenceTimeMs, 42.5);
    });
  });
}
