// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/presentation/widgets/account-details-sheet.dart';
import 'package:troco/features/payments/presentation/widgets/card-details-sheet.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-method-widget.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/cache/shared-preferences.dart';
import '../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../core/components/others/drag-handle.dart';
import '../../../../core/components/others/spacer.dart';
import '../provider/payment-methods-provider.dart';

class AddPaymentMethod extends ConsumerStatefulWidget {
  const AddPaymentMethod({super.key});

  @override
  ConsumerState<AddPaymentMethod> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<AddPaymentMethod> {
  bool account = false;
  final buttonKey = UniqueKey();

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
            Divider(
              thickness: 1,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
            mediumSpacer(),
            row(),
            largeSpacer(),
            button(),
            extraLargeSpacer(),
          ],
        ),
      ),
    );
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
            "Choose Payment Method",
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

  Widget row() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SelectPaymentMethodWidget(
            selected: !account,
            onChecked: () => setState(() => account = false),
            label: "Card",
            lottie: AssetManager.lottieFile(name: "card-payment")),
        largeSpacer(),
        SelectPaymentMethodWidget(
            selected: account,
            onChecked: () => setState(() => account = true),
            label: "Bank Account",
            lottie: AssetManager.lottieFile(name: "bank-payment")),
      ],
    );
  }

  Widget button() {
    return CustomButton(
      onPressed: onTap,
      label: "Next",
      buttonKey: buttonKey,
      usesProvider: true,
    );
  }

  Future<void> onTap() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

    final paymentMethod = await method();

    if (paymentMethod != null) {
      final paymentMethods = AppStorage.getPaymentMethods();
      paymentMethods.add(paymentMethod);
      AppStorage.savePaymentMethod(paymentMethods: paymentMethods);
      ref.watch(paymentMethodProvider.notifier).state = paymentMethods;
      ref.watch(paymentMethodProvider.notifier).state = paymentMethods;
      // setState(() {});
    }

    Navigator.pop(context, paymentMethod);
  }

  Future<PaymentMethod?> method() async {
    return await showModalBottomSheet<PaymentMethod?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) =>
          !account ? const AddCardDetails() : const AddAccountDetails(),
    );
  }
}
