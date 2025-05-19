import 'dart:io';
import 'package:dio/dio.dart';

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

  // Future<void> _saveFileLocally(String filename, List<int> bytes) async {
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   String path = Path.join(directory.path, filename);
  //   File file = File(path);
  //   await file.writeAsBytes(bytes);
  //   print("File saved at $path");
  // }

  Future<Directory> _getDownloadDirectory(String? subDirectory) async {
    var defaultDir = Platform.isIOS
        ? (await getApplicationDocumentsDirectory())
        : Directory(
            "/storage/emulated/0/Documents/Troco${subDirectory != null ? "/$subDirectory" : ""}");
    final defaultDirExists = await defaultDir.exists();

    if (!defaultDirExists) {
      defaultDir = await defaultDir.create(recursive: true);
    }

    return defaultDir;
  }

  Future<String?> downloadFile(
      String url, String fileName, String? subDirectory) async {
    final permissionGranted = await _checkAndRequestStoragePermission();

    if (!permissionGranted) {
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Enable Troco File permission to save");
      return null;
    }

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
        return file.path;
      }

      return null;
    } catch (e) {
      debugPrint(e.toString());
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Failed to download");
      return null;
    }
  }

  Future<bool> isDownloaded(String fileName, String? subDirectory) async {
    Directory appDir = await _getDownloadDirectory(subDirectory);

    // Define the file save path
    String savePath = "${appDir.path}/$fileName";

    return await File(savePath).exists();
  }
}
