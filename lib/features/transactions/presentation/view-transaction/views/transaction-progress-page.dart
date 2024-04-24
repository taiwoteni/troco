import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/groups/presentation/widgets/empty-screen.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../domain/entities/transaction.dart';

class TransactionProgressPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const TransactionProgressPage({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransactionProgressPageState();
}

class _TransactionProgressPageState extends ConsumerState<TransactionProgressPage> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: double.maxFinite,
      child: EmptyScreen(
        lottie: AssetManager.lottieFile(name: "empty-transactions"),
        scale: 1.5,
        label: "No Progress Yet.",
        expanded: false,
      ),
    );
  }
}