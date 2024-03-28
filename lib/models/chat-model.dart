// ignore_for_file: constant_identifier_names

enum AttachmentType{Image, Video, Audio, Document}
class Chat{
  final Map<dynamic,dynamic> _json;
  const Chat.fromJson({required final Map<dynamic,dynamic> json}): _json = json;

  bool get hasAttachment => _json.containsKey("attachment"); 
  bool get hasMessage => _json.containsKey("message"); 
  DateTime get time => DateTime.parse(_json["time"]);
  String? get message => _json["message"];
  String? get attachment => _json["attachment"];
  String get senderId => _json["sender id"];
  String get id => _json["id"];
  bool get read => _json["read"] ?? false;
  DateTime get readTime => _json.containsKey("read time")? DateTime.parse(_json["read time"]): DateTime.now();

}