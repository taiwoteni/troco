import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/extensions/pie-chart-extension.dart';
import 'package:troco/features/transactions/utils/enums.dart';

class TransactionPieChart extends ConsumerStatefulWidget {
  const TransactionPieChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPieChartState();
}

class _TransactionPieChartState extends ConsumerState<TransactionPieChart>
    with TickerProviderStateMixin {
  late int totalTransaction,
      completedTransactions,
      cancelledTransactions,
      ongoingTransactions;
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      lowerBound: 1,
      upperBound: 3,
    );
    initializeTransaction();
    controller.animateTo(3,
        duration: const Duration(milliseconds: 2000), curve: Curves.ease);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pieChartWidget();
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

  List<PieChartSectionData> sections() {
    final style = TextStyle(
        color: ColorManager.primaryDark,
        fontFamily: 'lato',
        fontSize: FontSizeManager.small,
        fontWeight: FontWeightManager.semibold);
    return [
      PieChartSectionData(
          value: 5.toDouble() * controller.value,
          color: ColorManager.accentColor,
          radius: SizeManager.extralarge * 1.4,
          title:
              "${((completedTransactions * 100) / totalTransaction).round()}%",
          showTitle: true,
          titleStyle: style),
      PieChartSectionData(
          value: ongoingTransactions.toDouble() * controller.value,
          color: Colors.purple,
          radius: SizeManager.extralarge * 1.4,
          title: "${((ongoingTransactions * 100) / totalTransaction).round()}%",
          showTitle: true,
          titleStyle: style),
      PieChartSectionData(
          value: cancelledTransactions.toDouble() * controller.value,
          color: Colors.red,
          radius: SizeManager.extralarge * 1.4,
          title:
              "${((cancelledTransactions * 100) / totalTransaction).round()}%",
          showTitle: true,
          titleStyle: style)
    ];
  }

  PieChartData pieChartData() {
    return PieChartData(
      centerSpaceColor: ColorManager.background,
      centerSpaceRadius: IconSizeManager.medium * 1,
    );
  }

  Widget pieChartWidget() {
    const size = IconSizeManager.extralarge * 2.2;
    return Container(
      width: size,
      height: size,
      color: ColorManager.background,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return (child! as PieChart).animateSections(
              section:
                  sections().getRange(0, controller.value.round()).toList());
        },
        child: pieChart(),
      ),
    );
  }

  PieChart pieChart() {
    return PieChart(
      pieChartData(),
    );
  }
}
