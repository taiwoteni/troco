import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/custom-views/wallet-transaction-item-widget.dart';
import 'package:troco/models/transaction.dart';
import 'package:troco/models/wallet-menu-item.dart';
import 'package:troco/providers/client-provider.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getWalletUiOverlayStyle());
      controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: const EdgeInsets.only(
          right: SizeManager.medium,
          left: SizeManager.medium,
          bottom: SizeManager.bottomBarHeight,
        ),
        child: Column(
          children: [
            appBar(),
            extraLargeSpacer(),
            menu(),
            const Spacer(),
            transactionWidget(),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_NG',
      // symbol: '₦',
      symbol: '',
      decimalDigits: 0,
    );
    final double boxWidth =
        MediaQuery.of(context).size.width - SizeManager.medium * 2;
    TextStyle defaultStyle = const TextStyle(
        fontFamily: "Quicksand",
        color: Colors.white,
        fontSize: FontSizeManager.extralarge * 1.1,
        fontWeight: FontWeightManager.extrabold);
    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top + SizeManager.medium),
      padding: const EdgeInsets.only(
          bottom: SizeManager.medium, left: SizeManager.medium * 1.5),
      height: 200,
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: ColorManager.accentColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(SizeManager.large)),
      child: Stack(
        children: [
          Positioned(
            top: -boxWidth / 2.5 / 3.5,
            right: -boxWidth / 2.5 / 3.5,
            child: Container(
              width: boxWidth / 2.5,
              height: boxWidth / 2.5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: -boxWidth / 2.5 / 2,
            child: Container(
              width: boxWidth / 2.5,
              height: boxWidth / 5,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white.withOpacity(0.4)),
            ),
          ),
          SizedBox(
            height: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mediumSpacer(),
                Text(
                  "${ref.watch(ClientProvider.userProvider)!.businessName} -",
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontSize: FontSizeManager.medium * 0.9,
                      fontWeight: FontWeightManager.medium),
                ),
                const Spacer(),
                AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return RichText(
                          text: TextSpan(style: defaultStyle, children: [
                        TextSpan(
                            text: formatter.format(controller.value * 5000000)),
                        TextSpan(
                            text: ".00",
                            style: defaultStyle.copyWith(
                                fontSize: FontSizeManager.large,
                                color: Colors.white.withOpacity(0.4))),
                        const TextSpan(text: " NGN"),
                      ]));
                    }),
                regularSpacer(),
                const Text(
                  "+15% 5,000 NGN",
                  style: TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'Lato',
                      fontSize: FontSizeManager.medium * 0.9,
                      fontWeight: FontWeightManager.semibold),
                ),
                const Spacer(),
                const Text(
                  "EQC8-fAHU9D-I0KU6G7",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Quicksand',
                      fontSize: FontSizeManager.medium * 0.8,
                      fontWeight: FontWeightManager.regular),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget menu() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: IconSizeManager.extralarge * 1.1,
        childAspectRatio: 0.9,
        mainAxisSpacing: SizeManager.regular * 1.2,
        crossAxisSpacing: SizeManager.regular * 1.2,
      ),
      itemCount: menuItems().length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = menuItems()[index];
        return InkWell(
          onTap: () => log("Hi"),
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
                color: (ColorManager.accentColor).withOpacity(0.2),
                borderRadius: BorderRadius.circular(SizeManager.small)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(
                  svgRes: item.svgRes,
                  color: ColorManager.accentColor,
                  size: const Size.square(IconSizeManager.regular * 1.1),
                ),
                regularSpacer(),
                Text(
                  item.label,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      color: ColorManager.accentColor,
                      fontWeight: FontWeightManager.medium,
                      fontSize: FontSizeManager.small * 0.8),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<WalletMenuItem> menuItems() {
    return [
      // WalletMenuItem(
      //     svgRes: AssetManager.svgFile(name: 'wallet'), label: "Fund"),
      WalletMenuItem(
          svgRes: AssetManager.svgFile(name: 'withdraw'),
          label: "Withdraw",
          color: Colors.red),
      WalletMenuItem(
          svgRes: AssetManager.svgFile(name: 'invite'),
          label: "Refer",
          color: Colors.orange),
      WalletMenuItem(
          svgRes: AssetManager.svgFile(name: 'wallet'),
          label: "History",
          color: Colors.indigo),
      WalletMenuItem(
          svgRes: AssetManager.svgFile(name: 'group'), label: "Referred"),
      // WalletMenuItem(
      //     svgRes: AssetManager.svgFile(name: 'withdraw'),
      //     label: "Transfer",
      //     color: Colors.cyan),
      // WalletMenuItem(
      //     svgRes: AssetManager.svgFile(name: 'settings'),
      //     label: "Settings",
      //     color: Colors.purple),

      // WalletMenuItem(
      //     svgRes: AssetManager.svgFile(name: 'invite'), label: "Refer"),
    ];
  }

  Widget transactionWidget() {
    final defaultStyle = TextStyle(
        fontFamily: 'Lato',
        color: ColorManager.primary,
        fontSize: FontSizeManager.large,
        fontWeight: FontWeightManager.bold);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Transactions",
              style: defaultStyle,
              textAlign: TextAlign.start,
            ),
            const Spacer(),
            TextButton(
                onPressed: null,
                child: Text(
                  'View All',
                  style: defaultStyle.copyWith(
                      fontSize: FontSizeManager.regular,
                      color: ColorManager.accentColor,
                      fontWeight: FontWeightManager.semibold,
                      fontFamily: 'Quicksand'),
                ))
          ],
        ),

        // const EmptyScreen(
        //   expanded: true,
        //   label: "No Transactions\ncurrently taking place.",
        // ),
        ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.small),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => WalletTransactionWidget(
                  transaction: transactions()[index],
                ),
            separatorBuilder: (context, index) => Divider(
                  thickness: 0.8,
                  color: ColorManager.secondary.withOpacity(0.08),
                ),
            itemCount: transactions().length >= 3 ? 3 : transactions().length)
      ],
    );
  }

  List<Transaction> transactions() {
    return [
      const Transaction.fromJson(json: {
        "transaction detail": "Withdrew 50,000 NGN",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 50000.00,
        "transaction status": "Finalizing",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Bought macbook pro",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 100000.00,
        "transaction status": "Pending",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Shipped Tera Batteries",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Selling",
        "transaction amount": 250000.00,
        "transaction status": "Completed",
      }),
    ];
  }
}
