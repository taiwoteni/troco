import 'enums.dart';

class TransactionPurposeConverter {
  static TransactionPurpose convertToEnum({required final String purpose}) {
    switch (purpose.toLowerCase()) {
      case 'buying':
        return TransactionPurpose.Buying;
      default:
        return TransactionPurpose.Selling;
    }
  }
}
