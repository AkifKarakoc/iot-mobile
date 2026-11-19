import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/errors/failures.dart';

@injectable
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService(this._picker);

  /// Picks an image from camera. Returns null if the user closes the camera
  /// without taking a photo.
  Future<Uint8List?> pickFromCamera() async {
    try {
      // Request camera permission (shows the system dialog when needed)
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied) {
        // Android no longer shows the dialog after "Don't ask again";
        // send the user to the app settings instead.
        await openAppSettings();
        throw const CameraFailure(
            'Kamera izni kapalı. Ayarlar > İzinler bölümünden kamerayı açın.');
      }
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

      // User closed the camera without taking a photo: not an error.
      if (image == null) return null;

      // Read image bytes
      final bytes = await image.readAsBytes();
      return Uint8List.fromList(bytes);
    } catch (e) {
      if (e is Failure) rethrow;
      throw CameraFailure('Kamera hatası: $e');
    }
  }

  /// Picks an image from gallery. Returns null if the user closes the gallery
  /// without choosing an image.
  Future<Uint8List?> pickFromGallery() async {
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

      // User closed the gallery without choosing an image: not an error.
      if (image == null) return null;

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
