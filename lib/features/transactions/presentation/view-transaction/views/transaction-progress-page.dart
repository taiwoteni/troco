import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/progress-details-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/progress-timeline-page.dart';
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
  bool doneAnimating = false;

  @override
  void initState() {
    transaction = widget.transaction;
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      countDown();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AnimatedCrossFade(
            secondChild: ProgressTimelinePage(
              transaction: transaction,
            ),
            firstChild: ProgressDetailsPage(transaction: transaction),
            crossFadeState: !doneAnimating
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 400),
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeOut,
            sizeCurve: Curves.ease,
          ),
        )
      ],
    );
  }

  Future<void> countDown() async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() => doneAnimating = true);
  }
}
