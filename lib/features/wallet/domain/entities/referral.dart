import 'dart:collection';

import 'package:troco/features/wallet/utils/enums.dart';

import '../../../auth/domain/entities/client.dart';

class Referral {
  final Map<dynamic, dynamic> _json;

  const Referral.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get id => _json["userId"] ?? user.userId;

  ReferralStatus get referralStatus => _json["referralStatus"] == "completed"
      ? ReferralStatus.Completed
      : ReferralStatus.Pending;

  Client get user => Client.fromJson(json: _json["userJson"]);

  Map<dynamic, dynamic> toJson() => _json;
}
