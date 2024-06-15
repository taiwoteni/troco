
class PaymentMethod{
  final String accountNumber;
  final int cvc;
  final String bankName;

  const PaymentMethod({required this.accountNumber, required this.bankName, required this.cvc});

  Map<dynamic,dynamic> toJson(){
    return {
      "accountNumber":accountNumber,
      "cvc":cvc,
      "bankName":bankName
    };
  }
}