// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/domain/entity/card-method.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';
import 'package:troco/features/payments/utils/card-utils.dart';

import '../../../../core/components/animations/lottie.dart';
import '../../../../core/components/others/spacer.dart';

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

class _SelectPaymentMethodWidgetState
    extends State<SelectPaymentProfileWidget> {
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
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () {
        widget.onChecked();
      },
      child: Container(
        width: double.maxFinite,
        height: 95,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
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
        child: Row(
          children: [
            Transform.scale(
              scale: 1.2,
              child: LottieWidget(
                lottieRes: AssetManager.lottieFile(
                    name: isCard ? "card-payment" : "bank-payment"),
                size: const Size.square(IconSizeManager.medium * 1.25),
                loop: !isCard,
              ),
            ),
            extraLargeSpacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCard ? cardName() : (method as AccountMethod).accountNumber,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.primary,
                      fontSize: FontSizeManager.regular,
                      fontWeight: FontWeightManager.semibold),
                ),
                Text(
                  isCard
                      ? (method as CardMethod).cardHolderName
                      : (method as AccountMethod).accountName.length >= 30
                          ? (method as AccountMethod)
                              .accountName
                              .replaceRange(25, null, '...')
                          : (method as AccountMethod).name,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.secondary,
                      overflow: TextOverflow.ellipsis,
                      fontSize: FontSizeManager.small * 0.9,
                      fontWeight: FontWeightManager.semibold),
                ),
              ],
            ),
            const Spacer(),
            isCard
                ? SvgIcon(
                    size: const Size.square(IconSizeManager.large),
                    svgRes: CardUtils.getCardIcon(
                        type: (method as CardMethod).cardType))
                : bankLogo()
          ],
        ),
      ),
    );
  }

  Widget bankLogo() {
    final account = method as AccountMethod;
    return account.bank.logo == null
        ? const SizedBox.square(
            dimension: 0,
          )
        : CachedNetworkImage(
            imageUrl: account.bank.logo!,
            fadeInCurve: Curves.ease,
            fadeInDuration: const Duration(milliseconds: 650),
            width: IconSizeManager.large,
            height: IconSizeManager.large,
            fit: BoxFit.cover,
          );
  }

  String cardName() {
    final card = method as CardMethod;
    final cardNumber = CardUtils.getCleanedNumber(card.cardNumber);
    final ca = "".padRight(cardNumber.length - 4, "*");
    final cb = cardNumber.substring(cardNumber.length - 4);
    return CardUtils.formatCardNumber(ca + cb);
  }
}
