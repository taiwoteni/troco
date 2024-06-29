import 'package:equatable/equatable.dart';
import 'package:troco/features/notifications/utils/enums.dart';
import 'package:troco/features/notifications/utils/notification-type-converter.dart';

class Notification extends Equatable{
  final Map<dynamic,dynamic> _json;

  const Notification.fromJson({required final Map<dynamic,dynamic> json}):_json=json;

  String get id => _json["_id"];

  String get label => _json["title"] ?? _json["notificationTitle"] ?? "Notification";

  bool get read => _json["read"] ?? false;

  String get content => _json["notificationContent"];
  dynamic get argument => _json["argument"];

  NotificationType get type => NotificationTypeConverter.convertToType(notificationType: label);

  DateTime get time => DateTime.parse(_json["notificationTime"]);

  Map<dynamic, dynamic> toJson(){
    return _json;
  }
  
  @override
  List<Object?> get props => [id];
  
}