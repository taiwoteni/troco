import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/transaction-category-converter.dart';

class EscrowCharge {
  final Map<dynamic, dynamic> _json;

  const EscrowCharge.fromJson({required final Map<dynamic, dynamic> json})
      : _json = json;

  double get percentage =>
      double.parse(_json["percentage"]?.toString() ?? "20") / 100;

  TransactionCategory get category =>
      TransactionCategoryConverter.convertToEnum(
          category: _json["category"] ?? "virtual");

  Map<dynamic, dynamic> toJson() {
    return _json;
  }
}
