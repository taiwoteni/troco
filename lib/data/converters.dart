
import 'enums.dart';

class RoleConverter{
  static Role convertToRole({required String role}){
    switch(role.toString().toLowerCase()){
      case "business":
      return Role.business;
      case 'merchant':
      return Role.merchant;
      default:
      return Role.student;
    }
  }
  static String convertToString({required Role role}){
    switch(role){
      case Role.business:
      return "business";
      case Role.merchant:
      return 'merchant';
      default:
      return 'student';
    }
  }
}