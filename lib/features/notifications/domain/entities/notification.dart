import 'package:equatable/equatable.dart';

class Notification extends Equatable{
  final Map<dynamic,dynamic> _json;

  const Notification.fromJson({required final Map<dynamic,dynamic> json}):_json=json;

  String get id => _json["_id"];

  String get label => _json["title"] ?? "Notification";

  String get content => _json["notificationContent"];

  Map<dynamic, dynamic> toJson(){
    return _json;
  }
  
  @override
  List<Object?> get props => [id];
  
}