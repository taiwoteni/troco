import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/data/enums.dart';
import 'package:troco/models/transaction.dart';

class WalletTransactionWidget extends StatelessWidget {
  final Transaction transaction;
  const WalletTransactionWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isDebit = transaction.transactionPurpose == TransactionPurpose.Buying;
    Color color = transaction.transactionPurpose == TransactionPurpose.Buying
        ? Colors.deepOrange
        : ColorManager.accentColor;
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_NG',
      // symbol: '₦',
      symbol: '',
      decimalDigits: 0,
    );

    final String formattedNumber =
        formatter.format(transaction.transactionAmount);
    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeManager.medium),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.medium),
          // gradient: LinearGradient(
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     colors: [
          //       color.withOpacity(0.8),
          //       color.withOpacity(0.9),
          //     ]),
        ),
        child: ListTile(
          dense: true,
          tileColor: Colors.transparent,
          contentPadding: const EdgeInsets.only(
            left: 0,
            right: SizeManager.medium,
            top: SizeManager.small,
            bottom: SizeManager.small,
          ),
          horizontalTitleGap: SizeManager.medium * 0.5,
          title: Text(
            transaction.transactionDetail,
            overflow: TextOverflow.ellipsis,
          ),
          titleTextStyle: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium,
              fontWeight: FontWeightManager.semibold),
          subtitle: const Text("25 Mar 2024 - 21:19 PM"),
          subtitleTextStyle: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Quicksand',
              fontSize: FontSizeManager.regular,
              fontWeight: FontWeightManager.regular),
          leading: Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withOpacity(0.2)),
            child: SvgIcon(
              angle: isDebit ? 225 : 90,
              svgRes: AssetManager.svgFile(name: "plane"),
              color: color,
              size: const Size.square(IconSizeManager.regular),
            ),
          ),
          trailing: Text("${isDebit ? "-" : "+"}$formattedNumber NG"),
          leadingAndTrailingTextStyle: TextStyle(
              color: color,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium * 0.8,
              fontWeight: FontWeightManager.bold),
        ),
      ),
    );
  }
}
