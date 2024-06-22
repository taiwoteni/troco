import 'package:equatable/equatable.dart';
import 'package:troco/features/auth/domain/entities/client.dart';

class Group extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Group.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get groupName => _json["groupName"] ?? _json["name"];
  DateTime get transactionTime =>
      DateTime.parse(_json["transactionTime"] ?? _json["deadlineTime"]);
  DateTime get createdTime => DateTime.parse(_json["creationTime"]);
  bool get usingDelivery => _json["useDelivery"];

  List<String> get members {
    // List<dynamic> membersJson = json.decode(_json["members"] ?? "[]");
    // return membersJson
    //     .map((json) => GroupMemberModel.fromJson(json: json))
    //     .toList();
    return (_json["members"] as List)
        .map(
          (e) => e.toString(),
        )
        .toList();
  }

  List<String> get transactions {
    return (_json["transactions"] as List)
        .map(
          (e) => e.toString(),
        )
        .toList();
  }
  List<Client> get sortedMembers {
    final sortedMembersJson = _json["sortedMembers"];
    if(sortedMembersJson == null){
      return [];
    }
    else{
      final clientList = (_json["sortedMembers"] as List).map((e) => Client.fromJson(json: e),).toList();
      return clientList;

    }

  }

  String get groupId => _json["id"] ?? _json["_id"];
  String get creator => members.first;
  String get adminId => _json["adminId"]??"abc";

  

  Map<dynamic, dynamic> toJson() {
    return _json;
  }

  @override
  List<Object?> get props => [groupId];
}
