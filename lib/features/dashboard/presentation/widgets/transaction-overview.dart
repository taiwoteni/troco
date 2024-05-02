import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/dashboard/data/datasources/latest-transactions.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../transactions/utils/enums.dart';

class TransactionOverview extends ConsumerStatefulWidget {
  const TransactionOverview({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionOverviewState();
}

class _TransactionOverviewState extends ConsumerState<TransactionOverview> {
  final List<Transaction> transactions = latestTransactions();
  final defaultStyle = TextStyle(
      fontFamily: 'quicksand',
      color: ColorManager.primary,
      fontSize: FontSizeManager.large * 0.85,
      fontWeight: FontWeightManager.bold);

  @override
  Widget build(BuildContext context) {
    double minAmount = transactions
        .map((t) => t.transactionAmount / 1000)
        .reduce((a, b) => a < b ? a : b);
    double maxAmount = transactions
        .map((t) => t.transactionAmount / 1000)
        .reduce((a, b) => a > b ? a : b);

    // Determine the number of weeks and the amount of money spent each week
    int numberOfWeeks = (DateTime.now().day / 7).ceil();
    List<double> weeklySales = List.generate(numberOfWeeks, (index) {
      double startOfWeek = (index * 7) + 1;
      double endOfWeek = (index + 1) * 7;

      return transactions
          .where((t) =>
              t.transactionTime.day >= startOfWeek &&
              t.transactionTime.day <= endOfWeek &&
              t.transactionPurpose == TransactionPurpose.Selling)
          .map((t) => t.transactionAmount / 1000)
          .fold(0, (sum, amount) {
        if (sum + amount > maxAmount) {
          maxAmount = sum + amount;
        }
        if (sum + amount < minAmount) {
          minAmount = sum + amount;
        }
        return sum + amount.toInt();
      });
    });
    List<double> weeklyPurchases = List.generate(numberOfWeeks, (index) {
      double startOfWeek = (index * 7) + 1;
      double endOfWeek = (index + 1) * 7;

      return transactions
          .where((t) =>
              t.transactionTime.day >= startOfWeek &&
              t.transactionTime.day <= endOfWeek &&
              t.transactionPurpose == TransactionPurpose.Buying)
          .map((t) => t.transactionAmount / 1000)
          .fold(0, (sum, amount) {
        if (sum + amount > maxAmount) {
          maxAmount = sum + amount;
        }
        if (sum + amount < minAmount) {
          minAmount = sum + amount;
        }
        return sum + amount.toInt();
      });
    });

    final style = defaultStyle.copyWith(
        color: ColorManager.secondary,
        fontWeight: FontWeightManager.medium,
        fontSize: FontSizeManager.small * 0.9);

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Text(
              "Transaction Overview",
              style: defaultStyle,
              textAlign: TextAlign.start,
            ),
          ),
          extraLargeSpacer(),
          Container(
            width: double.maxFinite,
            height: 130,
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: BarChart(BarChartData(
              barTouchData: BarTouchData(
                  allowTouchBarBackDraw: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: SizeManager.regular,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                          "${rod.toY.toInt()}K",
                          style.copyWith(
                              fontWeight: FontWeightManager.bold,
                              fontSize: style.fontSize! * 1.1,
                              color: rodIndex == 1
                                  ? Colors.red
                                  : ColorManager.accentColor));
                    },
                    getTooltipColor: (group) {
                      return ColorManager.primary;
                    },
                  )),
              minY: 0,
              maxY: maxAmount + 100,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 0,
                  sideTitles: SideTitles(
                    interval: maxAmount / 2,
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final String text = value == maxAmount
                          ? "${maxAmount.toInt()}K"
                          : value == maxAmount / 2
                              ? "${maxAmount ~/ 2}K"
                              : "";
                      return Text(
                        text,
                        style: style,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                    axisNameSize: 0,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final String text = "${value.toInt() + 1}";
                        return Padding(
                          padding:
                              const EdgeInsets.only(top: SizeManager.small),
                          child: Text(
                            "$text${text == "1" ? "st" : text == "2" ? "nd" : text == "3" ? "rd" : "th"}",
                            style: style,
                          ),
                        );
                      },
                    )),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                  border: Border(
                      bottom: BorderSide(
                          color: ColorManager.secondary.withOpacity(0.09)),
                      left: BorderSide(
                          color: ColorManager.secondary.withOpacity(0.09)))),
              gridData: FlGridData(
                  horizontalInterval: maxAmount / 4,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: ColorManager.tertiary, strokeWidth: 2);
                  },
                  drawVerticalLine: false),
              barGroups: List.generate(
                numberOfWeeks,
                (index) {
                  return BarChartGroupData(x: index, barsSpace: 1.5, barRods: [
                    BarChartRodData(
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(SizeManager.regular),
                      ),
                      toY: weeklySales[index],
                      color: ColorManager.accentColor,
                    ),
                    BarChartRodData(
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(SizeManager.regular),
                      ),
                      toY: weeklyPurchases[index],
                      color: Colors.redAccent,
                    )
                  ]);
                },
              ),
            )),
          ),
          mediumSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: SizeManager.small * 1.4,
                    height: SizeManager.small * 1.4,
                    decoration: BoxDecoration(
                        color: ColorManager.accentColor,
                        shape: BoxShape.circle),
                  ),
                  regularSpacer(),
                  Text(
                    "Sales",
                    style: defaultStyle.copyWith(
                        fontSize: FontSizeManager.small * 0.9,
                        fontWeight: FontWeightManager.regular,
                        color: ColorManager.secondary.withOpacity(0.5)),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: SizeManager.small * 1.4,
                    height: SizeManager.small * 1.4,
                    decoration: const BoxDecoration(
                        color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                  regularSpacer(),
                  Text(
                    "Purchases",
                    style: defaultStyle.copyWith(
                        fontSize: FontSizeManager.small * 0.9,
                        fontWeight: FontWeightManager.regular,
                        color: ColorManager.secondary.withOpacity(0.5)),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
