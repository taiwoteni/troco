// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/payments/data/models/payment-method-dataholder.dart';
import 'package:troco/features/payments/utils/card-month-input-formatter.dart';
import 'package:troco/features/payments/utils/uppercase-input-formatter.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/drag-handle.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../../core/components/texts/inputs/text-form-field.dart';
import '../../domain/entity/card-method.dart';
import '../../utils/card-number-input-formatter.dart';
import '../../utils/card-utils.dart';
import '../../utils/enums.dart';

class AddCardDetails extends ConsumerStatefulWidget {
  final CardMethod? card;
  const AddCardDetails({super.key, this.card});

  @override
  ConsumerState<AddCardDetails> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<AddCardDetails> {
  bool loading = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  CardType cardType = CardType.Invalid;

  late TextEditingController cardNumberController,cardNameController,expDateController,cvvController;

  @override
  void initState() {
    cardNameController = TextEditingController(text: widget.card?.cardHolderName ?? "");
    cardNumberController = TextEditingController(text: widget.card?.cardNumber ?? "");
    expDateController = TextEditingController(text: widget.card?.expDate ?? "");
    cvvController = TextEditingController(text: widget.card?.cvv ?? "");

    getCardTypeFrmNumber(cardNumberController.text);
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
              cardNumber(),
              mediumSpacer(),
              cardHolderName(),
              mediumSpacer(),
              rest(),
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
            "Add Card Details",
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

  Widget cardNumber() {
    return InputFormField(
      label: 'Card Number',
      controller: cardNumberController,
      inputType: TextInputType.number,
      validator: (value)=> CardUtils.validateCardNum(value, widget.card != null),
      onSaved: (value) {
        PaymentMethodDataHolder.cardNumber = value;
      },
      onChanged: (value) {
        getCardTypeFrmNumber(value);
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
      suffixIcon: cardType == CardType.Invalid
          ? IconButton(
              onPressed: null,
              iconSize: IconSizeManager.regular,
              icon: SvgIcon(
                svgRes: AssetManager.svgFile(name: "card"),
                fit: BoxFit.cover,
                color: ColorManager.secondary,
                // size: const Size.square(IconSizeManager.regular),
              ),
            )
          : cardTypeIcon(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19,
            maxLengthEnforcement:
                MaxLengthEnforcement.truncateAfterCompositionEnds),
        CardNumberInputFormatter(),
      ],
    );
  }

  Widget cardHolderName() {
    return InputFormField(
      label: 'Cardholder Name',
      controller: cardNameController,
      validator: (value) {
        if (value == null) {
          return "* enter name";
        }
        if (value.trim().isEmpty) {
          return "* enter name";
        }
        return null;
      },
      onSaved: (value) {
        PaymentMethodDataHolder.name = value;
      },
      inputType: TextInputType.name,
      inputFormatters: [
        UpperCaseTextFormatter(),
      ],
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "person"),
          fit: BoxFit.cover,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
    );
  }

  Widget cvv() {
    return InputFormField(
      label: 'CVC',
      controller: cvvController,
      inputType: TextInputType.number,
      validator: (value) {
        if (value == null) {
          return "* missing cvc";
        }
        if (value.trim().isEmpty) {
          return "* missing cvc";
        }
        if (value.trim().length < 3) {
          return "* enter valid cvc";
        }
        return null;
      },
      onSaved: (value) {
        PaymentMethodDataHolder.cvv = value;
      },
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "cvv"),
          fit: BoxFit.cover,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(3,
            maxLengthEnforcement:
                MaxLengthEnforcement.truncateAfterCompositionEnds),
      ],
    );
  }

  Widget monthYear() {
    return InputFormField(
      label: 'MM/YY',
      controller: expDateController,
      inputType: TextInputType.number,
      validator: CardUtils.validateDate,
      onSaved: (value) {
        PaymentMethodDataHolder.expDate = value;
      },
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "calendar"),
          fit: BoxFit.cover,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4,
            maxLengthEnforcement:
                MaxLengthEnforcement.truncateAfterCompositionEnds),
        CardMonthInputFormatter(),
      ],
    );
  }

  Widget rest() {
    return Row(
      children: [
        Expanded(child: cvv()),
        largeSpacer(),
        Expanded(child: monthYear())
      ],
    );
  }

  void getCardTypeFrmNumber(String card) {
    if (card.length <= 6) {
      String input = CardUtils.getCleanedNumber(card);
      CardType type = CardUtils.getCardTypeFrmNumber(input);
      if (type != cardType) {
        setState(() {
          cardType = type;
        });
      }
    }
  }

  Widget button() {
    return CustomButton(
      onPressed: validatePaymentDetails,
      label: "Verify",
      buttonKey: buttonKey,
      usesProvider: true,
    );
  }

  Widget cardTypeIcon() {
    return IconButton(
      onPressed: null,
      iconSize: IconSizeManager.regular,
      icon: SvgIcon(
        svgRes: CardUtils.getCardIcon(type: cardType),
        fit: BoxFit.cover,
        size: const Size.square(IconSizeManager.regular * 1.8),
      ),
    );
  }

  Future<void> validatePaymentDetails() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      final paymentMethod = PaymentMethodDataHolder.toPaymentMethod();
      Navigator.pop(context, paymentMethod);
      PaymentMethodDataHolder.clear();
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
