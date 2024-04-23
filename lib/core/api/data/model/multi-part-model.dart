// ignore_for_file: implementation_imports
import 'package:http/src/multipart_file.dart';

class MultiPartModel {
  final bool isFileType;
  final String? field;
  final dynamic value;
  final MultipartFile? file;

  const MultiPartModel.file({required this.file})
      : isFileType = true,
        field = null,
        value = null;

  const MultiPartModel.field({required this.field, required this.value})
      : isFileType = false,
        file = null;
}
