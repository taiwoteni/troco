import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/texts/outputs/info-text.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/wallet/domain/entities/wallet-transaction.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/images/svg.dart';
import '../../../settings/presentation/settings-page/widget/settings-header-clipper.dart';
import '../../../transactions/utils/enums.dart';
import '../../utils/enums.dart';

class WalletTransactionScreen extends StatefulWidget {
  final WalletTransaction walletTransaction;
  const WalletTransactionScreen({super.key, required this.walletTransaction});

  @override
  State<WalletTransactionScreen> createState() =>
      _WalletTransactionScreenState();
}

class _WalletTransactionScreenState extends State<WalletTransactionScreen> {
  late Color transactionColor;
  late WalletTransaction walletTransaction;
  late bool isWithdraw;

  @override
  void initState() {
    walletTransaction = widget.walletTransaction;
    isWithdraw = walletTransaction.transactionPurpose == WalletPurpose.Withdraw;
    transactionColor = isWithdraw ? Colors.red : ColorManager.accentColor;
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        SystemChrome.setSystemUIOverlayStyle(
            ThemeManager.getWalletUiOverlayStyle());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            header(),
            largeSpacer(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.large),
              child: Text(
                walletTransaction.transactionName,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: 'quicksand',
                    fontWeight: FontWeightManager.extrabold,
                    fontSize: FontSizeManager.medium),
              ),
            ),
            mediumSpacer(),
            largeSpacer(),
            detail(
                title: 'Transaction Type',
                value: walletTransaction.transactionPurpose.name),
            mediumSpacer(),
            divider(),
            largeSpacer(),
            detail(
                title: "Transaction Status",
                value: walletTransaction.transactionStatus !=
                        TransactionStatus.Completed
                    ? (walletTransaction.transactionStatus ==
                            TransactionStatus.Cancelled
                        ? "Declined"
                        : "Pending")
                    : walletTransaction.transactionPurpose !=
                            WalletPurpose.Income
                        ? "Withdraw Paid"
                        : "Income Credited",
                color: walletTransaction.transactionStatus ==
                        TransactionStatus.Cancelled
                    ? Colors.red
                    : walletTransaction.transactionStatus ==
                            TransactionStatus.Completed
                        ? ColorManager.accentColor
                        : ColorManager.secondary),
            mediumSpacer(),
            divider(),
            largeSpacer(),
            detail(
                title: "Transaction Date",
                value: DateFormat("MMM d, yyyy 'at' hh:mm a")
                    .format(walletTransaction.timeToSort)),
            mediumSpacer(),
            divider(),
            largeSpacer(),
            detail(
                title: "Transaction Amount",
                price: true,
                value: walletTransaction.transactionAmountString),
            extraLargeSpacer(),
            InfoText(
              text: "ID: #${walletTransaction.transactionId}",
              alignment: Alignment.center,
              color: ColorManager.secondary,
              onPressed: () =>
                  FlutterClipboard.copy(walletTransaction.transactionId),
            ),
            extraLargeSpacer(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return ClipPath(
      clipper: SettingsHeaderClipper(),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 3.5 +
            MediaQuery.of(context).viewPadding.top +
            SizeManager.large,
        color: ColorManager.tertiary,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                child: Container(
              width: IconSizeManager.extralarge * 1.5,
              height: IconSizeManager.extralarge * 1.5,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: transactionColor.withOpacity(0.2)),
              child: SvgIcon(
                angle: isWithdraw ? 225 : 90,
                svgRes: AssetManager.svgFile(name: "plane"),
                color: transactionColor,
                size: const Size.square(IconSizeManager.large),
              ),
            )),
            Positioned(
              bottom:
                  MediaQuery.of(context).viewPadding.top + SizeManager.large,
              left: MediaQuery.of(context).size.width * .2,
              right: MediaQuery.of(context).size.width * .2,
              child: Text(
                "${isWithdraw ? "Withdraw" : "Income"} Transaction",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.large * 0.9,
                    color: ColorManager.primary,
                    fontWeight: FontWeightManager.bold),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).viewPadding.top / 2 +
                    SizeManager.regular,
                left: SizeManager.medium,
                child: IconButton(
                    onPressed: () => context.pop(),
                    icon: SvgIcon(
                      svgRes: AssetManager.svgFile(name: 'back'),
                      color: ColorManager.primary,
                      size: const Size.square(IconSizeManager.medium * 1.1),
                    )))
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
      child: Divider(
        color: ColorManager.secondary.withOpacity(0.09),
      ),
    );
  }

  Widget detail(
      {required String title,
      required String value,
      Color? color,
      bool price = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'quicksand',
                height: 1.4,
                fontWeight: FontWeightManager.extrabold,
                fontSize: FontSizeManager.medium * 0.8),
          ),
          Text(
            price ? "${isWithdraw ? "- " : "+ "}$value NGN" : value,
            textAlign: TextAlign.left,
            style: price
                ? TextStyle(
                    color: transactionColor,
                    fontFamily: 'Lato',
                    fontSize: FontSizeManager.medium,
                    fontWeight: FontWeightManager.extrabold)
                : TextStyle(
                    color: color ?? ColorManager.primary,
                    fontFamily: 'quicksand',
                    height: 1.4,
                    fontWeight: FontWeightManager.extrabold,
                    fontSize: FontSizeManager.medium * 0.8),
          ),
        ],
      ),
    );
  }
}
