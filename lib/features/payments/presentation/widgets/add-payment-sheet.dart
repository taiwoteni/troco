import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/payments/utils/card-month-input-formatter.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/drag-handle.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../../core/components/texts/inputs/text-form-field.dart';
import '../../utils/card-number-input-formatter.dart';
import '../../utils/card-utils.dart';
import '../../utils/enums.dart';

class AddPaymentSheet extends StatefulWidget {
  const AddPaymentSheet({super.key});

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet> {
  bool loading = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  CardType cardType = CardType.Invalid;

  @override
  void initState() {
    getCardTypeFrmNumber("");
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
            "Add Payment Method",
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
      validator: (value) {
        if (value == null) {
          return "* enter an account number";
        }
        if (value.trim().isEmpty) {
          return "* enter an account number";
        }
        if (value.trim().length <= 4) {
          return "* enter a valid account number";
        }
        return null;
      },
      onSaved: (value) {},
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

  Widget bankName() {
    return InputFormField(
      label: 'Bank Name',
      showtrailingIcon: true,
      validator: (value) {
        if (value == null) {
          return "* select a bank";
        }
        if (value.trim().isEmpty) {
          return "* select a bank";
        }
        return null;
      },
      onSaved: (value) {},
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

  Widget cvv() {
    return InputFormField(
      label: 'CVC',
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
      onSaved: (value) {},
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
      inputType: TextInputType.number,
      validator: (value) {
        if (value == null) {
          return "* missing date";
        }
        if (value.trim().isEmpty) {
          return "* missing date";
        }
        if (value.trim().length < 5) {
          return "* enter valid cvc";
        }
        return null;
      },
      onSaved: (value) {},
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
}
