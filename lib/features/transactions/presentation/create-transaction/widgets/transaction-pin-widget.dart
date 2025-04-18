// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/texts/inputs/otp-input-field.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class TransactionPinSheet extends ConsumerStatefulWidget {
  final bool createTansactionMode;
  const TransactionPinSheet({super.key, this.createTansactionMode = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPinSheetState();

  static Future<bool?> bottomSheet(
      {required final BuildContext context,
      bool createTransactionMode = false}) {
    return showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: ColorManager.background,
      builder: (context) {
        return SingleChildScrollView(
            child: TransactionPinSheet(
                createTansactionMode: createTransactionMode));
      },
    );
  }
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
            onEntered: (value) {
              setState(() => pin1 = value);
            },
          ),
          OtpInputField(
            obscure: true,
            onEntered: (value) {
              setState(() => pin2 = value);
            },
          ),
          OtpInputField(
            obscure: true,
            onEntered: (value) {
              setState(() => pin3 = value);
            },
          ),
          OtpInputField(
            obscure: true,
            last: true,
            onEntered: (value) {
              setState(() => pin4 = value);
            },
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

    if (widget.createTansactionMode) {
      final escrowChargesResponse = await TransactionRepo.getEscrowCharges();
      log(escrowChargesResponse.body);
    }

    final response = await AuthenticationRepo.verifyTransactionPin(
        transactionPin: "$pin1$pin2$pin3$pin4");
    // log(response.body.toString());

    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

    final theSame =
        response.messageBody?["message"].toString().toLowerCase().trim() ==
            "validated... correct pin passed";

    if (theSame) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        Navigator.pop(context, false);
      }
      SnackbarManager.showBasicSnackbar(
          mode: ContentType.failure,
          context: context,
          message: "Incorrect Pin or Internet Error");
    }
  }
}
