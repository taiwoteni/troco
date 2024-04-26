import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/groups/presentation/widgets/empty-screen.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../domain/entities/transaction.dart';

class TransactionProgressPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const TransactionProgressPage({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionProgressPageState();
}

class _TransactionProgressPageState
    extends ConsumerState<TransactionProgressPage> {
  late Transaction transaction;

  @override
  void initState() {
    transaction = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyScreen(
      lottie: AssetManager.lottieFile(name: getAnimationName()),
      scale: getAnimationScale(),
      label: getAnimationLabel(),
      expanded: true,
    );
  }

  String getAnimationName() {
    switch (transaction.transactionStatus) {
      default:
        return "pending";
    }
  }

  double getAnimationScale() {
    switch (transaction.transactionStatus) {
      case TransactionStatus.Pending:
        return 1.2;
      default:
        return 1.0;
    }
  }

  String getAnimationLabel() {
    switch (transaction.transactionStatus) {
      default:
        return "Waiting for buyer to approve.";
    }
  }
}
