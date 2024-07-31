import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/text-extensions.dart';
import 'package:troco/features/transactions/presentation/my-transactions/providers/statistics-mode-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../domain/entities/transaction.dart';

class MyTransactionsPerMonth extends ConsumerStatefulWidget {
  const MyTransactionsPerMonth({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyTransactionsPerMonthState();
}

class _MyTransactionsPerMonthState
    extends ConsumerState<MyTransactionsPerMonth> {
  final List<Transaction> transactions = AppStorage.getAllTransactions();
  int selectMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    double minAmount = transactions
        .map((t) => t.transactionAmount)
        .reduce((a, b) => a < b ? a : b);
    double maxAmount = transactions
        .map((t) => t.transactionAmount)
        .reduce((a, b) => a > b ? a : b);

    int numberOfWeeks = 4;
    List<double> data = List.generate(numberOfWeeks, (index) {
      double startOfWeek = (index * 7) + 1;
      double endOfWeek = (index + 1) * 7;

      return transactions
          .where((t) =>
              t.creationTime.day >= startOfWeek &&
              t.creationTime.day <= endOfWeek &&
              t.creationTime.month == selectMonth &&
              t.transactionPurpose == ref.watch(statisticsMode))
          .map((t) => t.transactionAmount)
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

    /// We prevent weeks that have zero transactions so
    /// we remove them
    //TODO: Make sure the weeks aren't being skipped while removing empty transactions

    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.regular),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                now.month == selectMonth
                    ? "This Month"
                    : DateFormat("MMMM")
                        .format(DateTime(now.year, selectMonth)),
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.large,
                    fontWeight: FontWeightManager.bold),
              ),
              dropdown()
            ],
          ),
        ),
        largeSpacer(),
        mediumSpacer(),
        SizedBox(
          width: double.maxFinite,
          height: 170,
          child: LineChart(
            curve: Curves.ease,
            duration: const Duration(milliseconds: 500),
            LineChartData(
                maxY: maxAmount * 1.5,
                minY: 0,
                minX: 0,
                maxX: 4,
                borderData: FlBorderData(
                  border: Border(
                    left: BorderSide(
                      color: ColorManager.secondary.withOpacity(0.2),
                    ),
                    bottom: BorderSide(
                      color: ColorManager.secondary.withOpacity(0.2),
                    ),
                  ),
                ),
                titlesData: getTitlesData(data: data, maxAmount: maxAmount),
                gridData: const FlGridData(
                  show: false,
                  drawHorizontalLine: false,
                  drawVerticalLine: false,
                ),
                lineBarsData: [getBarsData(data: data)]),
          ),
        ),
      ],
    );
  }

  Widget dropdown() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: SizeManager.small, horizontal: SizeManager.regular),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.medium),
          color: ColorManager.tertiary),
      child: DropdownButton<int>(
        value: selectMonth,
        isDense: true,
        elevation: 0,
        padding: EdgeInsets.zero,
        dropdownColor: Colors.white,
        underline: const SizedBox.square(dimension: 0),
        borderRadius: BorderRadius.circular(SizeManager.medium),
        items: List.generate(
          12,
          (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(
                (index + 1) == now.month
                    ? "This month"
                    : DateFormat("MMMM").format(DateTime(now.year, index + 1)),
                style: TextStyle(
                  color: ColorManager.secondary,
                  fontSize: FontSizeManager.small,
                  fontFamily: 'lato',
                ),
              ),
            );
          },
        ),
        onChanged: (value) {
          setState(() => selectMonth = value!);
        },
      ),
    );
  }

  FlTitlesData getTitlesData(
      {required final List<double> data, required final double maxAmount}) {
    return FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          interval: maxAmount / 2,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final highestFormattedString =
                NumberFormat.compact().format(maxAmount * 1.5);
            final maxFormattedString = NumberFormat.compact().format(maxAmount);
            final halfFormattedString =
                NumberFormat.compact().format(maxAmount ~/ 2);
            final String text = value == maxAmount
                ? maxFormattedString
                : value == maxAmount / 2
                    ? halfFormattedString
                    : value == maxAmount * 1.5
                        ? highestFormattedString
                        : "";
            return Text(
              text,
              style: TextStyle(
                  color: ColorManager.secondary,
                  fontSize: FontSizeManager.small * 0.8,
                  fontWeight: FontWeightManager.semibold),
            ).quicksand();
          },
        )),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            String text = "";
            switch (value.round().toInt()) {
              case 1:
                text = "1st";
                break;
              case 2:
                text = "2nd";
                break;
              case 3:
                text = "3rd";
                break;
              case 4:
                text = "4th";
            }
            return Transform.rotate(
              angle: 120,
              child: Text(
                text,
                style: TextStyle(
                    color: ColorManager.secondary,
                    fontSize: FontSizeManager.small * 0.8,
                    fontWeight: FontWeightManager.semibold),
              ).quicksand(),
            );
          },
        )));
  }

  LineChartBarData getBarsData({required List<double> data}) {
    final buyingColors = [Colors.red.shade200, Colors.red.shade100];
    final sellingColors = [Colors.green.shade200, Colors.green.shade100];
    return LineChartBarData(
      color: ref.watch(statisticsMode) == TransactionPurpose.Buying
          ? Colors.red
          : ColorManager.accentColor,
      belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: ref.watch(statisticsMode) == TransactionPurpose.Buying
                ? buyingColors
                : sellingColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
      spots: [
        const FlSpot(0, 0),
        ...List.generate(
          data.length,
          (index) => FlSpot(index + 1, data[index]),
        )
      ],
    );
  }
}
