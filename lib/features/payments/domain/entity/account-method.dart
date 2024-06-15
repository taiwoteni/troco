import 'payment-method.dart';

class AccountMethod extends PaymentMethod{
  final String bankName, accountNumber, accountName;

  const AccountMethod({required this.bankName, required this.accountNumber, required this.accountName}): super(bankName: bankName, name: accountName);


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