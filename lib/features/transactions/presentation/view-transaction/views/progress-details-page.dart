import 'package:flutter/material.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../auth/presentation/providers/client-provider.dart';
import '../../../../groups/presentation/widgets/empty-screen.dart';
import '../../../domain/entities/transaction.dart';
import '../../../utils/enums.dart';

class ProgressDetailsPage extends StatefulWidget {
  final Transaction transaction;
  const ProgressDetailsPage({super.key, required this.transaction});

  @override
  State<ProgressDetailsPage> createState() => _ProgressDetailsPageState();
}

class _ProgressDetailsPageState extends State<ProgressDetailsPage> {
  late Transaction transaction;

  @override
  void initState() {
    transaction = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: EmptyScreen(
        lottie: AssetManager.lottieFile(name: getAnimationName()),
        scale: getAnimationScale(),
        label: getAnimationLabel(),
        expanded: true,
      ),
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
      case TransactionStatus.Processing:
        return 1.2;
      default:
        return 1.0;
    }
  }

  String getAnimationLabel() {
    final bool isSeller =
        transaction.creator == ClientProvider.readOnlyClient!.userId;
    switch (transaction.transactionStatus) {
      case TransactionStatus.Processing:
        return isSeller
            ? "Upload driver details"
            : "Seller is uploading driver details";
      case TransactionStatus.Inprogress:
        return "Waiting for admin to approve";
      default:
        return "Waiting for ${isSeller ? "buyer" : "you"} to approve..";
    }
  }
}
