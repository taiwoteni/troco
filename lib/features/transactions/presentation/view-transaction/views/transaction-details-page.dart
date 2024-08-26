import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:troco/core/api/data/model/response-model.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/texts/outputs/info-text.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/domain/repo/payment-repository.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-profile-sheet.dart';
import 'package:troco/features/transactions/domain/entities/driver.dart';
import 'package:troco/features/transactions/presentation/create-transaction/widgets/transaction-pricing-list-item.dart';
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
import 'package:troco/features/transactions/presentation/view-transaction/widgets/add-driver-details-form.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/receipt-sheet.dart.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/receipt-widget.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/select-return-product-widget.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/transaction-category-converter.dart';

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
  final screenshot = ScreenshotController();

  final pdfBoundaryKey = GlobalKey();

  final okKey = UniqueKey();
  final neutralKey = UniqueKey();
  final cancelKey = UniqueKey();

  bool driverDetailsExpanded = false;
  bool returnItemsIsExpanded = false;

  @override
  void initState() {
    transaction = widget.transaction;
    debugPrint(transaction.transactionId.toString());

    if (AppStorage.getGroups().any(
      (element) => element.groupId == transaction.transactionId,
    )) {
      group = AppStorage.getGroups().firstWhere(
        (element) => element.groupId == transaction.transactionId,
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Inorder to listen to the current transaction's changes from the
    // stream provider listener put in place
    transaction = ref.watch(currentTransactionProvider);
    listenToTransactionsChanges();
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
        if (transaction.transactionCategory != TransactionCategory.Virtual) ...[
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
        extraLargeSpacer(),

        // total price
        price(),
        regularSpacer(),
        extraLargeSpacer(),
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
              "Driver Details",
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
        deliveryFee(),
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
              child: SelectReturnProductWidget(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Inspection Period: ",
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

  Widget deliveryFee() {
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
        Hero(
          tag: transaction.transactionId,
          child: GestureDetector(
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
        ),
      ],
    );
  }

  Widget estimatedDate() {
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
              : DateFormat.yMMMEd()
                  .format(transaction.driver.estimatedDeliveryTime),
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

  Widget questionsText() {
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;

    final toAccept =
        transaction.transactionStatus == TransactionStatus.Pending && isBuyer;
    final toCancel =
        transaction.transactionStatus == TransactionStatus.Pending && !isBuyer;
    final toPay =
        transaction.transactionStatus == TransactionStatus.Inprogress &&
            !transaction.paymentDone;
    final toApprovePayment =
        transaction.transactionStatus == TransactionStatus.Inprogress &&
            transaction.paymentDone &&
            isBuyer;
    final didReturnTransactions = transaction.hasReturnTransaction &&
        transaction.transactionStatus == TransactionStatus.Processing &&
        !isBuyer;
    final toReceiveGoods =
        transaction.transactionStatus == TransactionStatus.Ongoing &&
            transaction.adminApprovesDriver &&
            isBuyer;
    final toExpressSatisfaction =
        transaction.transactionStatus == TransactionStatus.Finalizing &&
            isBuyer &&
            !transaction.buyerSatisfied;
    final toAcceptLeading =
        transaction.transactionCategory == TransactionCategory.Virtual &&
            transaction.transactionStatus == TransactionStatus.Processing &&
            transaction.sellerStarteedLeading &&
            isBuyer;

    final visible = toAccept ||
        toCancel ||
        toPay ||
        didReturnTransactions ||
        toReceiveGoods ||
        toExpressSatisfaction ||
        toAcceptLeading;

    String text = "";

    if (toAccept) {
      text = "Do you approve of this transaction?";
    } else if (toCancel) {
      text = "Do you wish to cancel your transaction?";
    } else if (toPay) {
      text =
          "Please pay for the ${transaction.pricingName}(s) you agreed to purchase";
    } else if (didReturnTransactions) {
      text = "Buyer returned items. Re-upload driver details";
    } else if (toReceiveGoods) {
      text = isVirtual
          ? "Start Inspecting"
          : "Has your ${transaction.pricingName}(s) delivered?";
    } else if (toExpressSatisfaction) {
      text =
          "Are you satisfied with the ${transaction.pricingName}(s) delivered to you?";
    } else if (toAcceptLeading) {
      text = "Do you accept this leading?";
    }

    // When buyer wants to approve
    return Visibility(
      visible: visible,
      child: Padding(
          padding: const EdgeInsets.only(
              left: SizeManager.small,
              right: SizeManager.small,
              bottom: SizeManager.medium),
          child: InfoText(
              fontSize: FontSizeManager.small,
              color: ColorManager.secondary,
              alignment: Alignment.center,
              text: text)),
    );
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

    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    return Row(
      children: [
        if (isPending) ...[
          if (isBuyer)
            actionButton(
                positive: true, label: "Accept", onPressed: acceptTransaction),
          actionButton(
              positive: false,
              label: isBuyer ? "Reject" : "Cancel",
              //No function to delete yet.
              onPressed: rejectTransaction),
        ],
        if (isInProgress)
          actionButton(
              positive:
                  isBuyer ? (transaction.paymentDone ? null : true) : null,
              label: isBuyer
                  ? (transaction.paymentDone
                      ? "Awaiting admin's approval.."
                      : "Make Payment")
                  : "Awaiting buyer's payment",
              onPressed: transaction.paymentDone ? () {} : makePayment),
        if (isProcessing) ...[
          actionButton(
              positive: isVirtual
                  ? (isBuyer
                      ? (transaction.sellerStarteedLeading ? true : null)
                      : (transaction.sellerStarteedLeading ? null : true))
                  : (isBuyer ? null : (transaction.hasDriver ? null : true)),
              label: isVirtual
                  ? (isBuyer
                      ? (transaction.sellerStarteedLeading
                          ? "Accept"
                          : "Awaiting seller..")
                      : (transaction.sellerStarteedLeading
                          ? "Awaiting buyer.."
                          : "Start Leading"))
                  : (isBuyer
                      ? transaction.hasReturnTransaction
                          ? "Returning items..."
                          : "Awaiting driver.."
                      : (transaction.hasDriver
                          ? "Awaiting admin's approval.."
                          : "Add driver details")),
              onPressed: isVirtual
                  ? (isBuyer
                      ? (transaction.sellerStarteedLeading
                          ? () => respondToLeading(yes: true)
                          : () {})
                      : (transaction.sellerStarteedLeading
                          ? () {}
                          : startLeading))
                  : (isBuyer
                      ? () {}
                      : (transaction.hasDriver ? () {} : addDriverDetails))),
          if (isVirtual && isBuyer && transaction.sellerStarteedLeading)
            actionButton(
              positive: false,
              label: "Decline",
              onPressed: () => respondToLeading(yes: false),
            )
        ],
        if (isOngoing)
          actionButton(
              positive: !isBuyer ? null : true,
              label: isBuyer
                  ? (!isVirtual ? "Received Product" : "Inspect Service")
                  : isVirtual
                      ? "Awaiting Inspection..."
                      : "Sending Product...",
              onPressed: isBuyer
                  ? (isVirtual ? inspectService : markReceivedProduct)
                  : () {}),
        if (isFinalizing) ...[
          if (isBuyer && !transaction.buyerSatisfied)
            actionButton(
                positive: true,
                label: "Satisfied",
                onPressed: () => showSatisfaction(satisfied: true)),
          actionButton(
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
                      : () {}),
        ],
        if (isCompleted || isCancelled)
          actionButton(
              positive: isCompleted,
              label: isCompleted ? "View Receipt" : "Cancelled..",
              onPressed: viewReceipt),

        // Expanded(
        //     child: CustomButton.medium(
        //       label: "Accept",
        //       usesProvider: true,
        //       buttonKey: okKey,
        //       color: ColorManager.accentColor,
        //     ),
        //   ),

        // Expanded(
        //   child: CustomButton.medium(
        //     buttonKey: cancelKey,
        //     usesProvider: true,
        //     label: !isBuyer ? "Cancel" : "Reject",
        //     color: Colors.red.shade800,
        //   ),
        // ),
      ],
    );
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
    ButtonProvider.startLoading(
        buttonKey: satisfied ? okKey : cancelKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));

    late HttpResponseModel response;
    if (transaction.transactionCategory == TransactionCategory.Virtual) {
      response = await TransactionRepo.satisfiedWithProduct(
          transaction: transaction, yes: satisfied);
    } else {
      if (!satisfied) {
        final items = (await showModalBottomSheet<List<String>?>(
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

        if (items.isEmpty) {
          ButtonProvider.stopLoading(
              buttonKey: satisfied ? okKey : cancelKey, ref: ref);
          return;
        }

        final response = await TransactionRepo.returnTransaction(
            transaction: transaction, itemIds: items);

        log(response.code.toString());
        log(response.body);

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
      response = await TransactionRepo.satisfiedWithProduct(
          transaction: transaction, yes: satisfied);
    }

    log(response.body);

    if (response.error) {
      ButtonProvider.stopLoading(
          buttonKey: satisfied ? okKey : cancelKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "An unknown error occurred");
    }
  }

  Future<void> markReceivedProduct() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
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

    return;
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
    }
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

  Future<void> addDriverDetails() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final driver = await showModalBottomSheet<Driver?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => const AddDriverDetailsForm(),
    );

    if (driver == null) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Empty Driver details");
      return;
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
      return;
    }
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

  Future<void> acceptTransaction() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    final result = await TransactionRepo.respondToTransaction(
        approve: true, transaction: transaction);
    log(result.body);
    if (result.error) {
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Failed to approve transaction");
    }
  }

  Future<void> rejectTransaction() async {
    ButtonProvider.startLoading(buttonKey: cancelKey, ref: ref);
    final result = await TransactionRepo.respondToTransaction(
        approve: false, transaction: transaction);
    log(result.body);
    ButtonProvider.stopLoading(buttonKey: cancelKey, ref: ref);
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        if (value
            .map((t) => t.transactionId)
            .contains(transaction.transactionId)) {
          ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
          ButtonProvider.stopLoading(buttonKey: cancelKey, ref: ref);

          final t = value.firstWhere(
              (tr) => tr.transactionId == transaction.transactionId);
          ref.watch(currentTransactionProvider.notifier).state = t;
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

    // Save or share the PDF
    final output = (await (Platform.isAndroid
        ? getExternalStorageDirectory()
        : getApplicationDocumentsDirectory()))!;
    final name = transaction.transactionName.replaceAll(" ", "_").toLowerCase();
    final file = File("${output.path}/$name.jpg");
    await file.writeAsBytes(capturedImage);

    if (Platform.isAndroid) {
      final permsion =
          (await Permission.manageExternalStorage.request()).isGranted;
      if (permsion) {
        final copy = await file.copy("/storage/emulated/0/Download/$name.jpg");
        debugPrint(copy.path);
      }
    }

    Navigator.pushNamed(context, Routes.cardPaymentScreen,
        arguments: 'file://${file.absolute.path}');
  }
}
