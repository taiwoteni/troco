import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/dialog-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import '../../domain/entities/wallet-transaction.dart';
import '../../utils/enums.dart';

class WalletTransactionWidget extends StatelessWidget {
  final WalletTransaction transaction;
  const WalletTransactionWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isWithdraw =
        transaction.transactionPurpose == WalletPurpose.Withdraw;
    Color color = isWithdraw ? Colors.red : ColorManager.accentColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeManager.medium),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.medium),
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
            transaction.transactionName,
            overflow: TextOverflow.ellipsis,
          ),
          titleTextStyle: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium,
              fontWeight: FontWeightManager.semibold),
          subtitle: Text(transaction.transactionStatus !=
                  TransactionStatus.Completed
              ? (transaction.transactionStatus == TransactionStatus.Cancelled
                  ? "Declined"
                  : "Pending")
              : transaction.transactionPurpose != WalletPurpose.Income
                  ? "Withdraw Paid"
                  : "Income Credited"),
          subtitleTextStyle: TextStyle(
              color: transaction.transactionStatus ==
                      TransactionStatus.Cancelled
                  ? Colors.red
                  : transaction.transactionStatus == TransactionStatus.Completed
                      ? ColorManager.accentColor
                      : ColorManager.secondary,
              fontFamily: 'Quicksand',
              fontSize: FontSizeManager.regular,
              fontWeight:
                  transaction.transactionStatus != TransactionStatus.Pending
                      ? FontWeightManager.semibold
                      : FontWeightManager.regular),
          leading: Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withOpacity(0.2)),
            child: SvgIcon(
              angle: isWithdraw ? 225 : 90,
              svgRes: AssetManager.svgFile(name: "plane"),
              color: color,
              size: const Size.square(IconSizeManager.regular),
            ),
          ),
          trailing: Text(
              "${isWithdraw ? "-" : "+"}${transaction.transactionAmountString} NG"),
          leadingAndTrailingTextStyle: TextStyle(
              color: color,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium * 0.8,
              fontWeight: FontWeightManager.bold),
          onTap: () {
            Navigator.pushNamed(context, Routes.walletTransactionRoute,
                arguments: transaction);
          },
        ),
      ),
    );
  }
}
