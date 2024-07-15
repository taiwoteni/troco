import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../provider/fee-provider.dart';
import 'fee-keypad-widget.dart';

class FeeCalculationPage extends ConsumerStatefulWidget {
  const FeeCalculationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectCategoryPageState();
}

class _SelectCategoryPageState extends ConsumerState<FeeCalculationPage> {
  String price = "0";
  String charges = "0";
  final buttonKey = UniqueKey();
  bool calculated = false;

  @override
  void setState(VoidCallback fn, {final bool? calculation}) {
    if (!mounted) {
      return;
    }

    if (calculation ?? false) {
      calculated = true;
    } else {
      calculated = false;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mediumSpacer(),
        enterEstimatedSales(),
        mediumSpacer(),
        priceText(),
        mediumSpacer(),
        keyPad(),
        largeSpacer(),
        calculate(),
        extraLargeSpacer(),
      ],
    );
  }

  Widget enterEstimatedSales() {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: "N",
      decimalDigits: 2,
    );
    return Text(
      calculated
          ? "Calculated price with charges (${formatter.format(double.parse(charges))}):"
          : "Enter your estimated price:",
      textAlign: TextAlign.left,
      style: TextStyle(
          color:
              !calculated ? ColorManager.secondary : ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.small * 1.1,
          fontWeight: FontWeightManager.regular),
    );
  }

  Widget keyPad() {
    final keys = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...keys.getRange(0, 3).map(
                    (e) => FeeKeypadWidget(
                        onTap: () =>
                            setState(() => price = price + e.toString()),
                        text: e.toString()),
                  ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...keys.getRange(3, 6).map(
                    (e) => FeeKeypadWidget(
                        onTap: () =>
                            setState(() => price = price + e.toString()),
                        text: e.toString()),
                  ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...keys.getRange(6, 9).map(
                    (e) => FeeKeypadWidget(
                        onTap: () =>
                            setState(() => price = price + e.toString()),
                        text: e.toString()),
                  ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FeeKeypadWidget(
                  onTap: () => setState(() => price = price.contains(".")
                      ? "${price.replaceAll(".", ".")}."
                      : "$price."),
                  text: "."),
              FeeKeypadWidget(
                  onTap: () => setState(() => price = "${price}0"),
                  text: 0.toString()),
              GestureDetector(
                onLongPress: () => setState(() => price = "0"),
                child: IconButton.filled(
                    style: const ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size.square(73)),
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.transparent),
                        shape: WidgetStatePropertyAll(CircleBorder())),
                    onPressed: () => setState(() => price =
                        price.trim().isEmpty || price == "0"
                            ? "0"
                            : price.substring(0, price.length - 1)),
                    icon: Icon(
                      Icons.backspace_rounded,
                      color: ColorManager.accentColor,
                      size: IconSizeManager.medium * 0.8,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget priceText() {
    final formattedPrice = NumberFormat.currency(
      locale: 'en_NG',
      symbol: "",
      decimalDigits: 2,
    ).format(double.parse(price));
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
        child: Text(
          price.isEmpty ? "0" : formattedPrice,
          textAlign: TextAlign.right,
          style: TextStyle(
              color: ColorManager.primary,
              fontSize: FontSizeManager.large * 1.3,
              fontWeight: FontWeightManager.extrabold,
              fontFamily: 'lato'),
        ),
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount keyPadDelegate() {
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: SizeManager.medium,
      mainAxisSpacing: SizeManager.medium,
    );
  }

  Widget calculate() {
    return CustomButton(
      label: price.trim().isEmpty || price == "0" ? "Back" : "Calculate",
      buttonKey: buttonKey,
      usesProvider: true,
      onPressed: next,
    );
  }

  Future<void> next() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    //should move to next page
    if (price.trim().isEmpty || price == "0") {
      ref.watch(feePageViewProvider.notifier).state.previousPage(
          duration: const Duration(milliseconds: 450), curve: Curves.ease);
    } else {
      if (ref.watch(feeCategoryProvider) == TransactionCategory.Product) {
        setState(() {
          charges = ((double.parse(price) * 0.05)).toString();
          price = ((double.parse(price) * 1.05)).toString();
        }, calculation: true);
      } else if (ref.watch(feeCategoryProvider) ==
          TransactionCategory.Service) {
        double charge = double.parse(price) > 500000 ? 0.03 : 0.05;
        setState(() {
          charges = ((double.parse(price) * charge)).toString();
          price = ((double.parse(price) * (1 + charge))).toString();
        }, calculation: true);
      }
    }
  }
}
