// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/kyc/utils/kyc-converter.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/services/domain/entities/escrow-fee.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';
import 'package:troco/features/wallet/domain/entities/wallet-transaction.dart';

import '../../features/chat/domain/entities/chat.dart';
import '../../features/groups/domain/entities/group.dart';
import '../../features/kyc/utils/enums.dart';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/settings/domain/entity/settings.dart';

class AppStorage {
  static SharedPreferences? _pref;
  static final Future<SharedPreferences> _pref2 =
      SharedPreferences.getInstance();

  static const String USER_STORAGE_KEY = "userData";
  static const String GROUP_STORAGE_KEY = "groups";
  static const String FRIENDS_STORAGE_KEY = "friends";

  static const String PAYMENT_METHODS_STORAGE_KEY = "paymentMethods";
  static const String KYC_STATUS_STORAGE_KEY = "kycVerificationStatus";

  static const String NOTIFICATION_STORAGE_KEY = "notifications";
  static const String TRANSACTION_STORAGE_KEY = "transactions";
  static const String SETTINGS_STORAGE_KEY = "settings";
  static const String ESCROW_CHARGES_KEY = "escrow-charges";

  static const String REFERRALS_STORAGE_KEY = "referrals";
  static const String WALLET_HISTORY_STORAGE_KEY = "wallet-history";

  static const String CC_SESSION_KEY = "cc-session";
  static String CC_CHAT_STORAGE_KEY = "cc_chats";
  static String UNSENT_CC_CHAT_STORAGE_KEY = "cc_unsent-chats";

  static String ALL_USERS_PHONE = "all-users-phone";

  static String CHAT_STORAGE_KEY({required String groupId}) =>
      "groups.$groupId.chats";
  static String UNSENT_CHAT_STORAGE_KEY({required String groupId}) =>
      "groups.$groupId.unsent-chats";
  static String GROUP_INVITATION_STORAGE_KEY({required String groupId}) =>
      "groups.$groupId.invitations";
  static Future<void> initialize() async {
    _pref = await _pref2;
  }
  // Make sure This method is called in the main method in main.dart!!
  // This is to landscape the pref and initialize it before use.

  static Future<void> saveClient({required final Client client}) async {
    await _pref!.setString(USER_STORAGE_KEY, jsonEncode(client.toJson()));
  }

  static Future<void> deleteUser() async {
    await _pref!.remove(USER_STORAGE_KEY);
    await _pref!.clear();
  }

  static Future<bool> clear() async {
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

    // In case of any unusual errors, we should wrap in a try...catch

    try {
      final jsonString = _pref!.getString(USER_STORAGE_KEY)!;
      final client = Client.fromJson(json: jsonDecode(jsonString));
      return client;
    } catch (e) {
      return null;
    }
  }

  static List<Chat> getChats({required final String groupId}) {
    final jsonString = _pref!.getString(CHAT_STORAGE_KEY(groupId: groupId));
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> chatsJson = json.decode(jsonString);
    return chatsJson.map((e) => Chat.fromJson(json: e)).toList();
  }

  static Future<void> saveChats(
      {required final List<Chat> chats, required final String groupId}) async {
    List<Map<dynamic, dynamic>> chatsJson =
        chats.map((e) => e.toJson()).toList();

    _pref!
        .setString(CHAT_STORAGE_KEY(groupId: groupId), json.encode(chatsJson));
  }

  static List<Chat> getUnsentChats({required final String groupId}) {
    final jsonString =
        _pref!.getString(UNSENT_CHAT_STORAGE_KEY(groupId: groupId));
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> chatsJson = json.decode(jsonString);
    return chatsJson.map((e) => Chat.fromJson(json: e)).toList();
  }

  static Future<void> saveUnsentChats(
      {required final List<Chat> chats, required final String groupId}) async {
    List<Map<dynamic, dynamic>> chatsJson =
        chats.map((e) => e.toJson()).toList();

    _pref!.setString(
        UNSENT_CHAT_STORAGE_KEY(groupId: groupId), json.encode(chatsJson));
  }

  static Future<List<Client>> getInvitedClients(
      {required final String groupId}) async {
    final jsonString =
        _pref!.getString(GROUP_INVITATION_STORAGE_KEY(groupId: groupId));
    if (jsonString == null) {
      log("No Invitations stored in this group");
      return [];
    }
    final List<dynamic> chatsJson = json.decode(jsonString);
    return chatsJson.map((e) => Client.fromJson(json: e)).toList();
  }

