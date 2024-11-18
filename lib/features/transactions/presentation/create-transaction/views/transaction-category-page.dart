import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/create-transaction-provider.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/transaction-controller-provider.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../utils/enums.dart';
import '../widgets/select-transaction-type-widget.dart';

class TransactionTermsPage extends ConsumerStatefulWidget {
  const TransactionTermsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionTermsPageState();
}

class _TransactionTermsPageState extends ConsumerState<TransactionTermsPage> {
  final buttonKey = UniqueKey();
  TransactionCategory? category =
      TransactionDataHolder.transactionCategory ?? TransactionCategory.Product;

  @override
  Widget build(BuildContext context) {
    final disabled = TransactionDataHolder.isEditing == true ||
        TransactionDataHolder.transactionCategory != null;
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: SizeManager.medium, horizontal: SizeManager.large),
        child: SizedBox.expand(
          child: Column(
            children: [
              title(),
              largeSpacer(),
              Opacity(
                opacity: disabled ? 0.4 : 1,
                child: SelectTransactionTypeWidget(
                  label: 'Product',
                  description: "Select if a product-based transaction.",
                  selected: category == TransactionCategory.Product,
                  onChecked: () {
                    if (disabled) {
                      return;
                    }
                    setState(() {
                      category = TransactionCategory.Product;
                    });
                  },
                ),
              ),
              mediumSpacer(),
              Opacity(
                opacity: disabled ? 0.4 : 1,
                child: SelectTransactionTypeWidget(
                  label: 'Service',
                  description: "Select if a service-based transaction.",
                  selected: category == TransactionCategory.Service,
                  onChecked: () {
                    if (disabled) {
                      return;
                    }
                    setState(() {
                      category = TransactionCategory.Service;
                    });
                  },
                ),
              ),
              mediumSpacer(),
              Opacity(
                opacity: disabled ? 0.4 : 1,
                child: SelectTransactionTypeWidget(
                  label: 'Virtual',
                  description: "Select if a virtual-product based transaction.",
                  selected: category == TransactionCategory.Virtual,
                  onChecked: () {
                    if (disabled) {
                      return;
                    }
                    setState(() {
                      category = TransactionCategory.Virtual;
                    });
                  },
                ),
              ),
              largeSpacer(),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Category",
        style: TextStyle(
            fontFamily: "Lato",
            fontSize: FontSizeManager.large * 0.9,
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
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 3));
        TransactionDataHolder.transactionCategory = category;
        TransactionDataHolder.id = null;
        TransactionDataHolder.items = [];
        ref.read(transactionPageController.notifier).moveNext(nextPageIndex: 1);
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }
}
