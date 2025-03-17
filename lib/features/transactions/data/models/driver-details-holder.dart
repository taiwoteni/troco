class DriverDetailsHolder {
  static String? companyName,
      driverName,
      plateNumber,
      backPlateNumber,
      driverPhoneNumber,
      destination;
  static DateTime? estimatedDeliveryTime;

  static void clear() {
    companyName = null;
    driverName = null;
    plateNumber = null;
    driverPhoneNumber = null;
    destination = null;
    estimatedDeliveryTime = null;
  }

  static Map<dynamic, dynamic> toJson() {
    return {
      "companyName": companyName,
      "driverName": driverName,
      "plateNumber": plateNumber,
      "backPlateNumber": backPlateNumber,
      "estimatedDeliveryTime": estimatedDeliveryTime?.toIso8601String(),
      "phoneNumber": driverPhoneNumber,
      "destination": destination
    };
  }
}