  static Future<void> saveInvitedClients(
      {required List<Client> clients, required final String groupId}) async {
    _pref!.setString(GROUP_INVITATION_STORAGE_KEY(groupId: groupId),
        json.encode(clients.map((e) => e.toJson()).toList()));
  }

  static List<Transaction> getTransactions() {
    final jsonString = _pref!.getString(TRANSACTION_STORAGE_KEY);
    if (jsonString == null) {
      // log("No Transactions stored.");
      return [];
    }
    // log("transactions are :$jsonString");
    final List<dynamic> transactionsJson = json.decode(jsonString) as List;
    final transactions = <Transaction>[];

    for (final json in transactionsJson) {
      if ((json["pricing"] as List).isNotEmpty) {
        Transaction t = Transaction.fromJson(json: json);
        try {
          t.salesItem.length;
          transactions.add(t);
        } on TypeError {
          //Do nothing
        }
      }
    }
    return transactions;
  }

  static List<Transaction> getAllTransactions() {
    final jsonString = _pref!.getString(TRANSACTION_STORAGE_KEY);
    if (jsonString == null) {
      // log("No Transactions stored.");
      return [];
    }
    // log("transactions are :$jsonString");
    final List<dynamic> transactionsJson = json.decode(jsonString) as List;
    final transactions = transactionsJson
        .map((json) => Transaction.fromJson(json: json))
        .toList();

    return transactions;
  }

  static Future<void> saveTransactions(
      {required final List<Transaction> transactions}) async {
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
    return notificationsJson
        .map((e) => Notification.fromJson(json: e))
        .toList();
  }

  static Future<void> saveNotifications(
      {required final List<Notification> notifications}) async {
    List<Map<dynamic, dynamic>> notificationsJson =
        notifications.map((e) => e.toJson()).toList();

    _pref!.setString(NOTIFICATION_STORAGE_KEY, json.encode(notificationsJson));
  }

