import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/services/presentation/calc/provider/fee-provider.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../transactions/presentation/create-transaction/widgets/select-transaction-type-widget.dart';
import '../../../../transactions/utils/enums.dart';

class SelectCategoryPage extends ConsumerStatefulWidget {
  const SelectCategoryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectCategoryPageState();
}

class _SelectCategoryPageState extends ConsumerState<SelectCategoryPage> {
  final buttonKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        extraLargeSpacer(),
        chooseFeeCategory(),
        largeSpacer(),
        SelectTransactionTypeWidget(
          label: 'Product',
          description: "Select if a product-based transaction.",
          selected:
              ref.watch(feeCategoryProvider) == TransactionCategory.Product,
          onChecked: () {
            ref.watch(feeCategoryProvider.notifier).state =
                TransactionCategory.Product;
          },
        ),
        mediumSpacer(),
        SelectTransactionTypeWidget(
          label: 'Service',
          description: "Select if a service-based transaction.",
          selected:
              ref.watch(feeCategoryProvider) == TransactionCategory.Service,
          onChecked: () {
            ref.watch(feeCategoryProvider.notifier).state =
                TransactionCategory.Service;
          },
        ),
        mediumSpacer(),
        SelectTransactionTypeWidget(
          label: 'Virtual',
          description: "Select if a virtual-product based transaction.",
          selected:
              ref.watch(feeCategoryProvider) == TransactionCategory.Virtual,
          onChecked: () {
            ref.watch(feeCategoryProvider.notifier).state =
                TransactionCategory.Virtual;
          },
        ),
        largeSpacer(),
        button(),
        extraLargeSpacer(),
      ],
    );
  }

  Widget chooseFeeCategory() {
    return Text(
      "Choose your transaction category",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'lato',
          fontSize: FontSizeManager.small * 1.1,
          fontWeight: FontWeightManager.regular),
    );
  }

  Widget button() {
    return CustomButton(
      label: "Next",
      buttonKey: buttonKey,
      usesProvider: true,
      onPressed: next,
    );
  }

  Future<void> next() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    //should move to next page
    ref.watch(feePageViewProvider.notifier).state.nextPage(
        duration: const Duration(milliseconds: 450), curve: Curves.ease);
  }
}
