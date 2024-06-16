import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/payments/presentation/widgets/payment-card-widget.dart';

import '../../../../core/app/size-manager.dart';
import '../../domain/entity/payment-method.dart';

class PaymentMethodsList extends ConsumerStatefulWidget {
  final List<PaymentMethod> methods;
  const PaymentMethodsList({super.key, required this.methods});

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
                        child: PaymentCard(method: widget.methods[index])),
                  );
                },
                separatorBuilder: (context, index) => mediumSpacer(),
                itemCount: widget.methods.length),
          ],
        ),
      ),
    );
  }
}
