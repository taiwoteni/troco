import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';

final statisticsMode = StateProvider<TransactionPurpose>((ref) {
  return ClientProvider.readOnlyClient!.accountCategory == Category.Personal
      ? TransactionPurpose.Buying
      : TransactionPurpose.Selling;
});
