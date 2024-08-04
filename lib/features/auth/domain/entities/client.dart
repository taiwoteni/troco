import 'package:equatable/equatable.dart';
import 'package:troco/features/kyc/utils/kyc-converter.dart';
import '../../../kyc/utils/enums.dart';
import '../../../transactions/utils/enums.dart';
import '../../utils/category-converter.dart';

class Client extends Equatable {
  final Map<dynamic, dynamic> _json;
  const Client.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  String get userId => _json["id"] ?? _json["_id"] ?? "9439430439392032";
  String get firstName => _json["firstName"].toString().trim();
  String get lastName => _json["lastName"].toString().trim();
  String get profile => _json["userImage"] ?? _json["profile"] ?? "null";
  String get fullName => "$firstName $lastName";
  String get email => _json["email"];
  String get referralCode => _json["referralCode"];
  int get walletBalance =>
      double.parse((_json["wallet"] ?? "0").toString()).toInt();
  String get phoneNumber => _json["phoneNumber"];
  String get businessName => _json["businessName"] ?? "$firstName Ventures";
  Category get accountCategory => CategoryConverter.convertToCategory(
      category: _json["category"] ?? _json["accountType"] ?? "personal");
  String get address => _json["address"];
  String get city => _json["city"];
  String get state => _json["state"];
  String get zipcode => _json["zipcode"];
  String get bustop => _json["nearestBustop"];

  String? get transactionPin => _json["transactionPin"];

  bool get blocked => _json["blocked"] != true;

  bool get online {
    final difference = DateTime.now().difference(lastSeen);

    return difference.inMinutes < 5;

    // return userId == ClientProvider.readOnlyClient!.userId;
  }

  DateTime get lastSeen {
    if (_json["lastSeen"] == null) {
      return DateTime.now();
    }

    return DateTime.parse(_json["lastSeen"]);
  }

  VerificationTier get kycTier =>
      KycConverter.convertToEnum(tier: _json["kycTier"].toString());

  String? get password => _json["password"];

  Map<dynamic, dynamic> toJson() {
    return _json;
  }

  @override
  List<Object?> get props => [userId];
}
