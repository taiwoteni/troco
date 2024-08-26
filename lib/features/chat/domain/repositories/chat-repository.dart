import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as Path;

import 'package:http/http.dart';
import 'package:troco/core/api/data/model/multi-part-model.dart';
import 'package:troco/core/cache/shared-preferences.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../../core/api/data/repositories/api-interface.dart';
import '../../../auth/presentation/providers/client-provider.dart';
import '../entities/chat.dart';

class ChatRepo {
  Future<List<dynamic>> getChats({required final String groupId}) async {
    final result = await ApiInterface.getRequest(
        url: 'findoneuser/${ClientProvider.readOnlyClient!.userId}');
    if (!result.error) {
      Map<dynamic, dynamic> userJson = result.messageBody!["data"];
      List groupList = userJson["groups"];
      List groupChatsList = groupList
          .firstWhere((element) => element["_id"] == groupId)["messages"];
      return groupChatsList;
    }
    // log(result.body.toString());
    return AppStorage.getChats(groupId: groupId);
  }

  static Future<HttpResponseModel> sendChat({
    required final String groupId,
    required final String message,
  }) async {
    final result = await ApiInterface.postRequest(
        url: "addMessageToGroup",

        /// For now to know that the code works.
        /// This mishap is due to Finbarr's backend.

        data: {
          "groupId": groupId,
          "userId": ClientProvider.readOnlyClient!.userId,
          "content": message,
        });

    return result;
  }

  static Future<HttpResponseModel> sendAttachment({
    required final String groupId,
    required final String attachment,
    final Uint8List? thumbnail,
    final String? message,
  }) async {
    final parsedfile = File(attachment);
    final stream = ByteStream(parsedfile.openRead());
    final length = await parsedfile.length();

    final file = MultipartFile("attachment", stream, length,
        filename: Path.basename(attachment));

    MultipartFile? thumbnailFile;

    if (thumbnail != null) {
      thumbnailFile = MultipartFile.fromBytes("thumbnail", thumbnail);
    }

    final result = await ApiInterface.multipartPostRequest(
        url: "addattachment",
        multiparts: [
          MultiPartModel.field(
              field: "userId", value: ClientProvider.readOnlyClient!.userId),
          MultiPartModel.field(field: "groupId", value: groupId),
          MultiPartModel.field(field: "content", value: message),
          MultiPartModel.file(file: file),
          if (thumbnail != null) MultiPartModel.file(file: thumbnailFile!)
        ]);

    return result;
  }

  static Future<HttpResponseModel> markAsRead(
      {required final String groupId, required final String messageId}) async {
    final result = await ApiInterface.patchRequest(url: "readrecipts", data: {
      "userId": ClientProvider.readOnlyClient!.userId,
      "groupId": groupId,
      "messageId": messageId,
    });

    return result;
  }

  static Future<HttpResponseModel> deleteChat(
      {required final Chat chat, required final String groupId}) async {
    debugPrint("Chat Id: ${chat.chatId}");
    final result = await ApiInterface.deleteRequest(
        url:
            "deletemessage/${chat.chatId}/${ClientProvider.readOnlyClient!.userId}/$groupId");
    return result;
  }

  static Future<HttpResponseModel> editChat(
      {required final Chat oldChat,
      required final String newMessage,
      required final String groupId}) async {
    final result = await ApiInterface.patchRequest(
        url:
            "updatemessage/${oldChat.chatId}/${ClientProvider.readOnlyClient!.userId}/$groupId",
        data: {"content": newMessage});
    return result;
  }
}
