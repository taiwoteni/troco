// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

class Chat extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Chat.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  bool get hasAttachment =>
      _json.containsKey("attachment") && _json["attachment"] != null;
  bool get isImage =>
      hasAttachment &&
      ["jpeg", "jpg", "img", "bmp", "png"].contains(
          attachment!.substring(attachment!.lastIndexOf(".") + 1).toString());
  bool get hasMessage =>
      (_json.containsKey("message") && _json["message"] != null) ||
      (_json.containsKey("content") &&
          (_json["content"] != null
              ? _json["content"].toString().trim().isNotEmpty
              : false));
  DateTime get time => DateTime.parse(_json["time"] ?? _json["timestamp"]);
  String? get message => _json["message"] ?? _json["content"];
  String? get attachment => _json["attachment"];
  dynamic get thumbnail => _json["thumbnail"];

  String get senderId => _json["sender id"] ?? _json["sender"];
  String get chatId => _json["id"] ?? _json["chatId"] ?? _json["_id"];

  String get profile => _json["profile"] ?? "null";
  bool get read =>
      readReceipts.contains(ClientProvider.readOnlyClient!.userId) ||
      senderId == ClientProvider.readOnlyClient!.userId;
  bool get readByOthers => readReceipts
      .where(
        (element) => element.toString() != senderId,
      )
      .isNotEmpty;
  List<String> get readReceipts => ((_json["readBy"] ?? []) as List)
      .map(
        (e) => e.toString(),
      )
      .toList();
  bool get loading => _json["loading"] ?? false;
  Map<dynamic, dynamic> toJson() => _json;

  void setLoading(bool value) {
    _json["loading"] = value;
  }

  @override
  List<Object?> get props => [chatId];
}
