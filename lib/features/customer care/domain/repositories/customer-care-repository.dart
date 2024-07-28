import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';

import '../../../../core/api/data/model/response-model.dart';

class CustomerCareRepository{

  static Future<HttpResponseModel> createChatSession()async{
    final result = await ApiInterface.postRequest(
      url: "startChat",
      data: {
        "userId":ClientProvider.readOnlyClient!.userId
      });

    
    return result;
  }

  static Future<HttpResponseModel> sendChat(
    {
      required final String sessionId,
      required final String content
    }
  )async{
    final result = await ApiInterface.postRequest(
      url: "sendMessage/$sessionId/${ClientProvider.readOnlyClient!.userId}",
      data: {
        "senderId":ClientProvider.readOnlyClient!.userId,
        "content":content,
        "sessionId":sessionId
      });

    
    return result;
  }

  Future<List<Chat>> getCustomerCareMessages(
    {
      required final String sessionId,
    }
  )async{
    final result = await ApiInterface.getRequest(
      url: "getcustomercaremessages/$sessionId");

      if(result.error){
        return AppStorage.getCustomerCareChats();
      }



    
    return (result.messageBody!["messages"] as List).map((e) => Chat.fromJson(json: e)).toList();
  }



}