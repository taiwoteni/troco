import 'dart:convert';
import 'dart:developer';

import 'package:troco/features/notifications/domain/entities/notification.dart';

import '../../../../core/api/data/model/response-model.dart';
import '../../../../core/api/data/repositories/api-interface.dart';
import '../../../../core/cache/shared-preferences.dart';
import '../../../auth/presentation/providers/client-provider.dart';

class NotificationRepo{

   static Future<HttpResponseModel> getAllNotifications() async {
    final result = await ApiInterface.findUser(
        userId: ClientProvider.readOnlyClient!.userId);

    if (result.error) {
      return HttpResponseModel(
          returnHeaderType: result.returnHeaderType,
          error: true,
          body: result.body,
          code: result.code);
    }
    final notificationsJson = result.messageBody!["data"]["notifications"];

    return HttpResponseModel(
        returnHeaderType: result.returnHeaderType,
        error: false,
        body: json.encode(notificationsJson),
        code: result.code);
  }

  static Future<HttpResponseModel> markNotificationAsRead({
    required final Notification notification,
  })async{

    final result = await ApiInterface.patchRequest(
      url: "marknotificationasread/${ClientProvider.readOnlyClient!.userId}/${notification.id}",
      data: {}
    );

    return result;


  }

  Future<List<Notification>> getNotifications()async{
    final response = await getAllNotifications();

    if(response.error){
      log("error fetching notifications from provider");
      return AppStorage.getNotifications();
    }
    else{
      final notificationsList = (json.decode(response.body) as List).map((e) => Notification.fromJson(json: e)).toList();
      return notificationsList;
    }
  }


}