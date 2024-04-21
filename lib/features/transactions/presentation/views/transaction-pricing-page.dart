import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/button/presentation/provider/button-provider.dart';
import '../../../../core/basecomponents/button/presentation/widget/button.dart';

class TransactionPricingPage extends ConsumerStatefulWidget {
  const TransactionPricingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPricingPageState();
}

class _TransactionPricingPageState
    extends ConsumerState<TransactionPricingPage> {
  final formKey = GlobalKey<FormState>();
  final buttonKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.large, right: SizeManager.large),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                mediumSpacer(),
                title(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
        child: Row(
          children: [
            Expanded(child: button()),
            mediumSpacer(),
            FloatingActionButton(
              onPressed: null,
              backgroundColor: ColorManager.accentColor,
              // foregroundColor: Colors.white,
              child: SvgIcon(
                svgRes: AssetManager.svgFile(name: "add-product"),
                size: const Size.square(IconSizeManager.medium * 0.9),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Pricing",
        style: TextStyle(
            fontFamily: "Quicksand",
            fontSize: FontSizeManager.large,
            color: ColorManager.primary,
            fontWeight: FontWeightManager.bold),
      ),
    );
  }

  Widget button() {
    return CustomButton.medium(
      label: "Continue",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.accentColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 3));
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          // TransactionDataHolder.inspectionPeriod = inspectByDay;
          // TransactionDataHolder.inspectionDays = inspectionDay;
          // ref.read(createTransactionPageController.notifier).state.nextPage(
          //     duration: const Duration(milliseconds: 450), curve: Curves.ease);
          // ref.read(createTransactionProgressProvider.notifier).state = 2;
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }
}
