import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../auth/presentation/providers/client-provider.dart';
import '../../../../groups/presentation/collections_page/widgets/empty-screen.dart';
import '../../../domain/entities/service.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/virtual-service.dart';
import '../../../utils/enums.dart';
import '../../../utils/service-role.dart';
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
        flip: transaction.transactionStatus == TransactionStatus.Processing &&
            transaction.hasReturnTransaction &&
            transaction.transactionPurpose == TransactionPurpose.Buying,
        expanded: false,
      ),
    );
  }

  String getAnimationName() {
    final bool isSeller =
        transaction.creator == ClientProvider.readOnlyClient!.userId;
    final bool isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final bool isService =
        transaction.transactionCategory == TransactionCategory.Service;
    switch (transaction.transactionStatus) {
      case TransactionStatus.Pending:
        return "pending";

      /// At this stage goods are being delivered.
      case TransactionStatus.Ongoing:
        return (isVirtual || isService)
            ? isVirtual
                ? getVirtualAnimationName()
                : isService
                    ? getServiceAnimationName()
                    : isSeller
                        ? "payment-loading"
                        : (transaction.paymentDone
                            ? "pending"
                            : "payment-loading")
            : "delivery";

      /// At this stage seller is to upload driver details.
      case TransactionStatus.Processing:
        return (isVirtual || isService)
            ? isVirtual
                ? getVirtualAnimationName()
                : isService
                    ? getServiceAnimationName()
                    : isSeller
                        ? "payment-loading"
                        : (transaction.paymentDone
                            ? "pending"
                            : "payment-loading")
            : transaction.hasReturnTransaction &&
                    transaction.transactionPurpose == TransactionPurpose.Buying
                ? "delivery"
                : "pending";

      /// At this stage goods have been received.
      /// Buyer is to show satisfaction
      case TransactionStatus.Finalizing:
        return (isVirtual || isService)
            ? "pending"
            : transaction.buyerSatisfied
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
        return isVirtual
            ? getVirtualAnimationName()
            : isService
                ? getServiceAnimationName()
                : isSeller
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

    final bool isService =
        transaction.transactionCategory == TransactionCategory.Service;

    final realCreatorIsClient = transaction.role == ServiceRole.Client;
    final realClient = transaction.realClient;
    final name = realCreatorIsClient ? "client" : "developer";

    final oppName = name == "client" ? "developer" : "client";

    switch (transaction.transactionStatus) {
      case TransactionStatus.Cancelled:
        return "Cancelled Transaction";
      case TransactionStatus.Inprogress:
        return isService
            ? getServiceAnimationLabel()
            : isVirtual
                ? getVirtualAnimationLabel()
                : isSeller
                    ? "Awaiting buyer's payemnt"
                    : transaction.paymentDone
                        ? "Awaiting admin's approval"
                        : "Waiting for your payment";
      case TransactionStatus.Processing:
        return (isVirtual || isService)
            ? (isService
                ? getServiceAnimationLabel()
                : getVirtualAnimationLabel())
            : transaction.hasReturnTransaction
                ? getReturnTransactionAnimationLabel()
                : (transaction.hasDriver
                    ? "Awaiting admin's approval"
                    : (isSeller
                        ? "Upload driver details"
                        : "waiting for driver details"));

      case TransactionStatus.Ongoing:
        return (isVirtual || isService)
            ? isService
                ? getServiceAnimationLabel()
                : isVirtual
                    ? getVirtualAnimationLabel()
                    : isSeller
                        ? "Awaiting buyer's payemnt"
                        : transaction.paymentDone
                            ? "Awaiting admin's approval"
                            : "Waiting for your payment"
            : ((transaction.hasReturnTransaction ? !isSeller : isSeller)
                ? "Delivering ${transaction.hasReturnTransaction ? "returned" : ""} product(s)"
                : "${transaction.hasReturnTransaction ? "Returned product(s)" : "Product(s)"} are on their way");
      case TransactionStatus.Finalizing:
        return (isService || isVirtual)
            ? "Admin finalizing transaction..."
            : !transaction.buyerSatisfied
                ? "Awaiting ${isSeller ? "buyer's" : "your"} satisfaction"
                : isSeller
                    ? transaction.trocoPaysSeller
                        ? "You should have received\nyour revenue"
                        : "Your revenue is on the way"
                    : "Hope you enjoyed our services";
      case TransactionStatus.Completed:
        return "Completed Transaction!";

      default:
        return "Waiting for ${isService ? (realClient ? "you" : oppName) : "buyer"} to approve..";
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

  String getServiceAnimationLabel() {
    String description = "Waiting For Admin";
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final tasks = transaction.salesItem
        .map(
          (e) => e as Service,
        )
        .toList();
    // We get the current task being done
    final pendingTask = tasks.firstWhere(
        (task) =>
            !task.taskUploaded ||
            !task.paymentMade ||
            !task.approvePayment ||
            !task.clientSatisfied ||
            !task.paymentReleased,
        orElse: () => tasks.last);

    int index = tasks.indexOf(pendingTask);

    if (!pendingTask.paymentMade) {
      description = isBuyer
          ? "Make payment for Task ${index + 1}"
          : "Waiting for client's payment";
      return description;
    }

    if (!pendingTask.approvePayment) {
      return "Admin approving payment for task ${index + 1}..";
    }

    if (!pendingTask.taskUploaded) {
      description = isBuyer
          ? "Waiting for developer's work...."
          : "Upload your work for task ${index + 1}";
      return description;
    }

    if (!pendingTask.clientSatisfied) {
      if (isBuyer) {
        return "Are you satisfied with the developer's work?";
      }
      return "Waiting for client's impression...";
    }

    return description;
  }

  String getServiceAnimationName() {
    String animation = "pending";
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final tasks = transaction.salesItem
        .map(
          (e) => e as Service,
        )
        .toList();
    // We get the current task being done
    final pendingTask = tasks.firstWhere(
        (task) =>
            !task.taskUploaded ||
            !task.paymentMade ||
            !task.approvePayment ||
            !task.clientSatisfied ||
            !task.paymentReleased,
        orElse: () => tasks.last);

    int index = tasks.indexOf(pendingTask);

    if (!pendingTask.paymentMade) {
      animation = isBuyer ? "payment-loading" : "pending";
      return animation;
    }

    if (!pendingTask.approvePayment) {
      return "pending";
    }

    if (!pendingTask.taskUploaded) {
      animation = isBuyer ? "pending" : "kyc-document";
      return animation;
    }

    if (!pendingTask.clientSatisfied) {
      if (isBuyer) {
        return "happy";
      }

      return "pending";
    }

    return animation;
  }

  String getVirtualAnimationName() {
    String animation = "pending";
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final tasks = transaction.salesItem
        .map(
          (e) => e as VirtualService,
        )
        .toList();
    // We get the current task being done
    final pendingTask = tasks.firstWhere(
        (task) =>
            !task.documentsUploaded ||
            !task.paymentMade ||
            !task.approvePayment ||
            !task.clientSatisfied ||
            !task.paymentReleased,
        orElse: () => tasks.last);

    int index = tasks.indexOf(pendingTask);

    if (!pendingTask.paymentMade) {
      animation = isBuyer ? "payment-loading" : "pending";
      return animation;
    }

    if (!pendingTask.approvePayment) {
      return "pending";
    }

    if (!pendingTask.documentsUploaded) {
      animation = isBuyer ? "pending" : "kyc-document";
      return animation;
    }

    if (!pendingTask.clientSatisfied) {
      if (isBuyer) {
        return "happy";
      }

      return "pending";
    }

    return animation;
  }

  String getVirtualAnimationLabel() {
    String description = "Waiting For Admin";
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final tasks = transaction.salesItem
        .map(
          (e) => e as VirtualService,
        )
        .toList();
    // We get the current task being done
    final pendingTask = tasks.firstWhere(
        (task) =>
            !task.documentsUploaded ||
            !task.paymentMade ||
            !task.approvePayment ||
            !task.clientSatisfied ||
            !task.paymentReleased,
        orElse: () => tasks.last);

    int index = tasks.indexOf(pendingTask);

    if (!pendingTask.paymentMade) {
      description = isBuyer
          ? "Make payment for virtual-product ${index + 1}"
          : "Waiting for buyer's payment";
      return description;
    }

    if (!pendingTask.approvePayment) {
      return "Admin approving payment for virtual-product ${index + 1}..";
    }

    if (!pendingTask.documentsUploaded) {
      description = isBuyer
          ? "Waiting for seller's document...."
          : "Upload the required document/file for virtual-product ${index + 1}";
      return description;
    }

    if (!pendingTask.clientSatisfied) {
      if (isBuyer) {
        return "Are you satisfied with the developer's work?";
      }

      return "Waiting for client's impression...";
    }

    return description;
  }

  String getReturnTransactionAnimationLabel() {
    final bool isSeller =
        transaction.creator == ClientProvider.readOnlyClient!.userId;

    if (transaction.hasReturnDriver) {
      if (transaction.adminApprovesDriver) {
        return isSeller
            ? "Return products underway"
            : "Your items are being returned";
      }

      return "Admin approving return buyer";
    }

    if (isSeller) {
      return "Waiting for buyer to return product";
    }

    return "Upload return driver's info";
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
