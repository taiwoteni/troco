import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';

import '../../domain/entity/payment-method.dart';

class PaymentMethodDataHolder{
  
  static String? cardNumber,cvv,expDate;
  
  static String? name,bank;

  static String? accountNumber;

  static void clear(){
    cardNumber = null;
    cvv = null;
    expDate = null;
    name = null;
    bank = null;
    accountNumber = null;
  }

  static PaymentMethod toPaymentMethod(){
    if(cardNumber== null){
      return AccountMethod(
        bankName: bank!, 
        accountNumber: accountNumber!, 
        accountName: name!);
    }
    return CardMethod(
      cardHolderName: name!, 
      cardNumber: cardNumber!, 
      cvv: cvv!, 
      expDate: expDate!, 
      bank: bank!);

  }
}