// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';

import '../../../transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import '../../../transactions/utils/enums.dart';
import '../../../transactions/utils/transaction-status-converter.dart';

class TransactionItemWidget extends ConsumerWidget {
  final Transaction transaction;
  final bool? fromDarkStatusBar;
  const TransactionItemWidget({super.key, required this.transaction, this.fromDarkStatusBar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isBuying = transaction.transactionPurpose == TransactionPurpose.Buying;
    Color color = transaction.transactionPurpose == TransactionPurpose.Buying
        ? Colors.deepOrange
        : ColorManager.accentColor;

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
          onTap: () async {
            await Future.delayed(const Duration(microseconds: 4));
            ref.watch(currentTransactionProvider.notifier).state = transaction;
            await Navigator.pushNamed(context, Routes.viewTransactionRoute,
                arguments: transaction);
            if(fromDarkStatusBar??false){
              SystemChrome.setSystemUIOverlayStyle(ThemeManager.getSettingsUiOverlayStyle());
            }    
          },
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
          subtitle: Text(TransactionStatusConverter.convertToStringStatus(
              status: transaction.transactionStatus)),
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
              svgRes: AssetManager.svgFile(name: isBuying ? "buy" : "delivery"),
              color: color,
              size: const Size.square(IconSizeManager.regular),
            ),
          ),
          trailing: Text(transaction.transactionAmount.toInt() == 0
              ? "FREE"
              : "${transaction.transactionAmountString} NG"),
          leadingAndTrailingTextStyle: TextStyle(
              color:
                  transaction.transactionPurpose == TransactionPurpose.Selling
                      ? ColorManager.accentColor
                      : Colors.redAccent,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium * 0.8,
              fontWeight: FontWeightManager.bold),
        ),
      ),
    );
  }
}
