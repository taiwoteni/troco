import 'dart:io';

import 'package:http/http.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/kyc/utils/enums.dart';
import 'package:path/path.dart' as Path;
import 'package:troco/features/kyc/utils/kyc-converter.dart';

import '../../../../core/api/data/model/multi-part-model.dart';
import '../../../../core/api/data/model/response-model.dart';

class KycRepository {
  static Future<HttpResponseModel> verifyKyc({
    required final VerificationTier tier,
    final String? photo,
    final String? document,
    final String? bill,
  }) async {
    final multiparts = <MultiPartModel>[];
    multiparts.add(MultiPartModel.field(field: "tier", value: int.parse(KycConverter.convertToStringApi(tier: tier))));

    if (photo != null) {
      var parsedfile = File(photo);
      var stream = ByteStream(parsedfile.openRead());
      var length = await parsedfile.length();
      final file = MultipartFile("photo", stream, length,
          filename: Path.basename(photo.toString()));
      multiparts.add(MultiPartModel.file(file: file));
    }
    if (document != null) {
      var parsedfile = File(document);
      var stream = ByteStream(parsedfile.openRead());
      var length = await parsedfile.length();
      final file = MultipartFile("ID_DocumentUpload", stream, length,
          filename: Path.basename(document.toString()));
      multiparts.add(MultiPartModel.file(file: file));
    }
    if (bill != null) {
      var parsedfile = File(bill);
      var stream = ByteStream(parsedfile.openRead());
      var length = await parsedfile.length();
      final file = MultipartFile("Bil_ImageUpload", stream, length,
          filename: Path.basename(bill.toString()));
      multiparts.add(MultiPartModel.file(file: file));
    }

    final result = await ApiInterface.multipartPostRequest(
      url: "kycstatus/${ClientProvider.readOnlyClient!.userId}",
      multiparts: multiparts);

      return result;
  }
}
