import 'package:troco/features/transactions/utils/enums.dart';

class ServiceRequirementsConverter {
  static ServiceRequirement convertToEnum({required final String requirement}) {
    switch (requirement.toLowerCase()) {
      // case 'produce':
      //   return ServiceRequirement.Produce;
      case 'create':
        return ServiceRequirement.Create;
      case 'design':
        return ServiceRequirement.Design;
      // case 'manufacture':
      //   return ServiceRequirement.Manufacture;
      // case 'replacement':
      //   return ServiceRequirement.Replacement;
      // default:
      //   return ServiceRequirement.Repair;
      default:
        return ServiceRequirement.Develop;
    }
  }
}
