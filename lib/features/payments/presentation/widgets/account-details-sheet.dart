// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/payments/data/models/payment-method-dataholder.dart';
import 'package:troco/features/payments/utils/uppercase-input-formatter.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/drag-handle.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../../core/components/texts/inputs/text-form-field.dart';

class AddAccountDetails extends ConsumerStatefulWidget {
  const AddAccountDetails({super.key});

  @override
  ConsumerState<AddAccountDetails> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<AddAccountDetails> {
  bool loading = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
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
      inputType: TextInputType.number,
      onSaved: (value) {
        PaymentMethodDataHolder.accountNumber = value;
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
      label: 'Bank Name',
      validator: (value) {
        if (value == null) {
          return "* enter valid bank";
        }
        if (value.trim().isEmpty) {
          return "* select valid bank";
        }
        return null;
      },
      showtrailingIcon: true,
      onSaved: (value) {
        PaymentMethodDataHolder.bank = value;
      },
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
    await Future.delayed(const Duration(seconds: 3));
    if (Random().nextBool()) {
      formKey.currentState!.save();
      PaymentMethodDataHolder.name = "Teninlanimi David Taiwo";
      PaymentMethodDataHolder.bank = "Access Bank";
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      final paymentMethod = PaymentMethodDataHolder.toPaymentMethod();
      Navigator.pop(context, paymentMethod);
      PaymentMethodDataHolder.clear();
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
