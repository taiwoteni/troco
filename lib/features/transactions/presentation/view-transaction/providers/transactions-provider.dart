// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';

import '../../../domain/entities/transaction.dart';

    int i = 0;


/// This is a state Provider, responsible for returning and refreshing
/// the Transaction Repo class. Inorder reload to be on the safer side when looking for changes.
final transacionRepoProvider =
    StateProvider<TransactionRepo>((ref) => TransactionRepo());

/// The Future provider that helps us to perform
/// The Future task of getting Groups.
final transactionFutureProvider =
    FutureProvider<List<Map<dynamic, dynamic>>>((ref) async {
  final transactionRepo = ref.watch(transacionRepoProvider);
  final data = await transactionRepo.getTransactions();
  // log(data.toString());
  // log("Loaded data from groupRepo");
  return data.map((e) => e.toJson()).toList();
});

/// The StreamProvider that constantly sends updates
/// Of the Transactions States only when there is a change
/// Cos we don't want constant rebuilding in the consumer widgets.
final transactionsStreamProvider = StreamProvider<List<Transaction>>(
  (ref) {
    final streamController = StreamController<List<Transaction>>();

    final periodic = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.watch(transactionFutureProvider).when(
          data: (transactionsJson) {
            /// First of all we have to compare and contrast between the
            /// values gotten from the APIs and saved on the Device Cache.
            ///
            /// We compare and contrast the transaction itself.
            ///
            /// We extract the Lists. Lists starting with underscores ('_') are from the Cache.
            /// While the others are from the [transactionsJson];

            /// We get the transactionsList from the Cache
            final _transacionsList =
                AppStorage.getAllTransactions().map((e) => e.toJson()).toList();

            if(i==0){
              log(transactionsJson.last.toString());
              i++;
            }

                /// This is because some transactions json have empty products.
                /// Due to previous complications in consuming the APIs. 
            final sortedTransactionsList = transactionsJson;
            

            // bool sameProducts = _transacionsList.map((e) => ,)

            /// Then We contrast.
            final bool transactionsDifferent =
                json.encode(_transacionsList) != json.encode(sortedTransactionsList);

            final valuesAreDifferent = transactionsDifferent;

            List<Transaction> transactionsList = sortedTransactionsList.map((e) => Transaction.fromJson(json: e))
                .toList();

            if (valuesAreDifferent) {
              log('transactions have changed');

              AppStorage.saveTransactions(transactions: transactionsList);
              streamController.sink.add(transactionsList);
            }
            ref.watch(transacionRepoProvider.notifier).state =
                TransactionRepo();
            // log("==================");
          },
          error: (error, stackTrace) =>
              log("Error occured when getting transactions from api $error"),
          loading: () => null);
    });

    ref.onDispose(() {
      streamController.close();
      periodic.cancel();
    });
    return streamController.stream;
  },
);
