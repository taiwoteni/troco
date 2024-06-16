import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/images/pick-profile-widget.dart';
import 'package:troco/core/components/others/drag-handle.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/presentation/provider/payment-methods-provider.dart';
import 'package:troco/features/payments/presentation/widgets/account-details-sheet.dart';
import 'package:troco/features/payments/presentation/widgets/card-details-sheet.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';

class PaymentMethodAction extends ConsumerStatefulWidget {
  final PaymentMethod method;
  const PaymentMethodAction({super.key, required this.method});

  @override
  ConsumerState<PaymentMethodAction> createState() =>
      _PaymentMethodActionState();
}

class _PaymentMethodActionState extends ConsumerState<PaymentMethodAction> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: SingleChildScrollView(
        child: Column(
          children: [
            extraLargeSpacer(),
            const DragHandle(),
            largeSpacer(),
            title(),
            mediumSpacer(),
            ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return menuItems()[index];
                },
                separatorBuilder: (context, index) => Divider(
                      color: ColorManager.secondary.withOpacity(0.08),
                    ),
                itemCount: menuItems().length),
            largeSpacer()
          ],
        ),
      ),
    );
  }

  List<DialogMenuItem> menuItems() {
    return [
      DialogMenuItem(
        icon: Icons.edit_rounded,
        color: ColorManager.accentColor,
        label:
            "Edit ${widget.method is CardMethod ? "card detail" : "account detail"}",
        onPressed: editMethod,
      ),
      DialogMenuItem(
        icon: CupertinoIcons.trash_fill,
        color: Colors.red,
        label:
            "Delete ${widget.method is CardMethod ? "card detail" : "account detail"}",
        onPressed: deleteMethod,
      ),
    ];
  }

  Widget title() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            "Payment Method",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "Lato",
                fontSize: FontSizeManager.large * 0.9),
          ),
        ),
        Positioned(
          width: SizeManager.extralarge * 1.1,
          height: SizeManager.extralarge * 1.1,
          right: SizeManager.regular,
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorManager.accentColor.withOpacity(0.2))),
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.accentColor,
                size: IconSizeManager.small,
              )),
        )
      ],
    );
  }

  Future<void> editMethod() async {
    final method = await showModalBottomSheet<PaymentMethod?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => widget.method is CardMethod
          ? AddCardDetails(
              card: widget.method as CardMethod,
            )
          : const AddAccountDetails(),
    );

    if (method != null) {
      final paymentMethods = AppStorage.getPaymentMethods();
      final index = paymentMethods.indexWhere(
        (element) => element.uuid() == widget.method.uuid(),
      );
      paymentMethods[index] = method;

      AppStorage.savePaymentMethod(paymentMethods: paymentMethods);
      ref.watch(paymentMethodProvider.notifier).state = paymentMethods;
    }
    Navigator.pop(context);
  }

  Future<void> deleteMethod() async {
    final paymentMethods = AppStorage.getPaymentMethods();
    final index = paymentMethods.indexWhere(
      (element) => element.uuid() == widget.method.uuid(),
    );
    paymentMethods.removeAt(index);

    AppStorage.savePaymentMethod(paymentMethods: paymentMethods);
    ref.watch(paymentMethodProvider.notifier).state = paymentMethods;
    Navigator.pop(context);
  }
}
