// ignore_for_file: dead_code
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transactions-provider.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/routes-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../transactions/domain/entities/transaction.dart';
import 'transaction-item-widget.dart';

class LatestTransactionsList extends ConsumerStatefulWidget {
  const LatestTransactionsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LatestTransactionsListState();
}

class _LatestTransactionsListState
    extends ConsumerState<LatestTransactionsList> {
  final defaultStyle = TextStyle(
      fontFamily: 'quicksand',
      color: ColorManager.primary,
      fontSize: FontSizeManager.large * 0.85,
      fontWeight: FontWeightManager.bold);

  List<Transaction> transactions = AppStorage.getAllTransactions();
  @override
  void initState() {
    transactions.sort(
      (a, b) => (b.timeToSort.compareTo(a.timeToSort)),
    );
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      setState(() {
        transactions = transactions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    listenToTransactionsChanges();
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManager.medium + SizeManager.regular),
            child: Row(
              children: [
                Text(
                  "Latest Transactions",
                  style: defaultStyle,
                  textAlign: TextAlign.start,
                ),
                const Spacer(),
                TextButton(
                    onPressed: () async {
                      /// to wait for my transactions page to open, then later,
                      /// then change it back to home Ui  overlay style
                      await Navigator.pushNamed(
                          context, Routes.myTransactionsRoute);
                      SystemChrome.setSystemUIOverlayStyle(
                          ThemeManager.getHomeUiOverlayStyle());
                    },
                    child: Text(
                      "View All",
                      style: defaultStyle.copyWith(
                          color: ColorManager.accentColor,
                          fontSize: FontSizeManager.regular * 0.9,
                          fontWeight: FontWeightManager.semibold),
                    ))
              ],
            ),
          ),
          regularSpacer(),
          ListView.separated(
              key: const Key("latestTransactionsList"),
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.regular),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => TransactionItemWidget(
                    key: ObjectKey(transactions[index]),
                    transaction: transactions[index],
                  ),
              separatorBuilder: (context, index) => Divider(
                    thickness: 0.8,
                    color: ColorManager.secondary.withOpacity(0.08),
                  ),
              itemCount: transactions.length >= 3 ? 3 : transactions.length)
        ],
      ),
    );
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        // log("loaded");
        value.sort(
          (a, b) => (b.timeToSort.compareTo(a.timeToSort)),
        );
        setState(() {
          transactions = value.toSet().toList();
        });
      });
    });
  }
}
