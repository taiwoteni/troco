import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/button/presentation/widget/button.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/utils/enums.dart';

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

  @override
  void initState() {
    transaction = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          mediumSpacer(),
          transactionId(),
          mediumSpacer(),
          title(),
          mediumSpacer(),
          description(),
          extraLargeSpacer(),
          regularSpacer(),
          numberOfProducts(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          inspectionPeriod(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          estimatedTime(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          price(),
          regularSpacer(),
          extraLargeSpacer(),
          extraLargeSpacer(),
          button(),
          extraLargeSpacer()
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: ColorManager.secondary.withOpacity(0.09),
    );
  }

  Widget transactionId() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text("#${transaction.transactionId}.",
          textAlign: TextAlign.right,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Lato',
              height: 1.4,
              fontWeight: FontWeightManager.semibold,
              fontSize: FontSizeManager.regular * 0.72)),
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
              color: ColorManager.primary.withOpacity(0.8),
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

  Widget inspectionPeriod() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Inspection Period: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary.withOpacity(0.8),
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
              color: ColorManager.primary.withOpacity(0.8),
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

  Widget numberOfProducts() {
    final no = transaction.products.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "No. of products: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary.withOpacity(0.8),
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "$no Product${no == 1 ? "" : "s"}",
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
    final isBuying =
        transaction.transactionPurpose == TransactionPurpose.Buying;
    return Row(
      children: [
        if (isBuying) ...[
          Expanded(
            child: CustomButton.medium(
              label: "Accept",
              color: ColorManager.accentColor,
            ),
          ),
          regularSpacer(),
        ],
        Expanded(
          child: CustomButton.medium(
            label: !isBuying ? "Cancel" : "Reject",
            color: Colors.red.shade800,
          ),
        ),
      ],
    );
  }
}
