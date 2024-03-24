import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/data/converters.dart';
import 'package:troco/data/enums.dart';
import 'package:troco/models/transaction.dart';

class TransactionItemWidget extends StatelessWidget {
  final Transaction transaction;
  const TransactionItemWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isBuying = transaction.transactionPurpose == TransactionPurpose.Buying;
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
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.9),
                ])),
        child: ListTile(
          dense: true,
          tileColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SizeManager.medium,
            vertical: SizeManager.regular * 0.7,
          ),
          horizontalTitleGap: SizeManager.large,
          title: Text(transaction.transactionDetail),
          titleTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium,
              fontWeight: FontWeightManager.semibold),
          subtitle: Text(TransactionConverter.convertToStringStatus(
              status: transaction.transactionStatus)),
          subtitleTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontSize: FontSizeManager.regular,
              fontWeight: FontWeightManager.regular),
          leading: SvgIcon(
            svgRes: AssetManager.svgFile(name: isBuying ? "buy" : "delivery"),
            color: Colors.white,
            size: const Size.square(IconSizeManager.regular),
          ),
          trailing: Text("$formattedNumber NG"),
          leadingAndTrailingTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.large * 0.8,
              fontWeight: FontWeightManager.bold),
        ),
      ),
    );
  }
}
