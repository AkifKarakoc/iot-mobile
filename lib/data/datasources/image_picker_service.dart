import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/errors/failures.dart';

@injectable
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService(this._picker);

  /// Picks an image from camera
  Future<Uint8List> pickFromCamera() async {
    try {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw const CameraFailure('Kamera izni verilmedi');
      }

      // Pick image from camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        throw const CameraFailure('Fotoğraf çekimi iptal edildi');
      }

      // Read image bytes
      final bytes = await image.readAsBytes();
      return Uint8List.fromList(bytes);
    } catch (e) {
      if (e is Failure) rethrow;
      throw CameraFailure('Kamera hatası: $e');
    }
  }

  /// Picks an image from gallery
  Future<Uint8List> pickFromGallery() async {
    try {
      // Request storage permission (for older Android versions)
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        throw const CameraFailure('Resim seçimi iptal edildi');
      }

      // Read image bytes
      final bytes = await image.readAsBytes();
      return Uint8List.fromList(bytes);
    } catch (e) {
      if (e is Failure) rethrow;
      throw CameraFailure('Galeri hatası: $e');
    }
  }

  /// Shows a dialog to choose between camera and gallery
  Future<Uint8List?> pickImage({required ImageSource source}) async {
    if (source == ImageSource.camera) {
      return await pickFromCamera();
    } else {
      return await pickFromGallery();
    }
  }
}
