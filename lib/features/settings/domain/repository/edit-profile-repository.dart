import 'package:troco/core/api/data/repositories/api-interface.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../auth/domain/entities/client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import "package:path/path.dart" as Path;
import 'package:troco/core/api/data/model/multi-part-model.dart';

class EditProfileRepository{
  static Future<HttpResponseModel> updateUserProfile({required Client client})async{
    final response = await ApiInterface.patchRequest(
      url: "updateusersetting/${client.userId}",
      data: client.toJson());

    return response;  

  }

  static Future<HttpResponseModel> uploadProfilePhoto(
      {required final String userId, required final String profilePath}) async {
    final file = await http.MultipartFile.fromPath("userImage", profilePath,
        filename: Path.basename(profilePath),
        contentType: MediaType('image', 'jpeg'));

    final result = await ApiInterface.multipartPatchRequest(
        multiparts: [MultiPartModel.file(file: file)],
        url: 'updateUserImage/$userId',
        headers: {"Content-Type": "multipart/form-data"});
    return result;
  }

}