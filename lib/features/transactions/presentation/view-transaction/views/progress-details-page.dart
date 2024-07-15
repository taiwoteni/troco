import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../auth/presentation/providers/client-provider.dart';
import '../../../../groups/presentation/collections_page/widgets/empty-screen.dart';
import '../../../domain/entities/transaction.dart';
import '../../../utils/enums.dart';
import '../providers/transactions-provider.dart';

class ProgressDetailsPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const ProgressDetailsPage({super.key, required this.transaction});

  @override
  ConsumerState<ProgressDetailsPage> createState() =>
      _ProgressDetailsPageState();
}

class _ProgressDetailsPageState extends ConsumerState<ProgressDetailsPage> {
  late Transaction transaction;

  @override
  void initState() {
    transaction = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = MediaQuery.of(context).size.height * 0.4 +
        MediaQuery.viewPaddingOf(context).top;
    final screenHieght = MediaQuery.of(context).size.height;
    transaction = ref.watch(currentTransactionProvider);
    listenToTransactionsChanges();
    return SizedBox(
      width: double.maxFinite,
      height: screenHieght - appBarHeight,
      child: EmptyScreen(
        lottie: AssetManager.lottieFile(name: getAnimationName()),
        scale: getAnimationScale(),
        label: getAnimationLabel(),
        expanded: false,
      ),
    );
  }

  String getAnimationName() {
    final bool isSeller =
        transaction.creator == ClientProvider.readOnlyClient!.userId;
    final bool isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    switch (transaction.transactionStatus) {
      case TransactionStatus.Pending:
        return "pending";

      /// At this stage goods are being delivered.
      case TransactionStatus.Ongoing:
        return isVirtual ? "pending" : "delivery";

      /// At this stage seller is to upload driver details.
      case TransactionStatus.Processing:
        return "pending";

      /// At this stage goods have been received.
      /// Buyer is to show satisfaction
      case TransactionStatus.Finalizing:
        return transaction.buyerSatisfied
            ? (isSeller ? "money-bag" : "happy")
            : isSeller
                ? "pending"
                : "happy";
      case TransactionStatus.Completed:
        return "happy";
      case TransactionStatus.Cancelled:
        return "empty";

      /// At this stage buyer is to pay
      case TransactionStatus.Inprogress:
        return isSeller
            ? "payment-loading"
            : (transaction.paymentDone ? "pending" : "payment-loading");
      default:
        return "pending";
    }
  }

  double getAnimationScale() {
    switch (transaction.transactionStatus) {
      case TransactionStatus.Pending:
      case TransactionStatus.Processing:
        return 1.2;
      default:
        return 1.0;
    }
  }

  String getAnimationLabel() {
    final bool isSeller =
        transaction.creator == ClientProvider.readOnlyClient!.userId;
    final bool isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;

    switch (transaction.transactionStatus) {
      case TransactionStatus.Cancelled:
        return "Cancelled Transaction";
      case TransactionStatus.Inprogress:
        return isSeller
            ? "Awaiting buyer's payemnt"
            : transaction.paymentDone
                ? "Awaiting admin's approval"
                : "Waiting for your payment";
      case TransactionStatus.Processing:
        return isVirtual
            ? "Leading and Inspection period"
            : (isSeller
                ? (transaction.hasDriver
                    ? "Awaiting admin's approval"
                    : "Upload driver details")
                : "Seller is uploading driver details");
      case TransactionStatus.Ongoing:
        return isVirtual
            ? "Leading and Inspection period"
            : (isSeller
                ? "Delivering ${transaction.transactionCategory.name}(s)"
                : "${transaction.transactionCategory.name}(s) are on their way");
      case TransactionStatus.Finalizing:
        return !transaction.buyerSatisfied
            ? "Awaiting ${isSeller ? "buyer's" : "your"} satisfaction"
            : isSeller
                ? transaction.trocoPaysSeller
                    ? "You should have received\nyour revenue"
                    : "Your revenue is on the way"
                : "Hope you enjoyed our services";
      case TransactionStatus.Completed:
        return "Completed Transaction!";

      default:
        return "Waiting for ${isSeller ? "buyer" : "you"} to approve..";
    }
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        if (value
            .map((t) => t.transactionId)
            .contains(transaction.transactionId)) {
          final t = value.firstWhere(
              (tr) => tr.transactionId == transaction.transactionId);
          setState(() {
            transaction = t;
          });
        }
      });
    });
  }
}

/// Basically, this is the timeline:
/// The Transaction is on Pending when created.
/// At this point buyer is awaited to approve.
/// Once buyer approves, Transaction is In progress.
/// Buyer is awaited to pay. Once he pays => paymentDone == true.
/// Then admin has to approve.
/// Once the admin approves, the transaction is Processing.
/// The seller is awaited to upload driver details.
/// Once he does so, driverInformation.isNotEmpty.
/// Then admin has to approve. Admin approves by changing status to Ongoing.
/// Once the admin approves, the transaction is Ongoing.
/// Here, the goods or services are being delivered.
/// Buyer will be prompted to acknowledge the delivery once delivered.
/// This would be done by changing status to Finalizing
/// Once he does that, the transaction is Finalizing.
/// He would then be asked if satisfied or not.
/// Once he clicks satisfied, transactionJson will update buyerSatisfied to true.
/// After this, admin pays the Seller.
/// This would be done by paying the seller and transactionJson updating payedSeller to true.
/// Then Seller would be prompted if received payment.
/// It would be done by changing transactionStatus to Completed.
