import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/payments/presentation/provider/payment-methods-provider.dart';
import 'package:troco/features/payments/presentation/widgets/payment-card-widget.dart';

import '../../../../core/app/size-manager.dart';

class PaymentMethodsList extends ConsumerStatefulWidget {
  const PaymentMethodsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaymentMethodsListState();
}

class _PaymentMethodsListState extends ConsumerState<PaymentMethodsList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        child: Column(
          children: [
            largeSpacer(),
            ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Transform.scale(
                    scaleY: 0.9,
                    child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                            horizontal: SizeManager.large * 1.55),
                        child: PaymentCard(
                            primary: primaryColor(index: index),
                            secondary: primaryColor(index: index).shade800,
                            method: ref.watch(paymentMethodProvider)[index])),
                  );
                },
                separatorBuilder: (context, index) => regularSpacer(),
                itemCount: ref.watch(paymentMethodProvider).length),
          ],
        ),
      ),
    );
  }

  MaterialColor primaryColor({required int index}) {
    if ((index + 1) % 4 == 0) {
      return Colors.pink;
    } else if ((index + 1) % 3 == 0) {
      return Colors.purple;
    } else if ((index + 1) % 2 == 0) {
      return Colors.blue;
    } else {
      return Colors.brown;
    }
  }
}
