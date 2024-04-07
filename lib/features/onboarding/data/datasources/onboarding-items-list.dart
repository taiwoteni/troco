import '../../../../core/app/asset-manager.dart';
import '../models/onboarding-item-model.dart';

List<OnboardingItemModel> onboardingItemModels(){
  return [
    OnboardingItemModel(
      imgRes: AssetManager.imageFile(name: "intro_1"),
      title: "Safe and Secure",
      description: "Your items are safe and we ensure it\ngets delivered to your location."),
      OnboardingItemModel(
      imgRes: AssetManager.imageFile(name: "intro_2"),
      title: "Engage In Business With\nUs",
      description: "We abide by the law and the\nagreement between you and your\nbusiness partner."),
      OnboardingItemModel(
      imgRes: AssetManager.imageFile(name: "intro_3"),
      title: "We Safeguard your\nMoney",
      description: "Before engaging in any transactions,\nconfer with your partner.\nAll discussions are recorded"),
      OnboardingItemModel(
      imgRes: AssetManager.imageFile(name: "intro_4"),
      title: "Get your goods safely\nfrom us",
      description: "Bring the item you wish to purchase,\nand with permission,utilize Troco to\nsecure your payment."),
  ];
}