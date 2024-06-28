import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:troco/features/payments/presentation/widgets/payment-method-actions-dialog.dart';
import 'package:troco/features/payments/utils/card-utils.dart';
import 'package:recase/recase.dart';

class PaymentCard extends StatelessWidget {
  final PaymentMethod method;
  final MaterialColor? primary;
  final Color? secondary;
  const PaymentCard(
      {super.key, required this.method, this.primary, this.secondary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showActions(context),
      child: method is AccountMethod
          ? accountPaymentWidget()
          : cardPaymentWidget(),
    );
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
          gradient: LinearGradient(colors: [
            primary ?? ColorManager.accentColor,
            secondary ?? ColorManager.themeColor
          ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
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

  Future<void> showActions(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => PaymentMethodAction(method: method),
    );
  }

  Widget accountPaymentWidget() {
    final account = method as AccountMethod;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          vertical: SizeManager.medium * 1.3,
          horizontal: SizeManager.large * 1.1),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.medium),
          gradient: LinearGradient(colors: [
            primary ?? ColorManager.accentColor,
            secondary ?? ColorManager.themeColor
          ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.bank.name.titleCase,
                style: const TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.medium,
                    color: Colors.white,
                    fontWeight: FontWeightManager.bold),
              ),
              if (account.bank.logo != null)
                CachedNetworkImage(
                  imageUrl: account.bank.logo!,
                  fadeInCurve: Curves.ease,
                  color: Colors.white,
                  fadeInDuration: const Duration(milliseconds: 650),
                  width: IconSizeManager.medium * 1.5,
                  height: IconSizeManager.medium * 1.5,
                  fit: BoxFit.cover,
                )
              else
                const SizedBox.square(dimension: IconSizeManager.medium * 1.5)
            ],
          ),
          smallSpacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Bank Name",
                style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.small * 0.8,
                    color: Colors.white,
                    fontWeight: FontWeightManager.regular),
              ),
            ],
          ),
          mediumSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                account.accountNumber
                    .substring(account.accountNumber.length - 4)
                    .padLeft(account.accountNumber.length, '*'),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Account Name",
                style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.small * 0.8,
                    color: Colors.white,
                    fontWeight: FontWeightManager.regular),
              ),
            ],
          ),
          regularSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                account.accountName.titleCase.length >= 26
                    ? account.accountName.titleCase
                        .replaceRange(23, null, '...')
                    : account.accountName.titleCase,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: true,
                style: const TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.medium,
                    color: Colors.white,
                    fontWeight: FontWeightManager.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}
