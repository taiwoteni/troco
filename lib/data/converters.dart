import 'enums.dart';

class CatgoryConverter {
  static Category convertToCategory({required String category}) {
    switch (category.toString().toLowerCase()) {
      case "company":
        return Category.Company;
      case 'merchant':
        return Category.Merchant;
      default:
        return Category.Business;
    }
  }

  static String convertToString({required Category category}) {
    switch (category) {
      case Category.Company:
        return "Company";
      case Category.Merchant:
        return 'Merchant';
      default:
        return 'Business';
    }
  }
}
