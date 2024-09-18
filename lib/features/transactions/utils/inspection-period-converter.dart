import 'package:troco/features/transactions/utils/enums.dart';

class InspectionPeriodConverter {
  static InspectionPeriod converToEnum({required String inspectionPeriod}) {
    switch (inspectionPeriod.trim().toLowerCase()) {
      case "hour":
        return InspectionPeriod.Hour;
      case "minute":
        return InspectionPeriod.Minute;
      default:
        return InspectionPeriod.Day;
    }
  }
}
