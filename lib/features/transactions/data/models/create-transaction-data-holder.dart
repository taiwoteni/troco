import 'package:intl/intl.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import '../../domain/entities/transaction.dart';
import '../../utils/enums.dart';

class TransactionDataHolder {
  static TransactionCategory? transactionCategory;
  static String? transactionName;
  static String? aboutProduct;
  static int? inspectionDays;
  static bool? inspectionPeriod;
  static List<SalesItem>? items;
  static String? date,id;

  static void clear() {
    transactionCategory = null;
    id = null;
    transactionName = null;
    aboutProduct = null;
    inspectionDays = null;
    inspectionPeriod = null;
    items = null;
    date = null;
  }

  static void assignFrom({required final Transaction transaction}){
    transactionCategory = transaction.transactionCategory;
    transactionName = transaction.transactionName;
    aboutProduct = transaction.transactionDetail;
    inspectionPeriod = transaction.inspectionPeriod == InspectionPeriod.Day;
    inspectionDays = transaction.inspectionDays;
    items = transaction.salesItem;
    date = DateFormat("dd/MM/yyyy").format(transaction.transactionTime);
    id = transaction.transactionId;
  }
}
