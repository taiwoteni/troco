import 'bank.dart';
import 'payment-method.dart';

class AccountMethod extends PaymentMethod{
  final String accountNumber, accountName;
  final Bank bank;
  final String? accountId;

  const AccountMethod({required this.bank, required this.accountNumber, required this.accountName, this.accountId}): super(name: accountName);

  factory AccountMethod.fromJson({required final Map<String,dynamic> json}){
    return AccountMethod(
      accountId: json["_id"],
      bank: Bank.fromJson(json: json["bank"]),
      accountNumber: json["accountNumber"],
      accountName: json["accountName"]);
  }


  @override
  Map<String, dynamic> toJson() {
    return {
      "bank":bank.toJson(),
      "accountName": accountName,
      "accountNumber":accountNumber
    };
  }

  @override
  String uuid()=> accountNumber;

  @override
  Future<String?> validate() async{
    return null;
    
  }

}