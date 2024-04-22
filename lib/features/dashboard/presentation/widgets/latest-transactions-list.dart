import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/dashboard/data/datasources/latest-transactions.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/others/spacer.dart';
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

  @override
  Widget build(BuildContext context) {
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
                    onPressed: null,
                    child: Text(
                      "View All",
                      style: defaultStyle.copyWith(
                          color: ColorManager.accentColor,
                          fontSize: FontSizeManager.regular * 0.9,
                          fontWeight: FontWeightManager.medium),
                    ))
              ],
            ),
          ),
          regularSpacer(),
          ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.regular),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => TransactionItemWidget(
                    transaction: latestTransactions()[index],
                  ),
              separatorBuilder: (context, index) => Divider(
                    thickness: 0.8,
                    color: ColorManager.secondary.withOpacity(0.08),
                  ),
              itemCount: latestTransactions().length >= 3
                  ? 3
                  : latestTransactions().length)
        ],
      ),
    );
  }
}
