import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/presentation/provider/payment-methods-provider.dart';
import 'package:troco/features/payments/presentation/widgets/add-payment-sheet.dart';
import 'package:troco/features/payments/presentation/widgets/no-payment-methods-widget.dart';
import 'package:troco/features/payments/presentation/widgets/payment-methods-list.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/images/svg.dart';
import '../../../../core/components/others/spacer.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      appBar: appBar(),
      body: ref.watch(paymentMethodProvider).isEmpty
          ? const NoPaymentMethod()
          : const PaymentMethodsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: addPaymentMethod,
        shape: const CircleBorder(),
        backgroundColor: ColorManager.accentColor,
        foregroundColor: Colors.white,
        child: const Icon(
          CupertinoIcons.add,
          size: IconSizeManager.regular,
        ),
      ),
    );
  }

  Future<void> addPaymentMethod() async {
    await showPaymentSheet();
  }

  Future<void> showPaymentSheet() async {
    final method = await showModalBottomSheet<PaymentMethod?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => const AddPaymentMethod(),
    );
    if (method != null) {
      final paymentMethods = AppStorage.getPaymentMethods();
      paymentMethods.add(method);
      AppStorage.savePaymentMethod(paymentMethods: paymentMethods);

      ref.watch(paymentMethodProvider.notifier).state.add(method);

    }
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Payment Methods",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
