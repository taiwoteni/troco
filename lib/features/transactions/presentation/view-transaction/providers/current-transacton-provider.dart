
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';

import '../../../domain/entities/transaction.dart';

final currentTransactionProvider = StateProvider<Transaction>((ref) {
  return AppStorage.getTransactions().isNotEmpty? AppStorage.getTransactions().last:const Transaction.fromJson(json: {});
});