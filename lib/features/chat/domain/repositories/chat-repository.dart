import 'dart:developer';

import '../../../../core/api/data/model/response-model.dart';
import '../../../../core/api/data/repositories/api-interface.dart';
import '../../../auth/presentation/providers/client-provider.dart';

class ChatRepo{
  Future<List<dynamic>> getChats({required final String groupId}) async {
    final result = await ApiInterface.getRequest(
        url: 'findoneuser/${ClientProvider.readOnlyClient!.userId}');
    if (!result.error) {
      Map<dynamic, dynamic> userJson = result.messageBody!["data"];
      List groupList = userJson["groups"];
      List groupChatsList = groupList.firstWhere((element) => element["_id"] == groupId)["messages"];
      return groupChatsList;
    }
    log(result.body.toString());
    return [];
  }

  static Future<HttpResponseModel> sendChat({
    required final String groupId,
    required final String userId,
    required final String message,
  })async{
    final result = await ApiInterface.postRequest(
      url: "addMessageToGroup", 
      /// For now to know that the code works.
      /// This mishap is due to Finbarr's backend.
      okCode: 500,
      data: {
        "groupId":groupId,
        "userId":userId,
        "content":message,
      });
    
    return result;
  }
}