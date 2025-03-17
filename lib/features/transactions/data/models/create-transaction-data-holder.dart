import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/create-transaction-provider.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/pricings-notifier.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/product-images-provider.dart';
import '../../domain/entities/transaction.dart';
import '../../utils/enums.dart';
import '../../utils/service-role.dart';

class TransactionDataHolder {
  static TransactionCategory? transactionCategory;
  static String? transactionName, location;
  static String? aboutProduct;
  static int? inspectionDays;

  /// if [inspectionPeriod] is by day
  static InspectionPeriod? inspectionPeriod;
  static List<SalesItem>? items;
  static ServiceRole? role;
  static String? date, id;
  static double? totalCost;

  static bool? isEditing;

  static DateTime? inspectionPeriodToDateTime() {
    if (inspectionPeriod == null || inspectionDays == null) {
      return null;
    }
    final now = DateTime.now();

    /// I create a datetime set to the current time
    /// and assign the day or month depending on the inspectionPeriod's type
    final dateTime = now.copyWith(
        month: inspectionPeriod != InspectionPeriod.Month
            ? null
            : inspectionDays! + now.month,
        day: inspectionPeriod == InspectionPeriod.Day
            ? inspectionDays! + now.day
            : null,
        hour: inspectionPeriod == InspectionPeriod.Hour
            ? inspectionDays! + now.hour
            : null);
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
    totalCost = null;
    items = null;
    date = null;
    isEditing = null;

    ref.read(pricingsProvider.notifier).clear();
    ref.read(removedImagesItemsProvider.notifier).state.clear();
    ref.read(createTransactionProgressProvider.notifier).state = 0;
  }

  static Map<dynamic, dynamic> toJson() {
    final isProduct = transactionCategory == TransactionCategory.Product;
    final format = DateFormat("dd/MM/yyyy");
    final json = {};
    json["transactionName"] = transactionName;
    json["aboutService"] = aboutProduct;
    json["location"] = location;
    json["typeOftransaction"] = transactionCategory?.name;
    json["DateOfWork"] = !isProduct
        ? inspectionPeriodToDateTime()!.toIso8601String()
        : format.parse(date!).toIso8601String();
    json["inspectionDays"] = inspectionDays;
    json["inspectionPeriod"] = inspectionPeriod?.name.toLowerCase();
    json["pricing"] = items
        ?.map(
          (e) => e.toJson(),
        )
        .toList();

    return json;
  }

  static Transaction toTransaction() {
    return Transaction.fromJson(json: toJson());
  }

  static void assignFrom({required final Transaction transaction}) {
    transactionCategory = transaction.transactionCategory;
    transactionName = transaction.transactionName;
    aboutProduct = transaction.transactionDetail;
    inspectionPeriod = transaction.inspectionPeriod;
    inspectionDays = transaction.inspectionDays;
    items = List.from(transaction.salesItem);
    location = transaction.location;
    if (transactionCategory == TransactionCategory.Service) {
      role = transaction.role;
    }
    date = DateFormat("dd/MM/yyyy").format(transaction.transactionTime);
    id = transaction.transactionId;

    if (transactionCategory == TransactionCategory.Service) {
      totalCost = items?.fold(0.0,
          (previousValue, element) => (previousValue ?? 0) + (element.price));
    }
  }
}
