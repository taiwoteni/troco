// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum AttachmentType{Image, Video, Audio, Document}
class Chat extends Equatable{
  final Map<dynamic,dynamic> _json;
  const Chat.fromJson({required final Map<dynamic,dynamic> json}): _json = json;

  bool get hasAttachment => _json.containsKey("attachment"); 
  bool get hasMessage => _json.containsKey("message") || _json.containsKey("content"); 
  DateTime get time => DateTime.parse(_json["time"] ?? _json["timestamp"]);
  String? get message => _json["message"] ?? _json["content"];
  String? get attachment => _json["attachment"];
  String get senderId => _json["sender id"] ?? _json["sender"];
  String get chatId => _json["id"] ?? _json["chatId"] ?? _json["_id"];
  String get profile =>_json["profile"]??"null";
  bool get read => _json["read"] ?? false;
  DateTime get readTime => _json.containsKey("read time")? DateTime.parse(_json["read time"] ?? DateTime.now().toIso8601String()): DateTime.now();
  
  @override
  List<Object?> get props => [chatId];

}