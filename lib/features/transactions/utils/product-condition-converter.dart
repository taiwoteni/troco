import 'package:troco/features/transactions/utils/enums.dart';

class ProductConditionConverter {
  static ProductCondition convertToEnum({required final String condition}) {
    switch (condition.toLowerCase()) {
      case 'new':
        return ProductCondition.New;
        case 'nigerian used':
        return ProductCondition.NigerianUsed;
      default:
        return ProductCondition.ForeignUsed;
    }
  }

  static String convertToString({required final ProductCondition condition}) {
    switch (condition) {
      case ProductCondition.ForeignUsed:
        return "Foreign Used";
        case ProductCondition.NigerianUsed:
        return "Nigerian Used";
      default:
        return "New";
    }
  }
}