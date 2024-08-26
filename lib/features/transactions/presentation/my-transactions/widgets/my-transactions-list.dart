import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/size-manager.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../dashboard/presentation/widgets/transaction-item-widget.dart';
import '../../../domain/entities/transaction.dart';
import '../../view-transaction/providers/transactions-provider.dart';

class MyTransactionsList extends ConsumerStatefulWidget {
  const MyTransactionsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyTransactionsListState();
}

class _MyTransactionsListState extends ConsumerState<MyTransactionsList> {
  final defaultStyle = TextStyle(
      fontFamily: 'quicksand',
      color: ColorManager.primary,
      fontSize: FontSizeManager.large * 0.85,
      fontWeight: FontWeightManager.bold);

  List<Transaction> transactions = AppStorage.getAllTransactions();

  @override
  void initState() {
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
    transactions.sort(
      (a, b) => b.creationTime.compareTo(a.creationTime),
    );
    return ListView.separated(
        key: const Key("latestTransactionsList"),
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.medium),
              child: TransactionItemWidget(
                key: ObjectKey(transactions[index]),
                transaction: transactions[index],
                fromDarkStatusBar: true,
              ),
            ),
        separatorBuilder: (context, index) => Divider(
              thickness: 0.8,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
        itemCount: transactions.length);
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        log("loaded");
        setState(() {
          transactions = value;
        });
      });
    });
  }
}
