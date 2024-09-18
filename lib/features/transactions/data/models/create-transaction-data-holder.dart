import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/pricings-notifier.dart';
import '../../domain/entities/transaction.dart';
import '../../utils/enums.dart';
import '../../utils/service-role.dart';

class TransactionDataHolder {
  static TransactionCategory? transactionCategory;
  static String? transactionName, location;
  static String? aboutProduct;
  static int? inspectionDays;

  /// if [inspectionPeriod] is by day
  static bool? inspectionPeriod;
  static List<SalesItem>? items;
  static ServiceRole? role;
  static String? date, id;
  static double? totalCost;

  static DateTime? inspectionPeriodToDateTime() {
    if (inspectionPeriod == null || inspectionDays == null) {
      return null;
    }
    final now = DateTime.now();

    /// I create a datetime set to the current time
    /// and assign the day or month depending on the inspectionPeriod's type
    final dateTime = now.copyWith(
        month: inspectionPeriod! ? null : inspectionDays! + now.month,
        day: inspectionPeriod! ? inspectionDays! + now.day : null);
    return dateTime;
  }

  static void clear({required WidgetRef ref}) {
    transactionCategory = null;
    id = null;
    transactionName = null;
    aboutProduct = null;
    role = null;
    inspectionDays = null;
    inspectionPeriod = null;
    location = null;
    items = null;
    date = null;

    ref.read(pricingsProvider.notifier).clear();
  }

  static void assignFrom({required final Transaction transaction}) {
    transactionCategory = transaction.transactionCategory;
    transactionName = transaction.transactionName;
    aboutProduct = transaction.transactionDetail;
    inspectionPeriod = transaction.inspectionPeriod == InspectionPeriod.Day;
    inspectionDays = transaction.inspectionDays;
    items = transaction.salesItem;
    location = transaction.location;
    date = DateFormat("dd/MM/yyyy").format(transaction.transactionTime);
    id = transaction.transactionId;
  }
}
