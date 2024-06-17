import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/transactions/utils/enums.dart';

class TransactionPieChart extends ConsumerStatefulWidget {
  const TransactionPieChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPieChartState();
}

class _TransactionPieChartState extends ConsumerState<TransactionPieChart> {
  late int totalTransaction,
      completedTransactions,
      cancelledTransactions,
      ongoingTransactions;

  @override
  void initState() {
    initializeTransaction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pieChart();
  }

  void initializeTransaction() {
    final transactions = AppStorage.getTransactions();

    totalTransaction = transactions.length;
    completedTransactions = transactions
        .where(
          (transaction) =>
              transaction.transactionStatus == TransactionStatus.Completed,
        )
        .length;
    cancelledTransactions = transactions
        .where(
          (transaction) =>
              transaction.transactionStatus == TransactionStatus.Cancelled,
        )
        .length;
    ongoingTransactions =
        totalTransaction - (completedTransactions + cancelledTransactions);
  }

  PieChartData pieChartData() {
    final style = TextStyle(
        color: ColorManager.primaryDark,
        fontFamily: 'lato',
        fontSize: FontSizeManager.small,
        fontWeight: FontWeightManager.semibold);
    return PieChartData(
      sections: [
        PieChartSectionData(
            value: 5.toDouble(),
            color: ColorManager.accentColor,
            radius: SizeManager.extralarge * 1.4,
            title:
                "${((completedTransactions * 100) / totalTransaction).round()}%",
            showTitle: true,
            titleStyle: style),
        PieChartSectionData(
            value: ongoingTransactions.toDouble(),
            color: Colors.purple,
            radius: SizeManager.extralarge * 1.4,
            title:
                "${((ongoingTransactions * 100) / totalTransaction).round()}%",
            showTitle: true,
            titleStyle: style),
        PieChartSectionData(
            value: cancelledTransactions.toDouble(),
            color: Colors.red,
            radius: SizeManager.extralarge * 1.4,
            title:
                "${((cancelledTransactions * 100) / totalTransaction).round()}%",
            showTitle: true,
            titleStyle: style)
      ],
      centerSpaceColor: ColorManager.background,
      centerSpaceRadius: IconSizeManager.medium * 1,
    );
  }

  Widget pieChart() {
    const size = IconSizeManager.extralarge * 2.2;
    return Container(
      width: size,
      height: size,
      color: ColorManager.background,
      child: PieChart(
        pieChartData(),
        swapAnimationCurve: Curves.ease,
        swapAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }

}
