// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';

class SelectPaymentProfileWidget extends StatefulWidget {
  bool selected;
  final void Function() onChecked;
  final PaymentMethod method;

  SelectPaymentProfileWidget(
      {super.key,
      required this.selected,
      required this.onChecked,
      required this.method});

  @override
  State<SelectPaymentProfileWidget> createState() =>
      _SelectPaymentMethodWidgetState();
}

class _SelectPaymentMethodWidgetState extends State<SelectPaymentProfileWidget> {
  late PaymentMethod method;
  bool isCard = false;

  @override
  void initState() {
    method = widget.method;
    isCard = method is CardMethod;
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeManager.regular),
        splashColor: ColorManager.accentColor.withOpacity(0.1),
        onTap: () {
          widget.onChecked();
        },
        child: Container(
          width: double.maxFinite,
          height: 95,
          decoration: BoxDecoration(
              color: widget.selected
                  ? ColorManager.accentColor.withOpacity(0.05)
                  : ColorManager.background,
              border: Border.all(
                  color: widget.selected
                      ? ColorManager.accentColor
                      : ColorManager.secondary.withOpacity(0.09),
                  width: 2),
              borderRadius: BorderRadius.circular(SizeManager.regular)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                isCard? cardName(): (method as AccountMethod).accountNumber,
                style: TextStyle(
                    fontFamily: "quicksand",
                    color: ColorManager.primary,
                    fontSize: FontSizeManager.regular,
                    fontWeight: FontWeightManager.semibold),
              ),
              Text(
                isCard? (method as CardMethod).cardType.name: (method as AccountMethod).bankName,
                style: TextStyle(
                    fontFamily: "quicksand",
                    color: ColorManager.secondary,
                    fontSize: FontSizeManager.small,
                    fontWeight: FontWeightManager.semibold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String cardName(){
    final card = method as CardMethod;
    return "".padRight(card.cardNumber.length-4, "*") + card.cardNumber.substring(card.cardNumber.length-4);

  }
}