  static List<PaymentMethod> getPaymentMethods() {
    final jsonString = _pref!.getString(PAYMENT_METHODS_STORAGE_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> paymentMethodsJson = json.decode(jsonString) as List;
    return paymentMethodsJson
        .map((e) => e["cardNumber"] != null
            ? CardMethod.fromJson(json: e)
            : AccountMethod.fromJson(json: e))
        .toList();
  }

  static Future<void> savePaymentMethod(
      {required final List<PaymentMethod> paymentMethods}) async {
    List<Map<dynamic, dynamic>> paymentMethodsJson =
        paymentMethods.map((e) => e.toJson()).toList();

    _pref!.setString(
        PAYMENT_METHODS_STORAGE_KEY, json.encode(paymentMethodsJson));
  }

  static VerificationTier getkycVerificationStatus() {
    return KycConverter.convertToEnum(
        tier: _pref!.getString(KYC_STATUS_STORAGE_KEY) ?? "0");
  }

  static Future<void> savekycVerificationStatus(
      {required VerificationTier tier}) async {
    _pref!.setString(
        KYC_STATUS_STORAGE_KEY, KycConverter.convertToStringApi(tier: tier));
  }

  static Future<void> saveSettings({required Settings settings}) async {
    _pref!.setString(SETTINGS_STORAGE_KEY, json.encode(settings.toJson()));
  }

  static Settings getSettings() {
    final jsonString = _pref!.getString(SETTINGS_STORAGE_KEY);
    if (jsonString == null) {
      return Settings.fromJson(map: {
        "two-factor-enabled": false,
        "two-factor-method": "otp",
        "auto-logout": true,
        "app-entry-method": "password"
      });
    }

    try {
      final settingsJson = json.decode(jsonString);
      return Settings.fromJson(map: settingsJson);
    } on TypeError {
      return Settings.fromJson(map: {
        "two-factor-enabled": false,
        "two-factor-method": "otp",
        "auto-logout": true,
        "app-entry-method": "password"
      });
    }
  }

  static List<Chat> getCustomerCareChats() {
    final jsonString = _pref!.getString(CC_CHAT_STORAGE_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> chatsJson = json.decode(jsonString);
    return chatsJson.map((e) => Chat.fromJson(json: e)).toList();
  }

  static Future<void> saveCustomerCareChats(
      {required final List<Chat> chats}) async {
    List<Map<dynamic, dynamic>> chatsJson =
        chats.map((e) => e.toJson()).toList();

    _pref!.setString(CC_CHAT_STORAGE_KEY, json.encode(chatsJson));
  }

  static List<Chat> getUnsentCustomerCareChats() {
    final jsonString = _pref!.getString(UNSENT_CC_CHAT_STORAGE_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> chatsJson = json.decode(jsonString);
    return chatsJson.map((e) => Chat.fromJson(json: e)).toList();
  }

  static Future<void> saveUnsentCustomerCareChats(
      {required final List<Chat> chats}) async {
    List<Map<dynamic, dynamic>> chatsJson =
        chats.map((e) => e.toJson()).toList();

    _pref!.setString(UNSENT_CC_CHAT_STORAGE_KEY, json.encode(chatsJson));
  }

  static String? getCustomerCareSessionId() {
    return _pref!.getString(CC_SESSION_KEY);
  }

  static Future<void> saveCustomerCareSessionId(
      {required final String sessionId}) async {
    await _pref!.setString(CC_SESSION_KEY, sessionId);
  }

  static List<Client> getFriends() {
    final jsonString = _pref!.getString(FRIENDS_STORAGE_KEY);
    if (jsonString == null) {
      log("No friends Stored");
      return [];
    }
    final List<dynamic> groupsJson = json.decode(jsonString);
    return groupsJson.map((e) => Client.fromJson(json: e)).toList();
  }

  static Future<void> saveFriends({required final List<Client> friends}) async {
    List<Map<dynamic, dynamic>> friendsJson =
        friends.map((e) => e.toJson()).toList();
    _pref!.setString(FRIENDS_STORAGE_KEY, json.encode(friendsJson));
  }

  static Future<void> saveReferrals(
      {required final List<Referral> referrals}) async {
    List<Map<dynamic, dynamic>> referralsJson =
        referrals.map((e) => e.toJson()).toList();

    _pref!.setString(REFERRALS_STORAGE_KEY, json.encode(referralsJson));
  }

  static List<Referral> getReferrals() {
    final jsonString = _pref!.getString(REFERRALS_STORAGE_KEY);
    if (jsonString == null) {
      log("No friends Stored");
      return [];
    }
    final List<dynamic> referralsJson = json.decode(jsonString);
    return referralsJson.map((e) => Referral.fromJson(json: e)).toList();
  }

  static Future<void> saveWalletTransactions(
      {required final List<WalletTransaction> walletTransactions}) async {
    List<Map<dynamic, dynamic>> referralsJson =
        walletTransactions.map((e) => e.toJson()).toList();

    _pref!.setString(WALLET_HISTORY_STORAGE_KEY, json.encode(referralsJson));
  }

  static List<WalletTransaction> getWalletTransactions() {
    final jsonString = _pref!.getString(WALLET_HISTORY_STORAGE_KEY);
    if (jsonString == null) {
      log("No friends Stored");
      return [];
    }
    final List<dynamic> walletTransactionsJson = json.decode(jsonString);
    return walletTransactionsJson
        .map((e) => WalletTransaction.fromJson(json: e))
        .toList();
  }

  static Future<void> saveAllUsersPhone(
      {required final List<Client> phones}) async {
    _pref!.setString(
        ALL_USERS_PHONE,
        json.encode(phones
            .map(
              (e) => e.toJson(),
            )
            .toList()));
  }

  static List<Client> getAllUsersPhone() {
    final jsonString = _pref!.getString(ALL_USERS_PHONE);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> groupsJson = json.decode(jsonString);
    return groupsJson.map((e) => Client.fromJson(json: e)).toList();
  }

  static List<EscrowCharge> getEscrowCharges() {
    final jsonString = _pref!.getString(ESCROW_CHARGES_KEY);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> chargesJson = json.decode(jsonString);
    return chargesJson.map((e) => EscrowCharge.fromJson(json: e)).toList();
  }

  static Future<void> saveEscrowCharges(
      {required final List<EscrowCharge> escrowCharges}) async {
    List<Map<dynamic, dynamic>> escrowChargesJson =
        escrowCharges.map((e) => e.toJson()).toList();

    _pref!.setString(ESCROW_CHARGES_KEY, json.encode(escrowCharges));
  }
}
