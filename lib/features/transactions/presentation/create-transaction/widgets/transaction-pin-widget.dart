// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/texts/inputs/otp-input-field.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class TransactionPinSheet extends ConsumerStatefulWidget {
  const TransactionPinSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPinSheetState();
}

class _TransactionPinSheetState extends ConsumerState<TransactionPinSheet> {
  final buttonKey = UniqueKey();
  String pin1 = "";
  String pin2 = "";
  String pin3 = "";
  String pin4 = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
          left: SizeManager.medium,
          right: SizeManager.medium,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.large))),
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
          extraLargeSpacer(),
          otpEntry(),
          extraLargeSpacer(),
          button(),
          largeSpacer(),
        ],
      ),
    );
  }

  Widget title() {
    return Text(
      "Transaction Pin",
      style: TextStyle(
          color: ColorManager.primary,
          fontWeight: FontWeightManager.bold,
          fontFamily: "Lato",
          fontSize: FontSizeManager.large * 0.9),
    );
  }

  Widget otpEntry() {
    return Form(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OtpInputField(
            first: true,
            obscure: true,
            onEntered: (value) {},
          ),
          OtpInputField(
            obscure: true,
            onEntered: (value) {},
          ),
          OtpInputField(
            obscure: true,
            onEntered: (value) {},
          ),
          OtpInputField(
            obscure: true,
            last: true,
            onEntered: (value) {},
          )
        ],
      ),
    );
  }

  Widget button() {
    return CustomButton(
      label: "Enter",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: verifyPin,
    );
  }

  Future<void> verifyPin() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    final response = await AuthenticationRepo.verifyTransactionPin(
        transactionPin: "$pin1$pin2$pin3$pin4");

    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

    if (!response.error) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        Navigator.pop(context, false);
      }
      SnackbarManager.showBasicSnackbar(
        context: context,
        message: "Incorrect Pin or Internet Error");
    }
  }
}
