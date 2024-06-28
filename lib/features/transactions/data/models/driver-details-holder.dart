class DriverDetailsHolder{

  static String? companyName,driverName,plateNumber,driverPhoneNumber,destination;

  static void clear(){
    companyName = null;
    driverName = null;
    plateNumber = null;
    driverPhoneNumber = null;
    destination = null;
  }

  static Map<dynamic,dynamic> toJson(){
    return {
      "companyName":companyName,
      "driverName":driverName,
      "plateNumber":plateNumber,
      "driverPhoneNumber":driverPhoneNumber,
      "destination":destination
    };
  }

}