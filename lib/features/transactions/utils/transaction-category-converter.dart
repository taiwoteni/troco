import 'enums.dart';

class TransactionCategoryConverter {
  static TransactionCategory convertToEnum({required final String category}) {
    switch (category.toLowerCase().trim()) {
      case 'product':
        return TransactionCategory.Product;
      case 'service':
        return TransactionCategory.Service;
      default:
        return TransactionCategory.Virtual;
    }
  }

  static String convertToString({required final TransactionCategory category, bool plural=false}){
    switch(category){
      case TransactionCategory.Product:
      return "Product${plural? "s":""}";
      case TransactionCategory.Service:
      return "Service${plural? "s":""}";
      case TransactionCategory.Virtual:
      return "Virtual Service${plural? "s":""}";
    }
  }
}
