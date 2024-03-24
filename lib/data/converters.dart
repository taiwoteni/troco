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

class PhoneNumberConverter {
  static String convertToNormal(String no) {
    final String phone = no.trim();
    bool is11 = phone.length == 11 && !phone.contains("+");
    return is11 ? phone : "0${phone.trim().substring(1, 11)}";
  }

  static String convertToFull(String no) {
    final String phone = no.trim();
    bool is11 = phone.length == 11 && !phone.contains("+");
    return is11 ? "+234${phone.trim().substring(1, 11)}" : phone;
  }
}

class TransactionConverter {
  static TransactionStatus convertToStatus({required final String status}) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.Pending;
      case 'in progress':
        return TransactionStatus.Inprogress;
      case 'processing':
        return TransactionStatus.Processing;
      case 'ongoing':
        return TransactionStatus.Ongoing;
      case 'finalizing':
        return TransactionStatus.Finalizing;
      case 'completed':
        return TransactionStatus.Completed;
      default:
        return TransactionStatus.Cancelled;
    }
  }

  static String convertToStringStatus(
      {required final TransactionStatus status}) {
    switch (status) {
      case TransactionStatus.Inprogress:
        return "In Progress";
      default:
        return status.name;
    }
  }

  static ProductCondition convertToCondition(
      {required final String condition}) {
    switch (condition.toLowerCase()) {
      case 'new':
        return ProductCondition.New;
      default:
        return ProductCondition.Used;
    }
  }

  static TransactionPurpose convertToEnum({required final String purpose}) {
    switch (purpose.toLowerCase()) {
      case 'buying':
        return TransactionPurpose.Buying;
      default:
        return TransactionPurpose.Selling;
    }
  }
}
