import '../../transactions/utils/enums.dart';

class CatgoryConverter {
  static Category convertToCategory({required String category}) {
    switch (category.toString().toLowerCase()) {
      case "admin":
        return Category.Admin;
      case 'merchant':
        return Category.Merchant;
      default:
        return Category.Business;
    }
  }

  static String convertToString({required Category category}) {
    switch (category) {
      case Category.Admin:
        return "Admin";
      case Category.Merchant:
        return 'Merchant';
      default:
        return 'Business';
    }
  }
}