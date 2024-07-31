import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../transactions/domain/entities/transaction.dart';

class Group extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Group.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get groupName => _json["groupName"] ?? _json["name"];
  DateTime get transactionTime =>
      DateTime.parse(_json["transactionTime"] ?? _json["deadlineTime"]);
  DateTime get createdTime => DateTime.parse(_json["creationTime"]);
  bool get usingDelivery => _json["useDelivery"];
  bool get complete => members.length >= 3;

  List<String> get members {
    // List<dynamic> membersJson = json.decode(_json["members"] ?? "[]");
    // return membersJson
    //     .map((json) => GroupMemberModel.fromJson(json: json))
    //     .toList();
    return (_json["members"] as List)
        .map(
          (e) => e.toString(),
        )
        .toList();
  }

  List<String> get _transactions {
    return (_json["transactions"] as List)
        .map(
          (e) => e.toString(),
        )
        .toList();
  }

  bool get hasTransaction =>
      _transactions.isNotEmpty &&
      AppStorage.getAllTransactions()
          .map(
            (e) => e.transactionId,
          )
          .contains(_transactions.first);

  Transaction get transaction {
    final transactions = AppStorage.getAllTransactions();
    final _transaction = transactions.firstWhere(
        (transaction) => transaction.transactionId == _transactions[0]);
    return _transaction;
  }

  bool get transactionIsHampered =>
      hasTransaction && transaction.salesItem.isEmpty;

  List<Client> get sortedMembers {
    final sortedMembersJson = _json["sortedMembers"];
    if (sortedMembersJson == null) {
      return [];
    } else {
      final clientList = (_json["sortedMembers"] as List)
          .map(
            (e) => Client.fromJson(json: e),
          )
          .toList();
      return clientList;
    }
  }

  String get groupId => _json["id"] ?? _json["_id"];
  String get creator => members.first;
  String get adminId => _json["adminId"] ?? "abc";
  String get buyerId =>
      members.firstWhere((element) => ![creator, adminId].contains(element));

  Client get seller {
    return sortedMembers.firstWhere(
      (element) => element.userId == members.first,
    );
  }

  Client get admin {
    return sortedMembers.firstWhere(
      (element) => element.userId == adminId,
    );
  }

  Client? get buyer {
    if (members.length < 3) {
      return null;
    }
    log((seller.userId == ClientProvider.readOnlyClient!.userId).toString());
    return sortedMembers.firstWhere(
        (element) => ![seller.userId, admin.userId].contains(element.userId));
  }

  Map<dynamic, dynamic> toJson() {
    return _json;
  }

  @override
  List<Object?> get props => [groupId];
}
