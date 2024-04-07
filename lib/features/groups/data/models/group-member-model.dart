import 'package:troco/features/groups/utils/converter.dart';
import 'package:troco/features/groups/utils/enums.dart';

class GroupMemberModel{
  final Map<dynamic,dynamic> _json;
  GroupMemberModel.fromJson({required final Map<dynamic,dynamic> json}):_json=json;

  String get firstName => _json["first name"];
  String get lastName => _json["last name"];
  String get fullName => "$firstName $lastName";
  String get userId => _json["user id"];
  GroupRole get role => GroupRoleConverter.convertToRole(groupString: _json["group role"] ?? "seller");
  

}