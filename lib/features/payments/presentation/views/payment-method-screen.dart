import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
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
  bool justCameBack = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: ref.watch(paymentMethodProvider).isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header(),
                  PaymentMethodsList(
                    methods: ref.watch(paymentMethodProvider),
                  )
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [header(), const Expanded(child: NoPaymentMethod())],
            ),
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

  Widget header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extraLargeSpacer(),
          back(),
          mediumSpacer(),
          title(),
        ],
      ),
    );
  }

  Widget title() {
    return Text(
      "Payment Methods",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget back() {
    return Align(
      alignment: Alignment.centerRight,
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
    );
  }

  Future<void> addPaymentMethod() async {
    await showPaymentSheet();
  }

  Future<void> showPaymentSheet() async {
    await showModalBottomSheet<PaymentMethod?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => const AddPaymentMethod(),
    );
    setState(() {});
    ref.watch(paymentMethodProvider);
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
