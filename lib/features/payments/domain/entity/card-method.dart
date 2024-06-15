import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/utils/card-utils.dart';

import '../../utils/enums.dart';

class CardMethod extends PaymentMethod{
  final String cardHolderName,cardNumber,cvv,expDate,bank;

  const CardMethod({
    required this.cardHolderName, 
    required this.cardNumber, 
    required this.cvv, 
    required this.expDate,
    required this.bank}): super(name: cardHolderName);

  factory CardMethod.fromJson({required final Map<String,dynamic> json}){
    return CardMethod(
      cardHolderName: json["cardHolderName"],
      cardNumber: json["cardNumber"],
      cvv: json["cvv"],
      expDate: json["expDate"],
      bank: json["bank"]);
  }

  CardType get cardType => CardUtils.getCardTypeFrmNumber(cardNumber);
  
  @override
  String uuid() => cardNumber;
  
  @override
  Future<String?> validate()async{
    return "";
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      "cardHolderName": cardHolderName,
      "cardNumber":cardNumber,
      "cvv":cvv,
      "expDate":expDate,
      "bank":bank
    };
  }
  

}