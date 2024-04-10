import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/basecomponents/button/presentation/provider/button-provider.dart';
import 'package:troco/core/basecomponents/button/presentation/widget/button.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/presentation/providers/create-transaction-provider.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';

class TransactionTermsPage extends ConsumerStatefulWidget {
  const TransactionTermsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionTermsPageState();
}

class _TransactionTermsPageState extends ConsumerState<TransactionTermsPage> {
  final buttonKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: SizeManager.medium, horizontal: SizeManager.large),
        child: SizedBox.expand(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Terms And Conditions",
                  style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: FontSizeManager.large * 0.9,
                      color: ColorManager.primary,
                      fontWeight: FontWeightManager.bold),
                ),
              ),
              extraLargeSpacer(),
              CustomButton.medium(
                label: "Continue",
                usesProvider: true,
                buttonKey: buttonKey,
                onPressed: () async {
                  ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
                  await Future.delayed(const Duration(seconds: 3));
                  ref
                      .read(createTransactionPageController.notifier)
                      .state
                      .nextPage(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.ease);
                  ref.read(createTransactionProgressProvider.notifier).state =
                      1;
                  ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
