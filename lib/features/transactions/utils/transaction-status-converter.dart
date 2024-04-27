import 'package:troco/features/transactions/utils/enums.dart';

class TransactionStatusConverter {
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
}
