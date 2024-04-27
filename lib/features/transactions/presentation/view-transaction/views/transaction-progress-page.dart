import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transaction-tab-index.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/progress-details-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/progress-timeline-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/menu-toggle.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mediumSpacer(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
          child: Align(
            alignment: Alignment.centerRight,
            child: MenuToggle(),
          ),
        ),
        mediumSpacer(),
        Expanded(
          child: AnimatedCrossFade(
            firstChild: ProgressTimelinePage(
              transaction: transaction,
            ),
            secondChild: ProgressDetailsPage(transaction: transaction),
            crossFadeState: ref.watch(menuToggleIndexProvider)
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
}
