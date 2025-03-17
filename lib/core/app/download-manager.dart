import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as Path;

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:troco/core/app/snackbar-manager.dart';

class DownloadManager {
  final BuildContext context;
  DownloadManager({required this.context});

  Future<bool> _checkAndRequestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<void> _saveFileLocally(String filename, List<int> bytes) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = Path.join(directory.path, filename);
    File file = File(path);
    await file.writeAsBytes(bytes);
    print("File saved at $path");
  }

  Future<Directory> _getDownloadDirectory(String? subDirectory) async {
    var defaultDir = Directory(
        "/storage/emulated/0/Documents/Troco${subDirectory != null ? "/$subDirectory" : ""}");
    final useDefaultDirectory = Platform.isAndroid;
    final defaultDirExists = await defaultDir.exists();

    if (useDefaultDirectory && !defaultDirExists) {
      defaultDir = await defaultDir.create(recursive: true);
    }

    if (useDefaultDirectory) {
      return defaultDir;
    }

    return ((await getDownloadsDirectory()) ??
        (await getApplicationDocumentsDirectory()));
  }

  Future<void> downloadFile(
      String url, String fileName, String? subDirectory) async {
    var dir = await _getDownloadDirectory(subDirectory);
    var file = File('${dir.path}/${fileName}');

    try {
      final downloadResponse = await Dio().download(
        url,
        file.path,
      );

      final statusCode = (downloadResponse.statusCode ?? 400);

      if (statusCode >= 200 && statusCode < 300) {
        SnackbarManager.showBasicSnackbar(
            context: context, message: "Downloaded successfully");
      }

      // final raf = file.openSync(mode: FileMode.write);
      // raf.writeFromSync(downloadResponse.data);
      // await raf.close();
    } catch (e) {
      debugPrint(e.toString());
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Failed to download");
    }
  }

  Future<bool> isDownloaded(String fileName) async {
    Directory appDir = await getApplicationDocumentsDirectory();

    // Define the file save path
    String savePath = "${appDir.path}/$fileName";

    return await File(savePath).exists();
  }
}
