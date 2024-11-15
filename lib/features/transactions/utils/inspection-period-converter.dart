import 'package:troco/features/transactions/utils/enums.dart';

class InspectionPeriodConverter {
  static InspectionPeriod converToEnum({required String inspectionPeriod}) {
    switch (inspectionPeriod.trim().toLowerCase()) {
      case "hour":
        return InspectionPeriod.Hour;
      case "month":
        return InspectionPeriod.Month;
      default:
        return InspectionPeriod.Day;
    }
  }
}
