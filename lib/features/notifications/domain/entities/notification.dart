class Notification{
  final Map<dynamic,dynamic> _json;

  const Notification.fromJson({required final Map<dynamic,dynamic> json}):_json=json;

  Map<dynamic, dynamic> toJson(){
    return _json;
  }
  
}