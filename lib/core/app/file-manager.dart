import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import "package:path_provider/path_provider.dart";
import 'dart:io';

import 'package:troco/core/basecomponents/images/pick-profile-widget.dart';

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
}
