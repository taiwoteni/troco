import '../../domain/entity/account-method.dart';

final trocoAccountDetails = [
  AccountMethod.fromJson(json: const {
    "bank": {
      "name": "Access Bank",
      "code": "044",
      "id": 1,
      "logo": "https://nigerianbanks.xyz/logo/access-bank.png"
    },
    "accountName": "Troco technology Ltd",
    "accountNumber": "1872810737"
  }),
  AccountMethod.fromJson(json: const {
    "bank": {
      "name": "United Bank For Africa",
      "code": "033",
      "id": 13,
      "logo": "https://nigerianbanks.xyz/logo/united-bank-for-africa.png",
    },
    "accountName": "Troco Technology Limited",
    "accountNumber": "1027170961"
  })
];
