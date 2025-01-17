import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:troco/core/app/snackbar-manager.dart';

class DownloadManager {
  final BuildContext context;
  DownloadManager({required this.context});

  Future<void> downloadFile(String url, String fileName) async {
    try {
      SnackbarManager.showBasicSnackbar(
          context: context,
          message: "Downloading...",
          mode: ContentType.warning);
      // Make the HTTP GET request
      final response = await http.get(Uri.parse(url));

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Get the device's application documents directory
        Directory appDir = await getApplicationDocumentsDirectory();

        // Define the file save path
        String savePath = "${appDir.path}/$fileName";

        // Write the file to the local file system
        File file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        SnackbarManager.showBasicSnackbar(
            context: context, message: "Downloaded File");

        print("File saved to: $savePath");
      } else {
        SnackbarManager.showErrorSnackbar(
            context: context, message: "Unable to download File");
        print(
            "Error: Failed to download file. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  Future<bool> isDownloaded(String fileName) async {
    Directory appDir = await getApplicationDocumentsDirectory();

    // Define the file save path
    String savePath = "${appDir.path}/$fileName";

    return await File(savePath).exists();
  }
}
