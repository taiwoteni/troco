
class GroupModel{
  final Map<dynamic, dynamic> _json;
  const GroupModel.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get groupName => _json["group name"];
  DateTime get transactionTime => DateTime.parse(_json["transaction time"]);
  DateTime get createdTime => DateTime.parse(_json["creation time"]);
  bool get usingDelivery => _json["needs delivery"];
  String get id => _json["id"];
  String get adminId => _json["admin id"];
}
