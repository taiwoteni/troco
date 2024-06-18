import '../../utils/enums.dart';

class Settings{
  final bool twoFactorEnabled;
  final TwoFactorMethod twoFactorMethod;
  final bool autoLogout;
  final AppEntryMethod appEntryMethod;

  const Settings({required this.twoFactorEnabled, required this.twoFactorMethod, required this.autoLogout, required this.appEntryMethod});

  factory Settings.fromJson({required final Map<dynamic,dynamic> map}){
    return Settings(
      twoFactorEnabled: map["two-factor-enabled"], 
      twoFactorMethod: map["two-factor-method"] == "pin"?TwoFactorMethod.Pin:TwoFactorMethod.Otp,
      autoLogout: map["auto-logout"],
      appEntryMethod: map["app-entry-method"] =="password"? AppEntryMethod.Password:AppEntryMethod.Pin,
    );
  }

  Map<dynamic,dynamic> toJson(){
    return {
      "two-factor-enabled":twoFactorEnabled,
      "two-factor-method": twoFactorMethod==TwoFactorMethod.Pin? "pin":"otp",
      "auto-logout":autoLogout,
      "app-entry-method":appEntryMethod==AppEntryMethod.Pin? "pin":"password"
    };
  }

}