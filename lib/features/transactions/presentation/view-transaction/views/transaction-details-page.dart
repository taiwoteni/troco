import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:clipboard/clipboard.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:troco/core/app/download-manager.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/texts/outputs/info-text.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/domain/repo/payment-repository.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-profile-sheet.dart';
import 'package:troco/features/transactions/domain/entities/driver.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transactions-provider.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/troco-details-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-driver-details-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/accept-returned-items-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/add-driver-details-form.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/comment-return-items-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/proof-of-work-widget-virtual.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/proof-of-work-widget.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/receipt-widget.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/select-return-product-widget.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/transaction-terms-and-conditions-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/upload-item-sheet.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/upload-task-sheet.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/transaction-category-converter.dart';

import '../../../../report/presentation/widgets/report-transaction-sheet.dart';
import '../../../data/models/virtual-document.dart';
import '../../../domain/entities/service.dart';
import '../../../../groups/domain/entities/group.dart';
import '../widgets/select-return-items-sheet.dart';

class TransactionsDetailPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const TransactionsDetailPage({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsDetailPageState();
}

class _TransactionsDetailPageState
    extends ConsumerState<TransactionsDetailPage> {
  late Transaction transaction;
  late Group group;
  late DownloadManager downloadManager;

  String text = "Approve Transaction";
  final screenshot = ScreenshotController();

  final pdfBoundaryKey = GlobalKey();

  final okKey = UniqueKey();
  final neutralKey = UniqueKey();
  final cancelKey = UniqueKey();

  bool serviceReceivedTasks = false;

  bool driverDetailsExpanded = false;
  bool returnItemsIsExpanded = false;

  bool justSentRejectedReturnDriverInfo = false;

  @override
  void initState() {
    transaction = AppStorage.getTransaction(
            transactionId: widget.transaction.transactionId) ??
        widget.transaction;
    debugPrint(transaction.toJson()["driverInformation"]?.toString() ?? "");

    if (AppStorage.getGroups().any(
      (element) => element.groupId == transaction.transactionId,
    )) {
      group = AppStorage.getGroups().firstWhere(
        (element) => element.groupId == transaction.transactionId,
      );
    }

    super.initState();
    // Initialize the download manager once the page's context is fully initialized.
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        downloadManager = DownloadManager(context: context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inorder to listen to the current transaction's changes from the
    // stream provider listener put in place
    listenToTransactionsChanges();
    transaction = ref.watch(currentTransactionProvider);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
      children: [
        mediumSpacer(),
        transactionId(),
        mediumSpacer(),
        regularSpacer(),
        // transaction name
        title(),
        mediumSpacer(),
        // transaction details
        description(),
        extraLargeSpacer(),
        regularSpacer(),
        // number of products
        numberOfItems(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // location
        location(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // inspection period
        inspectionPeriod(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // estimated time
        estimatedTime(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // escrow fee
        escrowFee(),
        regularSpacer(),
        largeSpacer(),

        //Driver details
        if (transaction.transactionCategory == TransactionCategory.Product) ...[
          regularSpacer(),
          driverDetailsTitle(),
          divider(),
          regularSpacer(),
          if (transaction.hasReturnTransaction) ...[
            returnItemTitle(),
            divider(),
            regularSpacer()
          ]
        ],
        // extraLargeSpacer(),

        // total price
        price(),
        regularSpacer(),
        extraLargeSpacer(),
        if (transaction.transactionCategory != TransactionCategory.Product)
          if (transaction.transactionCategory == TransactionCategory.Service)
            proofsOfWorkService()
          else
            proofsOfWorkVirtual(),
        extraLargeSpacer(),
        questionsText(),

        button(),
        extraLargeSpacer()
      ],
    );
  }

  Widget driverDetailsTitle() {
    return ExpansionPanelList(
      expansionCallback: (panelIndex, isExpanded) =>
          setState(() => driverDetailsExpanded = isExpanded),
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      materialGapSize: 0,
      dividerColor: Colors.transparent,
      expandIconColor: ColorManager.primary,
      children: [
        ExpansionPanel(
          backgroundColor: Colors.transparent,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return Text(
              transaction.hasReturnTransaction
                  ? "Return Driver Details"
                  : "Driver Details",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: ColorManager.primary,
                  fontFamily: 'Quicksand',
                  wordSpacing: -0.5,
                  fontWeight: FontWeightManager.bold,
                  fontSize: FontSizeManager.medium * 0.9),
            );
          },
          body: driverDetailsBody(),
          isExpanded: driverDetailsExpanded,
        )
      ],
    );
  }

  Widget driverDetailsBody() {
    return Column(
      children: [
        regularSpacer(),
        // Driver Name
        driverName(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // Driver Number
        driverNumber(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // Company Name
        companyName(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // delivery details
        driverDestination(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // Delivery Date
        estimatedDate(),
        regularSpacer(),
        divider(),
        regularSpacer(),
        // Delivery Fee
        driverPlateNumber(),
        regularSpacer(),
      ],
    );
  }

  Widget returnItemTitle() {
    return ExpansionPanelList(
      expansionCallback: (panelIndex, isExpanded) =>
          setState(() => returnItemsIsExpanded = isExpanded),
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      materialGapSize: 0,
      dividerColor: Colors.transparent,
      expandIconColor: ColorManager.primary,
      children: [
        ExpansionPanel(
          backgroundColor: Colors.transparent,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return Text(
              "Returned Items",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: ColorManager.primary,
                  fontFamily: 'Quicksand',
                  wordSpacing: -0.5,
                  fontWeight: FontWeightManager.bold,
                  fontSize: FontSizeManager.medium * 0.9),
            );
          },
          body: returnItemsBody(),
          isExpanded: returnItemsIsExpanded,
        )
      ],
    );
  }

  Widget returnItemsBody() {
    return Column(
      children: transaction.returnItems
          .map(
            (e) => Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: SizeManager.regular),
              child: SelectReturnItemWidget(
                item: e,
                onChecked: () {},
                selected: false,
                isDisplay: true,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget divider() {
    return Divider(
      color: ColorManager.secondary.withOpacity(0.09),
    );
  }

  Widget transactionId() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, Routes.viewProductsRoute,
                arguments: ModalRoute.of(context)!.settings.arguments!);
          },
          splashColor: ColorManager.accentColor.withOpacity(0.2),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeManager.regular * 1.5),
          ),
          borderRadius: BorderRadius.circular(SizeManager.regular * 1.5),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManager.regular * 1.1,
                vertical: SizeManager.small * 1.1),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeManager.regular * 1.5),
                color: ColorManager.accentColor.withOpacity(0.15)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "View ${TransactionCategoryConverter.convertToString(category: transaction.transactionCategory, plural: true)}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: ColorManager.accentColor,
                        fontFamily: 'Lato',
                        height: 1.4,
                        fontWeight: FontWeightManager.semibold,
                        fontSize: FontSizeManager.regular * 0.72)),
                smallSpacer(),
                Icon(
                  Icons.open_in_new_rounded,
                  size: IconSizeManager.small * 0.9,
                  color: ColorManager.accentColor,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: Text("#${transaction.transactionId}.",
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: ColorManager.secondary,
                  fontFamily: 'Lato',
                  height: 1.4,
                  fontWeight: FontWeightManager.semibold,
                  fontSize: FontSizeManager.regular * 0.72)),
        ),
      ],
    );
  }

  Widget title() {
    return Text(
      transaction.transactionName
          .trim()
          .padRight(transaction.transactionName.length + 1, "."),
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.primary,
          fontFamily: 'Quicksand',
          wordSpacing: -0.5,
          fontWeight: FontWeightManager.extrabold,
          fontSize: FontSizeManager.medium * 1.05),
    );
  }

  Widget description() {
    return Text(
      transaction.transactionDetail
          .trim()
          .padRight(transaction.transactionDetail.trim().length + 1, "."),
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'Quicksand',
          height: 1.4,
          fontWeight: FontWeightManager.medium,
          fontSize: FontSizeManager.regular * 0.9),
    );
  }

  Widget price() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Amount: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "${transaction.transactionAmountString.trim()} NGN",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'lato',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget location() {
    return SizedBox(
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Address: ",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'quicksand',
                height: 1.4,
                fontWeight: FontWeightManager.extrabold,
                fontSize: FontSizeManager.medium * 0.8),
          ),
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: Text(
                transaction.address,
                textAlign: TextAlign.right,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: 'quicksand',
                    height: 1.4,
                    fontWeight: FontWeightManager.extrabold,
                    fontSize: FontSizeManager.medium * 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inspectionPeriod() {
    final isProduct =
        transaction.transactionCategory == TransactionCategory.Product;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isProduct ? "Inspection Period: " : "Transaction Duration: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          transaction.inspectionString,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget estimatedTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Estimated End: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          DateFormat.yMMMEd().format(transaction.transactionTime),
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget numberOfItems() {
    final no = transaction.salesItem.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "No. of ${TransactionCategoryConverter.convertToString(category: transaction.transactionCategory, plural: true).toLowerCase()}: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "$no ${TransactionCategoryConverter.convertToString(category: transaction.transactionCategory, plural: no != 1)}",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget escrowFee() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Escrow Fee: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "${NumberFormat.currency(symbol: '', locale: 'en_NG', decimalDigits: 2).format(transaction.escrowCharges)} NGN",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'lato',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget driverDestination() {
    return SizedBox(
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Destination: ",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'quicksand',
                height: 1.4,
                fontWeight: FontWeightManager.extrabold,
                fontSize: FontSizeManager.medium * 0.8),
          ),
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: Text(
                !transaction.hasDriver
                    ? "---"
                    : transaction.driver.destinationLocation,
                textAlign: TextAlign.right,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: 'quicksand',
                    height: 1.4,
                    fontWeight: FontWeightManager.extrabold,
                    fontSize: FontSizeManager.medium * 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget companyName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Company Name: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          !transaction.hasDriver ? '---' : transaction.driver.companyName,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget driverName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Driver Name: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          !transaction.hasDriver ? '---' : transaction.driver.driverName,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget driverNumber() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Driver Number: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          !transaction.hasDriver ? '---' : transaction.driver.phoneNumber,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget driverPlateNumber() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Plate Number",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const ViewDriverDetailsScreen();
              },
            ));
          },
          child: Text(
            !transaction.hasDriver ? '---' : "View Plate Number >",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: !transaction.hasDriver
                    ? ColorManager.primary
                    : ColorManager.accentColor,
                fontFamily: 'quicksand',
                height: 1.4,
                fontWeight: FontWeightManager.extrabold,
                fontSize: FontSizeManager.medium * 0.8),
          ),
        ),
      ],
    );
  }

  Widget estimatedDate() {
    final estDateTime = !transaction.hasDriver
        ? DateTime.now()
        : transaction.driver.estimatedDeliveryTime;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Estimated Del. Date: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          !transaction.hasDriver
              ? '---'
              : DateFormat("EEE, dd MMM 'at' hh:mm a").format(estDateTime),
          textAlign: TextAlign.left,
          softWrap: true,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  String getQuestionText() {
    final isPending =
        transaction.transactionStatus == TransactionStatus.Pending;
    final isInProgress =
        transaction.transactionStatus == TransactionStatus.Inprogress;
    final isProcessing =
        transaction.transactionStatus == TransactionStatus.Processing;
    final isOngoing =
        transaction.transactionStatus == TransactionStatus.Ongoing;
    final isFinalizing =
        transaction.transactionStatus == TransactionStatus.Finalizing;
    final isCompleted =
        transaction.transactionStatus == TransactionStatus.Completed;
    final isCancelled =
        transaction.transactionStatus == TransactionStatus.Cancelled;

    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;

    String description = isBuyer
        ? "Accept the Terms and Conditions"
        : "Waiting for buyer to accept terms.";

    if (isPending) {
      if (isService) {
        return transaction.realClient
            ? "Accept the Terms and Conditions"
            : "Waiting for ${isBuyer ? 'developer' : 'client'} to accept terms";
      }
      return description;
    }
    if (isCompleted) {
      return "Transaction Completed!";
    }
    if (isCancelled) {
      return "Transaction Cancelled!";
    }
    if (isFinalizing) {
      if (isService || isVirtual) {
        return "Admin is finalizing ${isVirtual ? "virtual" : "service"} transaction...";
      }
      if (isBuyer) {
        return transaction.buyerSatisfied
            ? "Rounding up transaction..."
            : "Are you satisfied with these products?";
      }
      return transaction.buyerSatisfied
          ? "Rounding up transaction..."
          : "Waiting for client's impression..";
    }

    //For Virtual & Service Transactions
    if (isService) {
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
            : "Waiting for buyer's payment";
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
          if (!serviceReceivedTasks) {
            return "Have you received the developer's work?";
          }
          return "Are you satisfied with the developer's work?";
        }

        return "Waiting For Client's Response...";
      }
      return "Admin is finalizing service transaction...";
    }
    if (isVirtual) {
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
          if (!serviceReceivedTasks) {
            return "Have you received the developer's work?";
          }
          return "Are you satisfied with the seller's work?";
        }

        return "Waiting for client's impression...";
      }

      return "Admin is finalizing virtual transaction...";
    }

    if (transaction.hasReturnTransaction) {
      return !isBuyer
          ? !transaction.adminApprovesDriver
              ? !transaction.hasReturnDriver
                  ? "Buyer is expected to re-upload driver info"
                  : "Admin approving return driver.."
              : "Have you received the returned products?"
          : !transaction.hasReturnDriver
              ? "Previous driver rejected. Re-upload"
              : !transaction.adminApprovesDriver
                  ? "Admin approving return driver.."
                  : "Your items are being returned...";
    }

    // For Product Transactions
    if (isInProgress) {
      if (isBuyer) {
        return transaction.paymentDone
            ? "Admin is approving payment.."
            : "Make payment for products";
      }

      return text = transaction.paymentDone
          ? "Admin is approving payment..."
          : "Buyer making payment...";
    }
    if (isProcessing) {
      if (isBuyer) {
        return transaction.hasReturnTransaction
            ? "Your Items are being returned..."
            : "Waiting for driver details..";
      }

      return transaction.hasDriver
          ? "Admin approving.."
          : transaction.hasReturnTransaction
              ? "Have you received the returned products?"
              : "Add delivery driver's details";
    }
    if (isOngoing) {
      if (isBuyer) {
        return "Have you received the delivered products?";
      }
      return "Delivery ongoing...";
    }

    return description;
  }

  Widget questionsText() {
    // When buyer wants to approve
    return Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.small,
            right: SizeManager.small,
            bottom: SizeManager.medium),
        child: InfoText(
            fontSize: FontSizeManager.regular,
            color: ColorManager.secondary,
            alignment: Alignment.center,
            text: getQuestionText()));
  }

  Widget proofsOfWorkService() {
    final tasks = transaction.salesItem
        .map(
          (e) => e as Service,
        )
        .toList();
    final hasProof = tasks.any((element) => element.taskUploaded);
    return Visibility(
      visible: hasProof,
      child: Column(
        children: tasks
            .where(
          (element) => element.taskUploaded,
        )
            .map(
          (task) {
            return GestureDetector(
              key: ValueKey(task),
              onTap: () {
                // debugPrint(task.proofOfTask);
                // FlutterClipboard.copy(task.proofOfTask);
                // return;\
                final isLink = task.proofIsLink;
                if (isLink) {
                  SnackbarManager.showBasicSnackbar(
                      context: context, message: "Copied link");
                  FlutterClipboard.copy(task.proofOfTask);

                  return;
                }

                final extension = task.proofOfTask
                    .substring(task.proofOfTask.lastIndexOf("."));
                final fileName =
                    "${task.name.replaceAll(" ", "_")}${extension}";
                debugPrint(fileName);
                SnackbarManager.showBasicSnackbar(
                    context: context,
                    mode: ContentType.help,
                    message: "Downloading document....");

                downloadFile(url: task.proofOfTask, name: fileName);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: SizeManager.regular),
                child: ProofOfWorkWidget(salesItem: task),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget proofsOfWorkVirtual() {
    final tasks = transaction.salesItem
        .map(
          (e) => e as VirtualService,
        )
        .toList();
    final hasProof = tasks.any((element) => element.documentsUploaded);
    return Visibility(
      visible: hasProof,
      child: Column(
        children: tasks
            .where(
              (element) => element.documentsUploaded,
            )
            .map(
              (task) => task.virtualDocuments,
            )
            .expand((documents) => documents)
            .map(
          (document) {
            return GestureDetector(
              key: ValueKey(document),
              onTap: () {
                if (document.type == VirtualDocumentType.Link) {
                  SnackbarManager.showBasicSnackbar(
                      context: context, message: "Copied link");
                  FlutterClipboard.copy(document.source);
                  return;
                }
                final extension =
                    document.source.substring(document.source.lastIndexOf("."));
                SnackbarManager.showBasicSnackbar(
                    context: context, message: "Downloading document");

                final indexSeparator = documentIndex(document: document);

                downloadFile(
                    url: document.source,
                    name: "${document.taskName}-$indexSeparator${extension}");
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: SizeManager.regular),
                child: ProofOfWorkVirtualWidget(document: document),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Future<void> downloadFile({required String url, required String name}) async {
    final success = await downloadManager.downloadFile(url, name,
        "${transaction.transactionName.toLowerCase().replaceAll(" ", "_")}");

    if (success == null) return;

    if (Platform.isIOS) {
      if (await File(success).exists()) {
        final result = await Share.shareXFiles([XFile(success)],
            subject: "Troco", text: "Choose where to save this document");
        if (result.status != ShareResultStatus.success) {
          SnackbarManager.showErrorSnackbar(
              context: context, message: "Error saving document");
          return;
        }
        SnackbarManager.showBasicSnackbar(
            context: context, message: "Saved document to your iPhone");
      }
    }
  }

  int documentIndex({required final VirtualDocument document}) {
    if (transaction.transactionCategory != TransactionCategory.Virtual) {
      return 0;
    }
    final virtualService = transaction.salesItem
        .map((element) => element as VirtualService)
        .firstWhere((element) => element.id == document.taskId);
    final index = virtualService.virtualDocuments
        .indexWhere((_document) => _document.taskId == document.taskId);

    return index + 1;
  }

  Widget button() {
    final isPending =
        transaction.transactionStatus == TransactionStatus.Pending;
    final isInProgress =
        transaction.transactionStatus == TransactionStatus.Inprogress;
    final isProcessing =
        transaction.transactionStatus == TransactionStatus.Processing;
    final isOngoing =
        transaction.transactionStatus == TransactionStatus.Ongoing;
    final isFinalizing =
        transaction.transactionStatus == TransactionStatus.Finalizing;
    final isCompleted =
        transaction.transactionStatus == TransactionStatus.Completed;
    final isCancelled =
        transaction.transactionStatus == TransactionStatus.Cancelled;
    return Row(
      children: [
        if (isPending) ...pendingButtons(),
        if (isInProgress) ...inProgressButtons(),
        if (isProcessing) ...processingButtons(),
        if (isOngoing) ...ongoingButtons(),
        if (isFinalizing) ...finalizingButtons(),
        if (isCompleted) ...completedButtons(),
        if (isCancelled) ...cancelledButtons(),
      ],
    );
  }

  Widget actionButton(
      {required final bool? positive,
      required final String label,
      required void Function() onPressed}) {
    return Expanded(
      child: CustomButton(
        margin: const EdgeInsets.symmetric(horizontal: SizeManager.small),
        label: label,
        buttonKey: positive == null
            ? neutralKey
            : positive
                ? okKey
                : cancelKey,
        usesProvider: true,
        disabled: positive == null,
        onPressed: onPressed,
        color: positive == null
            ? null
            : positive
                ? ColorManager.themeColor
                : Colors.red.shade700,
      ),
    );
  }

  List<Widget> serviceButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final buttons = <Widget>[];

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
      orElse: () => tasks.last,
    );

    int index = tasks.indexOf(pendingTask);

    if (!pendingTask.paymentMade) {
      setState(() {
        text = isBuyer
            ? "Make payment for Task ${index + 1}"
            : "Waiting for buyer's payment";
      });
      buttons.add(actionButton(
          positive: isBuyer ? true : null,
          label: isBuyer ? "Make Payment" : "Hold On..",
          onPressed: isBuyer ? makePayment : () {}));
      return buttons;
    }

    if (!pendingTask.approvePayment) {
      setState(() {
        text = "Admin approving payment for task ${index + 1}..";
      });
      buttons.add(
          actionButton(positive: null, label: "Hold On..", onPressed: () {}));
      return buttons;
    }

    if (!pendingTask.taskUploaded) {
      setState(() {
        text = isBuyer
            ? "Waiting for developer's work...."
            : "Upload your work for task ${index + 1}";
      });
      if (DateTime.now().isAfter(pendingTask.deadlineTime) && isBuyer) {
        buttons.add(actionButton(
            positive: false, label: "Report Delay", onPressed: reportDelay));
        return buttons;
      }

      buttons.add(actionButton(
          positive: isBuyer ? null : true,
          label: isBuyer ? "Hold On.." : "Upload Work",
          onPressed: isBuyer ? () {} : uploadWork));
      return buttons;
    }

    if (!pendingTask.clientSatisfied) {
      if (isBuyer) {
        if (!serviceReceivedTasks) {
          buttons.add(actionButton(
              positive: true,
              label: "Received Task",
              onPressed: markReceivedProduct));
          return buttons;
        }

        buttons.addAll([
          actionButton(
            positive: true,
            label: "Satisfied",
            onPressed: () =>
                showSatisfactionForTask(task: pendingTask, satisfied: true),
          ),
          actionButton(
            positive: false,
            label: "Unsatisfied",
            onPressed: () =>
                showSatisfactionForTask(task: pendingTask, satisfied: false),
          )
        ]);
        return buttons;
      }

      buttons.add(
          actionButton(positive: null, label: "Hold On..", onPressed: () {}));
      return buttons;
    }

    buttons
        .add(actionButton(positive: null, label: "Done..", onPressed: () {}));

    return buttons;
  }

  List<Widget> virtualButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final buttons = <Widget>[];

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
      orElse: () => tasks.last,
    );

    int index = tasks.indexOf(pendingTask);

    if (!pendingTask.paymentMade) {
      setState(() {
        text = isBuyer
            ? "Make payment for virtual-product ${index + 1}"
            : "Waiting for buyer's payment";
      });
      buttons.add(actionButton(
          positive: isBuyer ? true : null,
          label: isBuyer ? "Make Payment" : "Hold On..",
          onPressed: isBuyer ? makePayment : () {}));
      return buttons;
    }

    if (!pendingTask.approvePayment) {
      setState(() {
        text = "Admin approving payment for virtual-product ${index + 1}..";
      });
      buttons.add(
          actionButton(positive: null, label: "Hold On..", onPressed: () {}));
      return buttons;
    }

    if (!pendingTask.documentsUploaded) {
      setState(() {
        text = isBuyer
            ? "Waiting for seller's work...."
            : "Upload required document/credentials for task ${index + 1}";
      });
      buttons.add(actionButton(
          positive: isBuyer ? null : true,
          label: isBuyer ? "Hold On.." : "Upload Item",
          onPressed: isBuyer ? () {} : uploadVirtualDocuments));
      return buttons;
    }

    if (!pendingTask.clientSatisfied) {
      if (isBuyer) {
        if (!serviceReceivedTasks) {
          buttons.add(actionButton(
              positive: true,
              label: "Received Doc",
              onPressed: markReceivedProduct));
          return buttons;
        }

        buttons.addAll([
          actionButton(
            positive: true,
            label: "Satisfied",
            onPressed: () =>
                showSatisfactionForVirtual(task: pendingTask, satisfied: true),
          ),
          actionButton(
            positive: false,
            label: "Unsatisfied",
            onPressed: () =>
                showSatisfactionForVirtual(task: pendingTask, satisfied: false),
          )
        ]);
        return buttons;
      }

      buttons.add(
          actionButton(positive: null, label: "Hold On..", onPressed: () {}));
      return buttons;
    }
    buttons
        .add(actionButton(positive: null, label: "Done..", onPressed: () {}));

    return buttons;
  }

  List<Widget> returnTransactionButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final buttons = <Widget>[];

    if (!transaction.hasReturnDriver) {
      // waiting for buyer to re-upload driver information
      if (!isBuyer) {
        buttons.add(
            actionButton(positive: null, label: "Hold On..", onPressed: () {}));
        return buttons;
      }

      buttons.add(actionButton(
          positive: true,
          label: "Add Return Driver",
          onPressed: addDriverDetails
          //     () async {
          //   final r = await addDriverDetails();
          //   if (r) {
          //     setState(() {
          //       justSentRejectedReturnDriverInfo = true;
          //     });
          //   }
          // }
          ));
      return buttons;
    }

    if (!transaction.adminApprovesDriver) {
      buttons.add(
          actionButton(positive: null, label: "Hold On..", onPressed: () {}));
      return buttons;
    }

    if (!isBuyer) {
      buttons.add(actionButton(
          positive: true,
          label: "Received Returned Items",
          onPressed: () async {
            ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
            await Future.delayed(const Duration(seconds: 2));

            final received = await AcceptItemsSheet.bottomSheet(
                    transaction: transaction, context: context) ??
                false;

            if (!received) {
              ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
              return;
            }

            final response = await TransactionRepo.acceptReturnedGoods(
                transaction: transaction);

            debugPrint(response.body);

            if (response.error) {
              SnackbarManager.showErrorSnackbar(
                  context: context, message: "Error accepting returned goods");
            } else {
              SnackbarManager.showBasicSnackbar(
                  context: context, message: "Accepted returned goods");
            }
          }));
      return buttons;
    }

    buttons.add(
        actionButton(positive: null, label: "Hold On..", onPressed: () {}));
    return buttons;
  }

  List<Widget> pendingButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;

    final buttons = <Widget>[];

    if (isService) {
      if (transaction.realClient) {
        buttons.add(actionButton(
            positive: true,
            label: "Terms & Conditions",
            onPressed: openTermsAndConditions));
        return buttons;
      }
      buttons.add(actionButton(
          positive: false, label: "Cancel", onPressed: rejectTransaction));
      return buttons;
    }

    if (isBuyer) {
      buttons.addAll([
        actionButton(
            positive: true, label: "Accept", onPressed: acceptTransaction),
        actionButton(
            positive: false,
            label: "Reject",
            //No function to delete yet.
            onPressed: rejectTransaction)
      ]);
      return buttons;
    }
    buttons.add(actionButton(
        positive: false, label: "Cancel", onPressed: rejectTransaction));

    return buttons;
  }

  List<Widget> inProgressButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;
    final buttons = <Widget>[];

    bool paymentDone = transaction.paymentDone;

    if (isService) {
      return serviceButtons();
    }

    if (isVirtual) {
      return virtualButtons();
    }

    // If it is product transaction

    if (isBuyer) {
      buttons.add(actionButton(
          positive: paymentDone ? null : true,
          label: paymentDone ? "Admin approving" : "Make Payment",
          onPressed: paymentDone ? () {} : makePayment));
      return buttons;
    }

    setState(() => text = paymentDone
        ? "Admin is approving payment..."
        : "Buyer making payment...");
    buttons.add(
        actionButton(positive: null, label: "Hold on...", onPressed: () {}));

    return buttons;
  }

  List<Widget> processingButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;
    // final startedLeading = transaction.sellerStarteedLeading;

    final buttons = <Widget>[];

    if (isService) {
      return serviceButtons();
    }

    if (isVirtual) {
      return virtualButtons();
    }

    final hasDriver = transaction.hasDriver;

    if (transaction.hasReturnTransaction) {
      return returnTransactionButtons();
    }

    buttons.add(actionButton(
        positive: hasDriver || isBuyer ? null : true,
        label: hasDriver
            ? "Admin approving.."
            : isBuyer
                ? "Hold on.."
                : "Add driver details",
        onPressed: hasDriver || isBuyer ? () {} : addDriverDetails));
    return buttons;
  }

  List<Widget> ongoingButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;
    final buttons = <Widget>[];

    if (isService) {
      return serviceButtons();
    }

    if (isVirtual) {
      return virtualButtons();
    }

    if (transaction.hasReturnTransaction) {
      return returnTransactionButtons();
    }

    // Only for Product in the meanwhile
    buttons.add(actionButton(
        positive: isBuyer ? true : null,
        label: isBuyer ? "Received Product" : "Sending Product..",
        onPressed: markReceivedProduct));

    return buttons;
  }

  List<Widget> finalizingButtons() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;

    final buttons = <Widget>[];

    if (isService || isVirtual) {
      buttons
          .add(actionButton(positive: null, label: "Done..", onPressed: () {}));
      return buttons;
    }

    if (isBuyer) {
      if (!transaction.buyerSatisfied) {
        buttons.add(actionButton(
            positive: true,
            label: "Satisfied",
            onPressed: () => showSatisfaction(satisfied: true)));
      }
      buttons.add(actionButton(
          positive: isBuyer ? transaction.buyerSatisfied : null,
          label: transaction.buyerSatisfied
              ? (isBuyer
                  ? "View Receipt"
                  : transaction.trocoPaysSeller
                      ? "Payment done.."
                      : "Revenue underway..")
              : isBuyer
                  ? "Unsatisfied"
                  : "Waiting for response...",
          //No function to delete yet.
          onPressed: transaction.buyerSatisfied && isBuyer
              ? viewReceipt
              : isBuyer
                  ? () => showSatisfaction(satisfied: false)
                  : () {}));

      return buttons;
    }

    buttons.add(actionButton(
        positive: null,
        label: transaction.buyerSatisfied
            ? (transaction.trocoPaysSeller
                ? "Payment done.."
                : "Revenue underway..")
            : "Waiting for response...",
        //No function to delete yet.
        onPressed: () {}));

    return buttons;
  }

  List<Widget> cancelledButtons() {
    return [
      actionButton(positive: null, label: "Cancelled..", onPressed: () {})
    ];
  }

  List<Widget> completedButtons() {
    return [
      actionButton(
          positive: true, label: "View Receipt", onPressed: viewReceipt)
    ];
  }

  Future<void> openTermsAndConditions() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    final accept = await showModalBottomSheet<bool?>(
        isScrollControlled: true,
        enableDrag: true,
        useSafeArea: false,
        isDismissible: false,
        backgroundColor: ColorManager.background,
        context: context,
        builder: (context) =>
            TransactionTermsAndConditionsSheet(transaction: transaction));
    // Once Buyer is done opening the terms and conditions

    if (accept == null) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      return;
    }

    if (accept) {
      acceptTransaction();
    } else {
      rejectTransaction();
    }
  }

  Future<void> uploadWork() async {
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));

    if (isVirtual) {
      final tasks = transaction.salesItem
          .map(
            (e) => e as VirtualService,
          )
          .toList();
      // We get the current task being done
      final pendingTask = tasks.firstWhere((task) =>
          !task.documentsUploaded ||
          !task.paymentMade ||
          !task.approvePayment ||
          !task.clientSatisfied ||
          !task.paymentReleased);

      final result = await FileManager.pickMedia();
      if (result == null) {
        SnackbarManager.showBasicSnackbar(
            context: context, message: "Empty file", mode: ContentType.failure);
        ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
        return;
      }

      final response = await TransactionRepo.uploadProofOfWork(
          transaction: transaction,
          taskId: pendingTask.id,
          link: false,
          fileOrLink: result.path);

      debugPrint(response.body);

      if (response.error) {
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Failed to upload document",
            mode: ContentType.failure);
        ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
        return;
      }
      SnackbarManager.showBasicSnackbar(
          context: context, message: "Sent document!");

      return;
    }

    final tasks = transaction.salesItem
        .map(
          (e) => e as Service,
        )
        .toList();
    // We get the current task being done
    final pendingTask = tasks.firstWhere((task) =>
        !task.taskUploaded ||
        !task.paymentMade ||
        !task.approvePayment ||
        !task.clientSatisfied ||
        !task.paymentReleased);

    final result = await showModalBottomSheet<bool?>(
          isScrollControlled: true,
          enableDrag: true,
          useSafeArea: false,
          isDismissible: false,
          backgroundColor: ColorManager.background,
          context: context,
          builder: (context) => UploadTaskSheet(
            transaction: transaction,
            service: pendingTask,
          ),
        ) ??
        false;

    // If it had an error
    if (!result) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
    }
  }

  Future<void> uploadVirtualDocuments() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    final tasks = transaction.salesItem
        .map(
          (e) => e as VirtualService,
        )
        .toList();
    // We get the current virtual service being done
    final virtualService = tasks.firstWhere((task) =>
        !task.documentsUploaded ||
        !task.paymentMade ||
        !task.approvePayment ||
        !task.clientSatisfied ||
        !task.paymentReleased);
    final result = (await UploadVirtualDocumentsSheet.bottomSheet(
            context: context, virtualService: virtualService) ??
        false);

    if (!result) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Error Uploading Virtual Documents");
    }
  }

  Future<void> reportDelay() async {
    ReportTransactionSheet.bottomSheet(
        context: context, transaction: transaction);
  }

  Future<void> startLeading() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final response = await TransactionRepo.createLeadingTransaction(
        transaction: transaction);
    log(response.body);

    if (response.error) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Could not start lead. Try again");
    }
  }

  Future<void> respondToLeading({required final yes}) async {
    ButtonProvider.startLoading(buttonKey: yes ? okKey : cancelKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final response = await TransactionRepo.startLeadingTransaction(
        transaction: transaction, yes: yes);
    log(response.body);

    if (response.error) {
      ButtonProvider.stopLoading(buttonKey: yes ? okKey : cancelKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Could not ${yes ? "accept" : "decline"} lead. Try again");
      return;
    }
    SnackbarManager.showBasicSnackbar(
        context: context,
        mode: ContentType.help,
        message: "You can start inspecting");
  }

  Future<void> inspectService() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final response = await TransactionRepo.finalizeVirtualTransaction(
        transaction: transaction, yes: true);
    log(response.body);

    if (response.error) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Could not start inspection. Try again");
    }
  }

  Future<void> viewReceipt() async {
    await generatePdfFromOffScreenWidget(context: context);
  }

  Future<void> showSatisfaction({required bool satisfied}) async {
    final isReturnTransaction =
        transaction.transactionCategory == TransactionCategory.Product;
    ButtonProvider.startLoading(
        buttonKey: satisfied ? okKey : cancelKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));

    if (!isReturnTransaction || satisfied) {
      final response = await TransactionRepo.satisfiedWithProduct(
          transaction: transaction, yes: satisfied);
      if (response.error) {
        ButtonProvider.stopLoading(
            buttonKey: satisfied ? okKey : cancelKey, ref: ref);
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "An unknown error occurred");
      }
      return;
    }

    //We ask for the items to be returned;
    final items = await askReturnProductsId();
    if (items.isEmpty) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      return;
    }

    // We ask for the reason why the buyer is not satisfied.
    final comment = await askReturnComment();
    if (comment.trim().isEmpty) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      return;
    }

    //We ask for the new driver details to upload.
    final driver = await askDriverInformation();
    if (driver == null) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      return;
    }

    //then we upload the new driver details
    final driverResponse = await TransactionRepo.uploadDriverDetails(
        driver: driver, transaction: transaction);
    if (driverResponse.error) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Error uploading return driver details");
      return;
    }

    //We first of all create a return transaction first.
    final returnTransactionResponse = await TransactionRepo.returnTransaction(
        transaction: transaction, itemIds: items, comment: comment);
    debugPrint(returnTransactionResponse.body);
    if (returnTransactionResponse.error) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Error creating driver details");
      return;
    }

    SnackbarManager.showBasicSnackbar(
        context: context,
        message: "Returning ${transaction.pricingName} underway");
  }

  Future<void> showSatisfactionForTask(
      {required final Service task, required bool satisfied}) async {
    ButtonProvider.startLoading(
        buttonKey: satisfied ? okKey : cancelKey, ref: ref);

    await Future.delayed(const Duration(seconds: 2));
    if (!satisfied) {
      await ReasonSheet.bottomSheet(
          context: context,
          title: "Reason",
          label: "Why aren't you satisfied?");
    }

    final response = await TransactionRepo.satisfiedWithTask(
        transaction: transaction, task: task, yes: satisfied);
    if (response.error) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "An unknown error occurred");
      return;
    }
  }

  Future<void> showSatisfactionForVirtual(
      {required final VirtualService task, required bool satisfied}) async {
    ButtonProvider.startLoading(
        buttonKey: satisfied ? okKey : cancelKey, ref: ref);

    await Future.delayed(const Duration(seconds: 2));

    if (!satisfied) {
      await ReasonSheet.bottomSheet(
          context: context,
          title: "Reason",
          label: "Why aren't you satisfied?");
    }

    final response = await TransactionRepo.satisfiedWithVirtualProduct(
        transaction: transaction, task: task, yes: satisfied);
    if (response.error) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "An unknown error occurred");
      return;
    }
  }

  Future<List<String>> askReturnProductsId() async {
    return (await showModalBottomSheet<List<String>?>(
            isScrollControlled: true,
            enableDrag: true,
            useSafeArea: false,
            isDismissible: false,
            backgroundColor: ColorManager.background,
            context: context,
            builder: (context) => SelectReturnItemsSheet(
                  transaction: transaction,
                ))) ??
        [];
  }

  Future<String> askReturnComment() async {
    return await ReasonSheet.bottomSheet(context: context) ?? "";
  }

  Future<void> markReceivedProduct() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));

    /// A bottom sheet that confirms that they've received
    /// the items. This must occur for all items - product,service and virtual
    final received = await AcceptItemsSheet.bottomSheet(
            transaction: transaction, context: context) ??
        false;
    if (!received) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      return;
    }

    if (transaction.transactionCategory != TransactionCategory.Product) {
      setState(() => serviceReceivedTasks = true);
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      return;
    }

    final result = await TransactionRepo.hasReceivedProduct(
        transaction: transaction, yes: true);
    debugPrint(result.body);
    if (result.error) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Failed to mark product as received");
    }
  }

  Future<void> makePayment() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    if (transaction.hasAccountDetails) {
      await showPayment();
      return;
    }

    final method = await selectPaymentProfile();

    if (method == null) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "No Method was selected");
      return;
    }

    if (method is CardMethod) {
      final response = await PaymentRepository.makeCardPayment(
          transaction: transaction, group: group, card: method);
      log(response.body);
      (await Navigator.pushNamed(context, Routes.cardPaymentScreen,
              arguments: response.messageBody!["paymentLink"]) as bool?) ??
          false;
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);

      return;
    }
    final response = await PaymentRepository.uploadSelectedAccount(
        group: group, account: method as AccountMethod);

    if (response.error) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Error occurred selecting account");
      return;
    }
    await showPayment();
  }

  Future<void> showPayment() async {
    final done = (await showModalBottomSheet<bool?>(
          isScrollControlled: true,
          enableDrag: true,
          useSafeArea: false,
          isDismissible: false,
          backgroundColor: ColorManager.background,
          context: context,
          builder: (context) => const TrocoDetailsSheet(),
        ) ??
        false);

    if (!done) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      return;
    }

    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);

    SnackbarManager.showBasicSnackbar(
        context: context, message: "Made Payment Successfully... Hold On..");
  }

  Future<PaymentMethod?> selectPaymentProfile() async {
    final method = await showModalBottomSheet<PaymentMethod?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => const SelectPaymentProfileSheet(
        onlyAccount: true,
      ),
    );

    return method;
  }

  Future<Driver?> askDriverInformation() async {
    return await showModalBottomSheet<Driver?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => const AddDriverDetailsForm(),
    );
  }

  Future<bool> addDriverDetails() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final driver = await askDriverInformation();

    if (driver == null) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Empty Driver details");
      return false;
    }

    // endpoint to add driver details
    final response = await TransactionRepo.uploadDriverDetails(
        driver: driver, transaction: transaction);
    debugPrint(response.body);

    if (response.error) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Unable to add driver details");
      return false;
    }

    return true;
  }

  Future<void> acceptTransaction() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    final result = await TransactionRepo.respondToTransaction(
        approve: true, transaction: transaction, ref: ref);
    log(result.body);
    if (result.error) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Failed to accept transaction");
    }
  }

  Future<void> rejectTransaction() async {
    ButtonProvider.startLoading(buttonKey: cancelKey, ref: ref);
    final result = await TransactionRepo.respondToTransaction(
        approve: false, transaction: transaction, ref: ref);

    debugPrint(result.body);

    SnackbarManager.showBasicSnackbar(
        context: context,
        mode: result.error ? ContentType.failure : ContentType.success,
        message: result.error
            ? "Error rejecting terms"
            : "Rejected Terms Successfully");
    ButtonProvider.stopLoading(buttonKey: cancelKey, ref: ref);
    context.pop();
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        if (value
            .map((t) => t.transactionId)
            .contains(transaction.transactionId)) {
          final t = value.firstWhere(
              (tr) => tr.transactionId == transaction.transactionId);

          debugPrint(t.toJson()["driverInformation"]?.toString() ?? "");
          // if (justSentRejectedReturnDriverInfo &&
          //     t.hasReturnDriver == transaction.hasReturnDriver) {
          // } else {
          //   if (justSentRejectedReturnDriverInfo) {
          //     setState(() => justSentRejectedReturnDriverInfo = false);
          //   }
          ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
          // }
          ButtonProvider.stopLoading(buttonKey: cancelKey, ref: ref);
          ref.read(currentTransactionProvider.notifier).state = t;
        }
      });
    });
  }

  Future<void> generatePdfFromOffScreenWidget(
      {required final BuildContext context}) async {
    Uint8List capturedImage = (await screenshot
        .captureFromWidget(ReceiptWidget(transaction: transaction)));
    final pdf = pw.Document();

    final image = pw.MemoryImage(capturedImage);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    Navigator.pushNamed(context, Routes.viewReceiptRoute,
        arguments: capturedImage);
  }
}
