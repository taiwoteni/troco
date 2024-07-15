// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/payments/data/models/payment-method-dataholder.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/repo/bank-repository.dart';
import 'package:troco/features/payments/utils/uppercase-input-formatter.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/drag-handle.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../../core/components/texts/inputs/text-form-field.dart';
import '../../domain/entity/bank.dart';
import 'select-bank-sheet.dart';

class AddAccountDetails extends ConsumerStatefulWidget {
  final AccountMethod? account;
  const AddAccountDetails({super.key, this.account});

  @override
  ConsumerState<AddAccountDetails> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<AddAccountDetails> {
  bool loading = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  Bank? bank;
  String? bankAccountError;
  late TextEditingController accountNumberController, bankNameController;

  @override
  void initState() {
    accountNumberController =
        TextEditingController(text: widget.account?.accountNumber);
    bankNameController = TextEditingController(text: widget.account?.bank.name);
    bank = widget.account?.bank;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              accountNumber(),
              mediumSpacer(),
              bankName(),
              largeSpacer(),
              button(),
              extraLargeSpacer(),
            ],
          ),
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
            "Add Account Details",
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
              onPressed: () => loading ? null : Navigator.pop(context),
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

  Widget accountNumber() {
    return InputFormField(
      label: 'Account Number',
      controller: accountNumberController,
      inputType: TextInputType.number,
      onSaved: (value) {
        PaymentMethodDataHolder.accountNumber = value;
      },
      validator: (value) {
        if (value == null) {
          return "* enter account number";
        }
        if (value.trim().isEmpty) {
          return "* enter account number";
        }

        if (bankAccountError != null) {
          return bankAccountError;
        }
        return null;
      },
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "bank-card"),
          fit: BoxFit.cover,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19,
            maxLengthEnforcement:
                MaxLengthEnforcement.truncateAfterCompositionEnds),
      ],
    );
  }

  Widget bankName() {
    return InputFormField(
      label: 'Bank',
      controller: bankNameController,
      validator: (value) {
        if (value == null) {
          return "* select bank";
        }
        if (value.trim().isEmpty) {
          return "* select bank";
        }
        return null;
      },
      onRedirect: () async {
        final bank = await showModalBottomSheet<Bank?>(
          isScrollControlled: true,
          enableDrag: true,
          useSafeArea: false,
          isDismissible: false,
          backgroundColor: ColorManager.background,
          context: context,
          builder: (context) => const SearchBankSheet(),
        );
        setState(() => this.bank = bank);
        return bank?.name;
      },
      showtrailingIcon: true,
      onSaved: (value) {},
      readOnly: true,
      inputType: TextInputType.name,
      inputFormatters: [
        UpperCaseTextFormatter(),
      ],
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "bank"),
          fit: BoxFit.cover,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
    );
  }

  Widget button() {
    return CustomButton(
      onPressed: validatePaymentDetails,
      label: "Verify",
      buttonKey: buttonKey,
      usesProvider: true,
    );
  }

  Future<void> validatePaymentDetails() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    setState(() => bankAccountError = null);

    await Future.delayed(const Duration(seconds: 3));

    if (formKey.currentState!.validate() && bank != null) {
      formKey.currentState!.save();
      log(bank!.toJson().toString());
      PaymentMethodDataHolder.bank = bank;

      final validatedBankAccount = await validateAccountNumber();

      // if no error message
      if (validatedBankAccount == null) {
        // by now, account name would have been saved.
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

        final paymentMethod = PaymentMethodDataHolder.toPaymentMethod();
        Navigator.pop(context, paymentMethod);
        PaymentMethodDataHolder.clear();
      } else {
        // We show bank account error
        setState(() => bankAccountError = validatedBankAccount);
        await Future.delayed(const Duration(seconds: 1));
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        formKey.currentState!.validate();
      }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }

  Future<String?> validateAccountNumber() async {
    final response = await BankRepository.verifyBankAccount(
        accountNo: PaymentMethodDataHolder.accountNumber!,
        bank: PaymentMethodDataHolder.bank!);
    log(response.body);
    log(response.code.toString());

    if (response.error || (response.messageBody?.isEmpty ?? false)) {
      return "Account not found";
    }

    PaymentMethodDataHolder.name =
        response.messageBody!["data"]["account_name"];
    return null;
  }
}
