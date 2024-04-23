import '../../domain/entities/product.dart';
import '../../utils/enums.dart';

class TransactionDataHolder {
  static TransactionCategory? transactionCategory;
  static String? transactionName;
  static String? aboutProduct;
  static int? inspectionDays;
  static bool? inspectionPeriod;
  static List<Product>? products;
  static DateTime? dateOfWork;

  static void clear() {
    transactionCategory = null;
    transactionName = null;
    aboutProduct = null;
    inspectionDays = null;
    inspectionPeriod = null;
    products = null;
    dateOfWork = null;
  }
}
