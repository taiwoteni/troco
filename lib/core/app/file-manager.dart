import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileManager {
  static Future<File?> pickImage({final ImageSource? imageSource}) async {
    ImagePicker picker = ImagePicker();
    final XFile? xfile =
        await picker.pickImage(source: imageSource ?? ImageSource.gallery);
    if (xfile != null) {
      // final String newFilePath = (await getApplicationDocumentsDirectory()).path;
      // final Uint8List xFileBytes = await xfile.readAsBytes();
      // final File file = await convertBytesToFile(
      //     bytes: xFileBytes,
      //     path:
      //         "$newFilePath/Cache/Media/Pictures/${Path.basename(xfile.path)}");

      return File(xfile.path);
    }
    return null;
  }

  static Future<File?> pickVideo({final ImageSource? imageSource}) async {
    ImagePicker picker = ImagePicker();
    final XFile? xfile =
        await picker.pickVideo(source: imageSource ?? ImageSource.gallery);
    // TODO: FIx for ios;
    if (xfile != null) {
      // final String newFilePath = (await getApplicationDocumentsDirectory()).path;
      // final Uint8List xFileBytes = await xfile.readAsBytes();
      // final File file = await convertBytesToFile(
      //     bytes: xFileBytes,
      //     path: "$newFilePath/Cache/Media/Videos/${Path.basename(xfile.path)}");
      return File(xfile.path);
    }
    return null;
  }

  static Future<XFile?> pickMedia() async {
    ImagePicker picker = ImagePicker();

    final XFile? file = await picker.pickMedia();
    return file;
  }

  static Future<XFile?> pickDocument({final String? header}) async {
    final files = await FilePicker.platform
        .pickFiles(type: FileType.any, dialogTitle: header);

    if (files?.xFiles.isEmpty ?? true) return null;

    return files!.xFiles.first;
  }

  static Future<List<XFile>?> pickDocuments({final String? header}) async {
    final files = await FilePicker.platform.pickFiles(
        type: FileType.any, dialogTitle: header, allowMultiple: true);

    return files?.xFiles;
  }
}
