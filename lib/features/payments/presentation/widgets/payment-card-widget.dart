import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/utils/card-utils.dart';
import 'package:recase/recase.dart';

class PaymentCard extends StatelessWidget {
  final PaymentMethod method;
  const PaymentCard({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return method is AccountMethod
        ? accountPaymentWidget()
        : cardPaymentWidget();
  }

  Widget cardPaymentWidget() {
    final card = method as CardMethod;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          vertical: SizeManager.medium * 1.3,
          horizontal: SizeManager.large * 1.1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.medium),
          gradient: LinearGradient(
              colors: [ColorManager.accentColor, ColorManager.themeColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // pin rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgIcon(
                  size: const Size.square(IconSizeManager.medium * 1.3),
                  svgRes: AssetManager.svgFile(name: "card-chip")),
              SvgIcon(
                  size: const Size.square(IconSizeManager.medium * 1.5),
                  svgRes: CardUtils.getCardIcon(type: card.cardType))
            ],
          ),
          mediumSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "****",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'lato',
                  fontWeight: FontWeightManager.extrabold,
                  fontSize: FontSizeManager.extralarge,
                ),
              ),
              const Text(
                "****",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'lato',
                  fontWeight: FontWeightManager.extrabold,
                  fontSize: FontSizeManager.extralarge,
                ),
              ),
              const Text(
                "****",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'lato',
                  fontWeight: FontWeightManager.extrabold,
                  fontSize: FontSizeManager.extralarge,
                ),
              ),
              Text(
                card.cardNumber.substring(card.cardNumber.length - 4),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'lato',
                  fontWeight: FontWeightManager.extrabold,
                  fontSize: FontSizeManager.large,
                ),
              ),
            ],
          ),
          regularSpacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CardHolder Name",
                style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.small * 0.8,
                    color: Colors.white,
                    fontWeight: FontWeightManager.regular),
              ),
              Text(
                "Expiry Date",
                style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.small * 0.8,
                    color: Colors.white,
                    fontWeight: FontWeightManager.medium),
              ),
            ],
          ),
          regularSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.cardHolderName.titleCase,
                style: const TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.medium,
                    color: Colors.white,
                    fontWeight: FontWeightManager.bold),
              ),
              Text(
                card.expDate,
                style: const TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.medium,
                    color: Colors.white,
                    fontWeight: FontWeightManager.extrabold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget accountPaymentWidget() {
    return const SizedBox();
  }
}
