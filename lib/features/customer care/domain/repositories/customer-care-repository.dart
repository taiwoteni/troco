import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../core/api/data/model/response-model.dart';

class CustomerCareRepository {
  static Future<HttpResponseModel> createChatSession() async {
    final result = await ApiInterface.postRequest(
        url: "startChat",
        okCode: 201,
        data: {"userId": ClientProvider.readOnlyClient!.userId});

    return result;
  }

  static Future<HttpResponseModel> sendIntroCustomerCareChat({
    required final String customerCareId,
    required final String sessionId,
  }) async {
    final result = await ApiInterface.postRequest(
        url: "sendMessage/$sessionId/${ClientProvider.readOnlyClient!.userId}",
        data: {
          "senderId": customerCareId,
          "content":
              "Welcome to Troco Customer Service, ${ClientProvider.readOnlyClient!.fullName}. If you have any complaints, issues or uncertainties, feel free to ask. We're here.",
          "sessionId": sessionId
        });

    return result;
  }

  static Future<HttpResponseModel> sendChat(
      {required final String sessionId, required final String content}) async {
    final result = await ApiInterface.postRequest(
        url: "sendMessage/$sessionId/${ClientProvider.readOnlyClient!.userId}",
        data: {
          "senderId": ClientProvider.readOnlyClient!.userId,
          "content": content,
          "sessionId": sessionId
        });

    return result;
  }

  Future<List<Map<dynamic, dynamic>>> getCustomerCareMessages({
    required final String sessionId,
  }) async {
    final result = await ApiInterface.getRequest(
        url: "getcustomercaremessages/$sessionId");

    if (result.error) {
      return AppStorage.getCustomerCareChats().map((e) => e.toJson()).toList();
    }

    final sortedList = (result.messageBody!["chatSession"]["messages"] as List)
        .map(
          (e) => {
            "_id": e["_id"],
            "content": e["content"],
            "sender": e["sender"] == null
                ? result.messageBody!["chatSession"]["customerCare"]
                : e["sender"]["_id"],
            "timestamp": e["timestamp"]
          },
        )
        .toList();

    return sortedList;
  }
}
