

import 'package:troco/features/kyc/utils/enums.dart';

class KycConverter{

  static VerificationTier convertToEnum({required String tier}){
    switch(tier.toLowerCase().trim()){
      case "1":
        return VerificationTier.Tier1;
      case "2":
        return VerificationTier.Tier2;
      case "3":
        return VerificationTier.Tier3;
      default:
        return VerificationTier.None;
    }
  }
  static String convertToStringApi({required VerificationTier tier}){
    switch(tier){
      case VerificationTier.Tier1:
        return "1";
      case VerificationTier.Tier2:
        return "2";
      case VerificationTier.Tier3:
        return "3";
      default:
        return "0";
    }
  }
}