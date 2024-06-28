import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/domain/repo/payment-repository.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-profile-sheet.dart';
import 'package:troco/features/transactions/domain/entities/driver.dart';
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
import 'package:troco/features/transactions/presentation/view-transaction/widgets/add-driver-details-form.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/transaction-category-converter.dart';

import '../../../../groups/domain/entities/group.dart';

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

  final okKey = UniqueKey();
  final neutralKey = UniqueKey();
  final cancelKey = UniqueKey();

  bool driverDetailsExpanded = false;

  @override
  void initState() {
    transaction = widget.transaction;
    group = AppStorage.getGroups().firstWhere(
      (element) => element.groupId == transaction.transactionId,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        regularSpacer(),
        driverDetailsTitle(),

        divider(),
        extraLargeSpacer(),

        // total price
        price(),
        regularSpacer(),
        extraLargeSpacer(),
        extraLargeSpacer(),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "${transaction.transactionAmountString.trim()} NGN",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'lato',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
    );
  }

  Widget location() {
    return Row(
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          transaction.address,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          transaction.inspectionString,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          DateFormat.yMMMEd().format(transaction.transactionTime),
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "$no ${TransactionCategoryConverter.convertToString(category: transaction.transactionCategory, plural: no != 1)}",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "${NumberFormat.currency(symbol: '', locale: 'en_NG', decimalDigits: 2).format(transaction.transactionAmount * 0.05)} NGN",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'lato',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
    );
  }

  Widget driverDestination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Destination: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "---",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          '---',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          '---',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "---",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
    );
  }

  Widget deliveryFee() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Delivery Fee",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          '---',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "---",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
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
        if (isProcessing)
          actionButton(
              positive: isBuyer ? null : (transaction.hasDriver ? null : true),
              label: isBuyer
                  ? "Awaiting driver.."
                  : (transaction.hasDriver
                      ? "Awaiting admin's approval.."
                      : "Add driver details"),
              onPressed: isBuyer
                  ? () {}
                  : (transaction.hasDriver ? () {} : addDriverDetails)),
        if (isOngoing)
          actionButton(
              positive: !isBuyer ? null : true,
              label: isBuyer ? "Received Product" : "Sending Product...",
              onPressed: () {}),
        if (isFinalizing) ...[
          if (isBuyer && !transaction.buyerSatisfied)
            actionButton(positive: true, label: "Satisfied", onPressed: () {}),
          actionButton(
              positive: transaction.buyerSatisfied || !isBuyer ? null : true,
              label: transaction.buyerSatisfied
                  ? (isBuyer
                      ? "Enjoy.."
                      : transaction.trocoPaysSeller
                          ? "Payment done.."
                          : "Revenue underway..")
                  : isBuyer
                      ? "Unsatisfied"
                      : "Waiting for response...",
              //No function to delete yet.
              onPressed: () {}),
        ],
        if (isCompleted || isCancelled)
          actionButton(
              positive: null,
              label: isCompleted ? "Completed!" : "Cancelled..",
              onPressed: () {}),

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

  Future<void> makePayment() async {
    ButtonProvider.startLoading(buttonKey: okKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
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
      ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);

      if (response.error) {
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "Payment was unsuccessful");
      }
      return;
    }
    ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
    SnackbarManager.showBasicSnackbar(
        context: context,
        mode: ContentType.warning,
        message: "Only working on Card Methods");
  }

  Future<PaymentMethod?> selectPaymentProfile() async {
    final method = await showModalBottomSheet<PaymentMethod?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => const SelectPaymentProfileSheet(),
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
    ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);

    if (driver != null) {
      // endpoint to add driver details
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
    ButtonProvider.stopLoading(buttonKey: okKey, ref: ref);
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
