import 'dart:collection';

import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/wallet/utils/enums.dart';

import '../../../auth/domain/entities/client.dart';

class Referral {
  final Map<dynamic, dynamic> _json;

  const Referral.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get id => _json["userId"] ?? _json["_id"];

  String get email => _json["email"];

  String get fullName => _json["firstName"] + " " + _json["lastName"];

  String get profile =>
      _json["userImage"] ?? ClientProvider.readOnlyClient!.profile;

  ReferralStatus get referralStatus =>
      (_json["referralStatus"] ?? _json["status"]) == "completed"
          ? ReferralStatus.Completed
          : ReferralStatus.Pending;

  Map<dynamic, dynamic> toJson() => _json;
}
