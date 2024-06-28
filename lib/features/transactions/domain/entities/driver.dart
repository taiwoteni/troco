class Driver{
  final Map<dynamic,dynamic> _json;
  const Driver.fromJson({required final Map<dynamic,dynamic> json}):_json = json;

  bool get checkedOut => false;

  String get companyName => _json["companyName"];
  String get driverName => _json["driverName"];
  String get plateNumber => _json["plateNumber"];
  String get destinationLocation => _json["destination"];
  String get phoneNumber => _json["phoneNumber"];
  
}