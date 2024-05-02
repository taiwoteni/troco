import '../../transactions/utils/enums.dart';

class CategoryConverter {
  static Category convertToCategory({required String category}) {
    switch (category.toString().toLowerCase()) {
      case "personal":
        return Category.Personal;
      case 'merchant':
        return Category.Merchant;
      case 'company':
        return Category.Company;
      default:
        return Category.Business;
    }
  }

  static String convertToString({required Category category}) {
    switch (category) {
      case Category.Personal:
        return "Personal";
      case Category.Merchant:
        return 'Merchant';
      case Category.Company:
        return 'Company';
      default:
        return 'Business';
    }
  }
}
