import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/menu-toggle.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/my-transactions-per-month.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/transactions-pie-chart.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../groups/presentation/groups_page/widgets/empty-screen.dart';
import '../../../domain/entities/transaction.dart';
import '../../view-transaction/providers/transactions-provider.dart';

class MyStatisticsPage extends ConsumerStatefulWidget {
  const MyStatisticsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<MyStatisticsPage> {
  List<Transaction> transactions = [];

  @override
  void initState() {
    transactions = AppStorage.getTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    listenToChanges();
    return transactions.isEmpty ? emptyBody() : body();
  }

  Widget emptyBody() {
    return Container(
        alignment: Alignment.center,
        child: Column(children: [
          extraLargeSpacer(),
          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeManager.large * 1.2),
              child: back()),
          mediumSpacer(),
          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeManager.large * 1.2),
              child: Align(alignment: Alignment.centerLeft, child: title())),
          EmptyScreen(
            lottie: AssetManager.lottieFile(name: "empty-transactions"),
            scale: 1.5,
            label: "You do not have any transactions.",
            expanded: true,
          ),
        ]));
  }

  Widget body() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extraLargeSpacer(),
          back(),
          mediumSpacer(),
          title(),
          largeSpacer(),
          mediumSpacer(),
          pieChartAnalysis(),
          extraLargeSpacer(),
          statisticsMode(),
          largeSpacer(),
          const MyTransactionsPerMonth()
        ],
      ),
    );
  }

  Widget title() {
    return Text(
      "My Statistics",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget back() {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
              shape: const MaterialStatePropertyAll(CircleBorder()),
              backgroundColor: MaterialStatePropertyAll(
                  ColorManager.accentColor.withOpacity(0.2))),
          icon: Icon(
            Icons.close_rounded,
            color: ColorManager.accentColor,
            size: IconSizeManager.small,
          )),
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
          completed(),
          mediumSpacer(),
          ongoing(),
        ],
      ),
    );
  }

  Widget statisticsMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        largeSpacer(),
        const Align(child: MenuToggle()),
        largeSpacer(),
      ],
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

  Widget completed() {
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

  Widget ongoing() {
    final transactions = AppStorage.getTransactions();

    final ongoingAmount = transactions
        .where(
          (element) => ![
            TransactionStatus.Completed,
            TransactionStatus.Cancelled
          ].contains(element.transactionStatus),
        )
        .fold(
          0,
          (previousValue, transaction) =>
              previousValue + transaction.transactionAmount.toInt(),
        );
    final ongoingAmountString = NumberFormat.compact().format(ongoingAmount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: IconSizeManager.small * 0.5,
          height: IconSizeManager.small * 0.5,
          margin: const EdgeInsets.only(top: SizeManager.small),
          decoration:
              const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
        ),
        regularSpacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            smallText(text: "Ongoing"),
            mediumText(text: ongoingAmountString)
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

  Future<void> listenToChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        value.sort(
          (a, b) => (1.compareTo(0)),
        );
        setState(() {
          transactions = value;
        });
      });
    });
  }
}
