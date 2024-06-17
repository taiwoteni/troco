
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/utils/enums.dart';

final feeCategoryProvider = StateProvider<TransactionCategory>((ref) {
  return TransactionCategory.Product;
});


final feePageViewProvider = StateProvider<PageController>((ref) {
  return PageController();
});