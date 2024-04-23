import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/transaction-category-page.dart';
import '../views/transaction-description-page.dart';
import '../views/transaction-finalize-page.dart';
import '../views/transaction-pricing-page.dart';

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
