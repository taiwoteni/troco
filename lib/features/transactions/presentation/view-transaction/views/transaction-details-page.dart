import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';

class TransactionsDetailPage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const TransactionsDetailPage({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransactionsDetailPageState();
}

class _TransactionsDetailPageState extends ConsumerState<TransactionsDetailPage> {

  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}