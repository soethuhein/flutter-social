import 'package:image_picker/image_picker.dart';

abstract class ImageService {
  Future<String?> pickFromCamera();
  Future<String?> pickFromGallery();
}

class ImagePickerService implements ImageService {
  ImagePickerService({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<String?> pickFromCamera() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.camera);
    return file?.path;
  }

  @override
  Future<String?> pickFromGallery() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }
}
