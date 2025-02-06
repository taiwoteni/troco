import 'package:equatable/equatable.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/kyc/utils/kyc-converter.dart';
import '../../../kyc/utils/enums.dart';
import '../../../transactions/utils/enums.dart';
import '../../utils/category-converter.dart';

class Client extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Client.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get userId => _json["id"] ?? _json["_id"] ?? "9439430439392032";
  String get firstName => _json["firstName"]?.toString().trim() ?? "";
  String get lastName => _json["lastName"]?.toString().trim() ?? "";
  String get profile => _json["userImage"] ?? _json["profile"] ?? "null";
  String get fullName => "$firstName $lastName";
  String get email => _json["email"];
  String get referralCode => _json["referralCode"] ?? "loading...";
  double get walletBalance => double.parse((_json["wallet"] ?? "0").toString());
  String get phoneNumber => _json["phoneNumber"];
  String get businessName =>
      _json["businessName"] ?? _json["BusinessName"] ?? "--/--";
  Category get accountCategory => CategoryConverter.convertToCategory(
      category: _json["category"] ?? _json["accountType"] ?? "personal");
  String get address => _json["address"] ?? "--/--";
  String get city => _json["city"] ?? "--/--";
  String get state => _json["state"] ?? "--/--";
  String get zipcode => _json["zipcode"] ?? "--/--";
  String get bustop => _json["nearestBustop"] ?? "--/--";

  String? get transactionPin => _json["transactionPin"];

  bool get blocked => _json["blocked"] == true;

  bool get verified => kycTier == VerificationTier.Tier3;

  bool get online {
    final difference = DateTime.now().difference(lastSeen);

    return difference.inMinutes < 3;

    // return userId == ClientProvider.readOnlyClient!.userId;
  }

  DateTime get lastSeen {
    if (_json["lastSeen"] == null) {
      return DateTime.now();
    }

    final lastSeen = DateTime.parse(_json["lastSeen"]);

    return lastSeen.toLocal();
  }

  VerificationTier get kycTier =>
      KycConverter.convertToEnum(tier: _json["kycTier"].toString());

  String? get password => _json["password"];

  List<String> get blockedUsers => ((_json["blockedUsers"] ?? []) as List)
      .map(
        (e) => e.toString(),
      )
      .toList();

  bool get blockedByUser => AppStorage.getUser()!.blockedUsers.contains(userId);

  Map<dynamic, dynamic> toJson() {
    return _json;
  }

  @override
  List<Object?> get props => [userId];
}
