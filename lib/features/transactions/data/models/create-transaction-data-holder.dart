import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import '../../utils/enums.dart';

class TransactionDataHolder {
  static TransactionCategory? transactionCategory;
  static String? transactionName;
  static String? aboutProduct;
  static int? inspectionDays;
  static bool? inspectionPeriod;
  static List<SalesItem>? items;
  static String? date;

  static void clear() {
    transactionCategory = null;
    transactionName = null;
    aboutProduct = null;
    inspectionDays = null;
    inspectionPeriod = null;
    items = null;
    date = null;
  }
}
