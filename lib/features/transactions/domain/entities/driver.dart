class Driver{
  final Map<dynamic,dynamic> _json;

  Driver.fromJson({required final Map<dynamic,dynamic> json}):_json=json;

  bool get checkedOut => false;
}