import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:troco/core/app/value-manager.dart';
import 'package:troco/features/auth/domain/entities/client.dart';

import '../../features/chat/domain/entities/chat.dart';
import '../../features/groups/domain/entities/group.dart';

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
    await _pref!.remove(ValuesManager.USER_STORAGE_KEY);
    await _pref!.clear();
  }
  static Future<bool> clear()async{
   return await _pref!.clear();
  }

  static List<Group> getGroups() {
    final jsonString = _pref!.getString(ValuesManager.GROUP_STORAGE_KEY);
    if (jsonString == null) {
      log("No groups Stored");
      return [];
    }
    final List<dynamic> groupsJson = json.decode(jsonString);
    return groupsJson.map((e) => Group.fromJson(json: e)).toList();
  }

  static Future<void> saveGroups({required final List<Group> groups}) async {
    List<Map<dynamic, dynamic>> groupsJson =
        groups.map((e) => e.toJson()).toList();
    _pref!.setString(ValuesManager.GROUP_STORAGE_KEY, json.encode(groupsJson));
  }

  static Client? getUser() {
    if (!_pref!.containsKey(ValuesManager.USER_STORAGE_KEY)) {
      return null;
    }
    final jsonString = _pref!.getString(ValuesManager.USER_STORAGE_KEY)!;
    final client = Client.fromJson(json: jsonDecode(jsonString));
    return client;
  }

  static List<Chat> getChats({required final String groupId}) {
    final jsonString = _pref!.getString(ValuesManager.CHAT_STORAGE_KEY(groupId: groupId));
    if (jsonString == null) {
      log("No Chats stored in this group");
      return [];
    }
    final List<dynamic> chatsJson = json.decode(jsonString);
    return chatsJson.map((e) => Chat.fromJson(json: e)).toList();
  }

  static Future<void> saveChats({required final List<Chat> chats, required final String groupId}) async {
    List<Map<dynamic, dynamic>> chatsJson =
        chats.map((e) => e.toJson()).toList();

    _pref!.setString(ValuesManager.CHAT_STORAGE_KEY(groupId: groupId), json.encode(chatsJson));
  }

}
