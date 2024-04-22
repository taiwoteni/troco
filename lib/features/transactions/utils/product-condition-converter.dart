import 'package:troco/features/transactions/utils/enums.dart';

class ProductConditionConverter {
  static ProductCondition convertToEnum({required final String condition}) {
    switch (condition.toLowerCase()) {
      case 'new':
        return ProductCondition.New;
      default:
        return ProductCondition.Used;
    }
  }
}