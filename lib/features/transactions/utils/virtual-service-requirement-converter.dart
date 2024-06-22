import 'package:troco/features/transactions/utils/enums.dart';

class VirtualServiceRequirementsConverter {
  static VirtualServiceRequirement convertToEnum({required final String requirement}) {
    switch (requirement.toLowerCase()) {
      case 'create':
        return VirtualServiceRequirement.Create;
      case 'design':
        return VirtualServiceRequirement.Design;
      case 'exchange':
        return VirtualServiceRequirement.Exchange;
      case 'develop':
        return VirtualServiceRequirement.Develop;
      case 'buying':
        return VirtualServiceRequirement.Buying;
      default:
        return VirtualServiceRequirement.Selling;
    }
  }
}
