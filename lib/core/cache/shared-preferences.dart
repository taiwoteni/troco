// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';

import '../../features/chat/domain/entities/chat.dart';
import '../../features/groups/domain/entities/group.dart';
import '../../features/notifications/domain/entities/notification.dart';

class AppStorage {
  static SharedPreferences? _pref;
  static final Future<SharedPreferences> _pref2 =
      SharedPreferences.getInstance();

  
  static const String USER_STORAGE_KEY = "userData";
  static const String GROUP_STORAGE_KEY = "groups";
  static const String NOTIFICATION_STORAGE_KEY = "notifications";
  static const String TRANSACTION_STORAGE_KEY = "transactions";
  static String CHAT_STORAGE_KEY ({required String groupId})=> "groups.$groupId.chats";
  static String GROUP_INVITATION_STORAGE_KEY ({required String groupId})=> "groups.$groupId.invitations";


  static Future<void> initialize() async {
    _pref = await _pref2;
  }
  // Make sure This method is called in the main method in main.dart!!
  // This is to landscape the pref and initialize it before use.

  static Future<void> saveClient({required final Client client}) async {
    await _pref!
        .setString(USER_STORAGE_KEY, jsonEncode(client.toJson()));
  }

  static Future<void> deleteUser() async {
    await _pref!.remove(USER_STORAGE_KEY);
    await _pref!.clear();
  }
  static Future<bool> clear()async{
   return await _pref!.clear();
  }

  static List<Group> getGroups() {
    final jsonString = _pref!.getString(GROUP_STORAGE_KEY);
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
    _pref!.setString(GROUP_STORAGE_KEY, json.encode(groupsJson));
  }

  static Client? getUser() {
    if (!_pref!.containsKey(USER_STORAGE_KEY)) {
      return null;
    }
    final jsonString = _pref!.getString(USER_STORAGE_KEY)!;
    final client = Client.fromJson(json: jsonDecode(jsonString));
    return client;
  }

  static List<Chat> getChats({required final String groupId}) {
    final jsonString = _pref!.getString(CHAT_STORAGE_KEY(groupId: groupId));
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

    _pref!.setString(CHAT_STORAGE_KEY(groupId: groupId), json.encode(chatsJson));
  }

  static Future<List<Client>> getInvitedClients({required final String groupId})async{
    final jsonString = _pref!.getString(GROUP_INVITATION_STORAGE_KEY(groupId: groupId));
    if (jsonString == null) {
      log("No Invitations stored in this group");
      return [];
    }
    final List<dynamic> chatsJson = json.decode(jsonString);
    return chatsJson.map((e) => Client.fromJson(json: e)).toList();
  }

  static Future<void> saveInvitedClients({required List<Client> clients, required final String groupId})async{
    _pref!.setString(GROUP_INVITATION_STORAGE_KEY(groupId: groupId), json.encode(clients.map((e) => e.toJson()).toList()));

  }



  static List<Transaction> getTransactions() {
    final jsonString = _pref!.getString(TRANSACTION_STORAGE_KEY);
    if (jsonString == null) {
      log("No Transactions stored.");
      return [];
    }
    final List<dynamic> transactionsJson = json.decode(jsonString);
    return transactionsJson.map((e) => Transaction.fromJson(json: e)).toList();
  }

  static Future<void> saveTransactions({required final List<Transaction> transactions}) async {
    List<Map<dynamic, dynamic>> transactionsJson =
        transactions.map((e) => e.toJson()).toList();

    _pref!.setString(TRANSACTION_STORAGE_KEY, json.encode(transactionsJson));
  }

  static List<Notification> getNotifications() {
    final jsonString = _pref!.getString(NOTIFICATION_STORAGE_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> notificationsJson = json.decode(jsonString);
    return notificationsJson.map((e) => Notification.fromJson(json: e)).toList();
  }

  static Future<void> saveNotifications({required final List<Notification> notifications}) async {
    List<Map<dynamic, dynamic>> notificationsJson =
        notifications.map((e) => e.toJson()).toList();

    _pref!.setString(NOTIFICATION_STORAGE_KEY, json.encode(notificationsJson));
  }

}
