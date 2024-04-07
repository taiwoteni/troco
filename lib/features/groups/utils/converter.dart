import 'package:troco/features/groups/utils/enums.dart';

class GroupRoleConverter{
  static String convertToString({required final GroupRole groupRole}){
    switch(groupRole){
      case GroupRole.Buyer:
      return "buyer";
      case GroupRole.Seller:
      return "seller";
      default:
      return "admin";
    }
  }

  static GroupRole convertToRole({required final String groupString}){
    switch(groupString.trim().toLowerCase()){
      case "buyer":
      return GroupRole.Buyer;
      case "seller":
      return GroupRole.Seller;
      default:
      return GroupRole.Admin;
    }
  }
}