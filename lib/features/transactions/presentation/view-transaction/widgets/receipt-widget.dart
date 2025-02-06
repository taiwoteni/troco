import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/snackbar-manager.dart';
import '../../../../splash/presentation/splash-screen.dart';
import '../../../domain/entities/transaction.dart';

class ReceiptWidget extends StatefulWidget {
  final Transaction transaction;
  const ReceiptWidget({super.key, required this.transaction});

  @override
  State<ReceiptWidget> createState() => _ReceiptWidgetState();
}

class _ReceiptWidgetState extends State<ReceiptWidget> {
  late Transaction transaction;

  @override
  void initState() {
    transaction = widget.transaction;
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        SnackbarManager.showBasicSnackbar(
            context: context, message: "Receipt saved to storage.");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.maxFinite,
      height: double.maxFinite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          watermark(),
          details(),
        ],
      ),
    );
  }

  Widget watermark() {
    return SizedBox.fromSize(
      size: const Size.square(double.maxFinite),
      child: Transform.rotate(
        angle: 315.0,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(ColorManager.tertiary, BlendMode.srcIn),
          child: Image.asset(
            AssetManager.imageFile(name: "troco-white", ext: Extension.png),
            width: SplashScreen.receiptViewWatermarkWidth,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }

  Widget details() {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: EdgeInsets.symmetric(
          horizontal: SplashScreen.receiptViewHorizontalMargin),
      child: Column(
        children: [
          Gap(SplashScreen.receiptViewInsetsTop),
          extraLargeSpacer(),
          header(),
          mediumSpacer(),
          timeText(),
          extraLargeSpacer(),
          mediumSpacer(),
          detailItem(
              title: "Transaction Reference",
              information: transaction.transactionId.constantCase),
          divider(),
          detailItem(
              title: "Transaction Name",
              information: transaction.transactionName),
          divider(),
          detailItem(
              title: "Transaction Description",
              information: transaction.transactionDetail),
          divider(),
          detailItem(
              title: "Transaction Type",
              information:
                  "${transaction.transactionCategory.name} Transaction"),
          divider(),
          detailItem(
              title:
                  "Total ${transaction.transactionCategory == TransactionCategory.Virtual ? "Virtual-Service" : transaction.transactionCategory.name}(s)",
              information: transaction.salesItem.length.toString()),
          divider(),
          detailItem(
              title: "Transaction Amount",
              information: "${transaction.transactionAmountString} NGN"),
          divider(),
          detailItem(
              title: "Escrow Charges",
              information: "${transaction.escrowChargesString} NGN"),
          divider(),
          detailItem(
              title:
                  transaction.transactionCategory == TransactionCategory.Service
                      ? "Developer"
                      : "Seller",
              information: transaction.sellerName),
          divider(),
          detailItem(
              title:
                  transaction.transactionCategory == TransactionCategory.Service
                      ? "Client"
                      : "Buyer",
              information: transaction.buyerName),
          divider(),
          detailItem(
              title: "Transaction Status",
              information: transaction.transactionStatus.name)
        ],
      ),
    );
  }

  Widget logo() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Image.asset(
        AssetManager.imageFile(name: "troco", ext: Extension.png),
        width: 145,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget header() {
    return Text(
      "Transaction Receipt",
      style: TextStyle(
        color: ColorManager.accentColor,
        fontFamily: 'lato',
        fontSize: FontSizeManager.medium * 1.2,
        fontWeight: FontWeightManager.bold,
      ),
    );
  }

  Widget timeText() {
    final defaultStyle = TextStyle(
        color: ColorManager.secondary,
        fontSize: FontSizeManager.regular * .9,
        fontWeight: FontWeightManager.regular,
        fontFamily: 'lato');

    return RichText(
        text: TextSpan(style: defaultStyle, children: [
      const TextSpan(text: "Generated on "),
      TextSpan(
          style: defaultStyle.copyWith(
              color: Colors.black, fontWeight: FontWeightManager.bold),
          text: DateFormat("EEEE, MMM dd, yyyy").format(DateTime.now()))
    ]));
  }

  Widget detailItem(
      {required final String title, required final String information}) {
    return Container(
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: ColorManager.primary,
                fontFamily: 'quicksand',
                height: 1.4,
                fontWeight: FontWeightManager.extrabold,
                fontSize: FontSizeManager.medium * 0.7),
          ),
          largeSpacer(),
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: Text(
                information,
                textAlign: TextAlign.left,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    color: ColorManager.accentColor,
                    fontFamily: 'quicksand',
                    height: 1.4,
                    fontWeight: FontWeightManager.extrabold,
                    fontSize: FontSizeManager.medium * 0.7),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeManager.medium),
      child: Divider(
        color: ColorManager.secondary.withOpacity(0.09),
      ),
    );
  }
}
