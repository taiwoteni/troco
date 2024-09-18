import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../domain/entities/transaction.dart';

class TransactionTermsAndConditionsSheet extends ConsumerStatefulWidget {
  final Transaction transaction;
  const TransactionTermsAndConditionsSheet(
      {super.key, required this.transaction});

  @override
  ConsumerState<TransactionTermsAndConditionsSheet> createState() =>
      _TransactionTermsAndConditionsSheetState();
}

class _TransactionTermsAndConditionsSheetState
    extends ConsumerState<TransactionTermsAndConditionsSheet> {
  late bool isServiceTransaction;
  late Transaction transaction;
  bool loading = false;
  final buttonKey = UniqueKey();
  var acceptTerms = true;

  @override
  void initState() {
    transaction = widget.transaction;
    isServiceTransaction =
        transaction.transactionCategory == TransactionCategory.Service;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: SingleChildScrollView(
          child: Column(children: [
        extraLargeSpacer(),
        const DragHandle(),
        largeSpacer(),
        title(),
        mediumSpacer(),
        Divider(
          thickness: 1,
          color: ColorManager.secondary.withOpacity(0.08),
        ),
        mediumSpacer(),
        // statementFromSeller(),
        // mediumSpacer(),
        summarizedStatement(),
        smallSpacer(),
        acceptTermsAndConditions(),
        largeSpacer(),
        button(),
        largeSpacer(),
      ])),
    );
  }

  Widget title() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            "Terms and Conditions",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "Lato",
                fontSize: FontSizeManager.large * 0.9),
          ),
        ),
        Positioned(
          width: SizeManager.extralarge * 1.1,
          height: SizeManager.extralarge * 1.1,
          right: SizeManager.regular,
          child: IconButton(
              onPressed: () => loading ? null : Navigator.pop(context),
              style: ButtonStyle(
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorManager.accentColor.withOpacity(0.2))),
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.accentColor,
                size: IconSizeManager.small,
              )),
        )
      ],
    );
  }

  Widget statementFromSeller() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Statement from ${isServiceTransaction ? "Developer" : "Seller"}:",
            textAlign: TextAlign.start,
            style: headingStyle(),
          ),
          regularSpacer(),
          Text(
            transaction.transactionDetail,
            textAlign: TextAlign.start,
            style: textStyle(),
          )
        ],
      ),
    );
  }

  Widget summarizedStatement() {
    debugPrint(transaction.salesItem
        .map(
          (e) => e.toJson(),
        )
        .toString());
    final formatter =
        NumberFormat.currency(locale: 'en_NG', symbol: '', decimalDigits: 2);
    final dateFormatter = DateFormat("EEE, MMM d");
    final boldStyle =
        textStyle().copyWith(fontWeight: FontWeightManager.extrabold);
    var summarization = <TextSpan>[
      const TextSpan(text: "This transaction, named ")
    ];

    summarization
        .add(TextSpan(text: transaction.transactionName, style: boldStyle));
    summarization.add(const TextSpan(
        text: " is a transaction in which it's cost sums up to a total of "));
    summarization.add(TextSpan(
        text: "${transaction.transactionAmountString} Naira",
        style: boldStyle));
    summarization.add(TextSpan(
        text:
            " (with already included escrow charges of ${transaction.salesItem.first.escrowPercentage.toInt()}%) that would be paid by the buyer of this transaction who goes by the name "));
    summarization.add(TextSpan(text: transaction.buyerName, style: boldStyle));
    summarization
        .add(const TextSpan(text: ".\n\nThis transaction comprises of "));
    summarization.add(TextSpan(
        text: transaction.salesItem.length.toString(), style: boldStyle));
    summarization.add(const TextSpan(text: " tasks:\n"));

    for (final item in transaction.salesItem) {
      summarization.add(TextSpan(
          text: "${transaction.salesItem.indexOf(item) + 1}. ${item.name} ",
          style: boldStyle));
      summarization.add(const TextSpan(text: " which costs "));
      summarization.add(TextSpan(
          text: "${formatter.format(item.finalPrice)} naira",
          style: boldStyle));
      if (item is Service) {
        final task = item;
        summarization.add(const TextSpan(
            text:
                " and should have been submitted by the developer on or before "));
        summarization.add(TextSpan(
            text: dateFormatter.format(task.deadlineTime), style: boldStyle));
      }
      if (transaction.salesItem.last != item) {
        summarization.add(TextSpan(text: ".\n", style: boldStyle));
      }
    }

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Generated Statement:",
            textAlign: TextAlign.start,
            style: headingStyle(),
          ),
          regularSpacer(),
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(style: textStyle(), children: summarization),
          )
        ],
      ),
    );
  }

  Widget acceptTermsAndConditions() {
    return Row(
      children: [
        regularSpacer(),
        SizedBox.square(
          dimension: IconSizeManager.regular * 1.85,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Checkbox(
              value: acceptTerms,
              onChanged: (value) => setState(() => acceptTerms = value ?? true),
              fillColor: WidgetStatePropertyAll(acceptTerms
                  ? ColorManager.accentColor
                  : ColorManager.background),
              checkColor: Colors.white,
              side: BorderSide(
                  style: BorderStyle.solid,
                  color: acceptTerms
                      ? ColorManager.accentColor
                      : ColorManager.secondary),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        Text(
          "I accept the terms and conditions above.",
          style: textStyle().copyWith(color: ColorManager.primary),
        )
      ],
    );
  }

  Widget button() {
    return CustomButton(
      buttonKey: buttonKey,
      color: !acceptTerms ? Colors.red.shade700 : null,
      usesProvider: true,
      label: acceptTerms ? "Done" : "Reject",
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        context.pop(result: acceptTerms);
      },
    );
  }

  // Text Styles

  TextStyle headingStyle() {
    return TextStyle(
        fontFamily: 'lato',
        color: ColorManager.primary,
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.semibold);
  }

  TextStyle textStyle() {
    return TextStyle(
        fontFamily: 'lato',
        color: ColorManager.secondary,
        wordSpacing: 2.5,
        fontSize: FontSizeManager.small * 1.15,
        fontWeight: FontWeightManager.regular);
  }
}
