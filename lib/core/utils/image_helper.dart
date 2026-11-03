import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery
  static Future<File?> pickFromGallery({
    int imageQuality = 75,
    double maxWidth = 1600,
    double maxHeight = 1600,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Pick an image from camera
  static Future<File?> pickFromCamera({
    int imageQuality = 75,
    double maxWidth = 1600,
    double maxHeight = 1600,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
