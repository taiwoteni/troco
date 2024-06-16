import 'payment-method.dart';

class AccountMethod extends PaymentMethod{
  final String bankName, accountNumber, accountName;

  const AccountMethod({required this.bankName, required this.accountNumber, required this.accountName}): super(name: accountName);

  factory AccountMethod.fromJson({required final Map<String,dynamic> json}){
    return AccountMethod(
      bankName: json["bank"],
      accountNumber: json["accountNumber"],
      accountName: json["accountName"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "bank":bankName,
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