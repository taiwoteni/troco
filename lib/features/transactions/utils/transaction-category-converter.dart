import 'enums.dart';

class TransactionCategoryConverter {
  static TransactionCategory convertToEnum({required final String category}) {
    switch (category.toLowerCase()) {
      case 'product':
        return TransactionCategory.Product;
      case 'service':
        return TransactionCategory.Service;
      default:
        return TransactionCategory.Virtual;
    }
  }
}
