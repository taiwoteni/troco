import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/transactions-pie-chart.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<StatisticsPage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        mediumSpacer(),
        pieChartAnalysis(),
      ],
    );
  }

  Widget pieChartAnalysis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          pieChartAnalysisLabel(),
          const TransactionPieChart(),
        ],
      ),
    );
  }

  Widget pieChartAnalysisLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          total(),
          largeSpacer(),
          spent(),
          mediumSpacer(),
          cancelled(),
        ],
      ),
    );
  }

  Widget total() {
    final transactions = AppStorage.getTransactions();
    final totalAmount = transactions.fold(
      0,
      (previousValue, transaction) =>
          previousValue + transaction.transactionAmount.toInt(),
    );
    final totalAmountString = NumberFormat.compact().format(totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "N$totalAmountString",
          style: TextStyle(
              fontFamily: 'Lato',
              color: ColorManager.primary,
              fontSize: FontSizeManager.extralarge * 0.9,
              fontWeight: FontWeightManager.extrabold),
        ),
        smallSpacer(),
        smallText(text: "Total Transactions")
      ],
    );
  }

  Widget spent() {
    final transactions = AppStorage.getTransactions();

    final completedAmount = transactions
        .where(
          (element) => element.transactionStatus == TransactionStatus.Completed,
        )
        .fold(
          0,
          (previousValue, transaction) =>
              previousValue + transaction.transactionAmount.toInt(),
        );
    final completedAmountString =
        NumberFormat.compact().format(completedAmount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: IconSizeManager.small * 0.5,
          height: IconSizeManager.small * 0.5,
          margin: const EdgeInsets.only(top: SizeManager.small),
          decoration: BoxDecoration(
              color: ColorManager.accentColor, shape: BoxShape.circle),
        ),
        regularSpacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            smallText(text: "Completed"),
            mediumText(text: completedAmountString)
          ],
        )
      ],
    );
  }

  Widget cancelled() {
    final transactions = AppStorage.getTransactions();

    final cancelledAmount = transactions
        .where(
          (element) => element.transactionStatus == TransactionStatus.Cancelled,
        )
        .fold(
          0,
          (previousValue, transaction) =>
              previousValue + transaction.transactionAmount.toInt(),
        );
    final cancelledAmountString =
        NumberFormat.compact().format(cancelledAmount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: IconSizeManager.small * 0.5,
          height: IconSizeManager.small * 0.5,
          margin: const EdgeInsets.only(top: SizeManager.small),
          decoration:
              const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        ),
        regularSpacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            smallText(text: "Cancelled"),
            mediumText(text: cancelledAmountString)
          ],
        )
      ],
    );
  }

  Widget mediumText({required final String text}) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Lato',
          color: ColorManager.primary,
          fontSize: FontSizeManager.extralarge * 0.5,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget smallText({required final String text}) {
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'Lato',
          color: ColorManager.secondary,
          fontSize: FontSizeManager.regular * 0.75,
          fontWeight: FontWeightManager.regular),
    );
  }

}