import '../../utils/enums.dart';

class SettingsModel{
  final String label;
  final dynamic icon;
  final IconType iconType;
  final SettingsType settingsType;
  final void Function()? onTap;
  
  const SettingsModel({required this.label, required this.icon, this.onTap, this.iconType = IconType.icon,this.settingsType = SettingsType.normal});
}