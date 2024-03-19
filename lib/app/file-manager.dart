import 'package:image_picker/image_picker.dart';
class FileManager{
  static Future<XFile?> pickImage({final ImageSource? imageSource})async{
  ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: imageSource?? ImageSource.gallery);
    return file;
  }
  static Future<XFile?> pickVideo({final ImageSource? imageSource})async{
  ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: imageSource??ImageSource.gallery);
    return file;
  }
  static Future<XFile?> pickMedia()async{
  ImagePicker picker = ImagePicker();

    final XFile? file = await picker.pickMedia();
    return file;
  }


}