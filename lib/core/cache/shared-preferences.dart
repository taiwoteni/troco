import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:troco/core/app/value-manager.dart';
import 'package:troco/features/auth/data/models/client.dart';

class AppStorage {
  static SharedPreferences? _pref;
  static final Future<SharedPreferences> _pref2 =
      SharedPreferences.getInstance();

  static Future<void> initialize() async {
    _pref = await _pref2;
  }
  // Make sure This method is called in the main method in main.dart!!
  // This is to landscape the pref and initialize it before use.

  static Future<void> saveClient({required final Client client}) async {
    await _pref!
        .setString(ValuesManager.USER_STORAGE_KEY, jsonEncode(client.toJson()));
  }
  static Future<void> deleteUser() async {
    await _pref!
        .remove(ValuesManager.USER_STORAGE_KEY);
  }

  static Client? getUser() {
    if(!_pref!.containsKey(ValuesManager.USER_STORAGE_KEY)){
      return null;
    }
    final jsonString = _pref!.getString(ValuesManager.USER_STORAGE_KEY)!;
    final client = Client.fromJson(json: jsonDecode(jsonString));
    return client;
  }
}
