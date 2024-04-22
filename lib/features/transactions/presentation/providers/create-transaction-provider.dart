import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/presentation/views/transaction-category-page.dart';
import 'package:troco/features/transactions/presentation/views/transaction-description-page.dart';
import 'package:troco/features/transactions/presentation/views/transaction-finalize-page.dart';
import 'package:troco/features/transactions/presentation/views/transaction-pricing-page.dart';

final createTransactionProgressProvider = StateProvider<int>((ref) => 0);
final createTransactionPageController =
    StateProvider<PageController>((ref) => PageController());
final createTransactionStagesProvider =
    StateProvider<List<Widget>>((ref) => const [
          TransactionTermsPage(),
          TransactionDescriptionPage(),
          TransactionPricingPage(),
          TransactionFinalizePage()
        ]);
