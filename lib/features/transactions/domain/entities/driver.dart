class Driver{
  final Map<dynamic,dynamic> _json;
  const Driver.fromJson({required final Map<dynamic,dynamic> json}):_json = json;

  bool get checkedOut => false;

  String get companyName => _json["companyName"]??_json["CompanyName"] ?? "Nigeria Ltd";
  String get driverName => _json["driverName"] ?? _json["name"];
  String get plateNumber => _json["plateNumber"] ?? _json["FrontPlateNumber"];
  String get backPlateNumber => _json["backPlateNumber"] ??_json["BackPlateNumber"];
  String get destinationLocation => _json["destination"] ?? _json["theDelivery"];
  String get phoneNumber => _json["phoneNumber"] ?? _json["phoneNumber"];
  DateTime get estimatedDeliveryTime => DateTime.parse(_json["estimatedDeliveryTime"] ?? _json["EstimatedDeliveryTime"]);
  
}