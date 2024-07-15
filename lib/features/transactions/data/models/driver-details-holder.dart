import 'package:intl/intl.dart';

class DriverDetailsHolder{

  static String? companyName,driverName,plateNumber,driverPhoneNumber,destination,estimatedDeliveryTime;

  static void clear(){
    companyName = null;
    driverName = null;
    plateNumber = null;
    driverPhoneNumber = null;
    destination = null;
    estimatedDeliveryTime = null;
  }

  static Map<dynamic,dynamic> toJson(){
    return {
      "companyName":companyName,
      "driverName":driverName,
      "plateNumber":plateNumber,
      "estimatedDeliveryTime":DateFormat("dd/MM/yyyy").parse(estimatedDeliveryTime?? DateTime.now().toIso8601String()).toIso8601String(),
      "phoneNumber":driverPhoneNumber,
      "destination":destination
    };
  }

}