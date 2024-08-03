import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/wallet/presentation/widgets/wallet-transaction-item-widget.dart';
import 'package:troco/features/wallet/data/models/wallet-menu-item-model.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../core/app/routes-manager.dart';
import '../../../groups/presentation/collections_page/widgets/empty-screen.dart';
import '../../domain/entities/wallet-transaction.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late List<WalletTransaction> walletHistory;
  @override
  void initState() {
    walletHistory = [];
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
    const padding = EdgeInsets.only(
        right: SizeManager.medium,
        left: SizeManager.medium,
        bottom: SizeManager.bottomBarHeight);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: walletHistory.isEmpty
            ? Container(
                width: double.maxFinite,
                height: double.maxFinite,
                padding: padding,
                child: body())
            : SingleChildScrollView(padding: padding, child: body()));
  }

  Widget body() {
    return Column(children: [
      appBar(),
      extraLargeSpacer(),
      menu(),
      extraLargeSpacer(),
      if (walletHistory.isNotEmpty)
        transactionWidget()
      else
        EmptyScreen(
          expanded: true,
          lottie: AssetManager.lottieFile(name: "empty-transactions"),
          scale: 1.2,
          label: "No Wallet Transactions so far.",
        )
    ]);
  }

  Widget appBar() {
    final NumberFormat formatter = NumberFormat.currency(
        locale: 'en_NG',
        // symbol: '₦',
        symbol: '',
        decimalDigits: 0);
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
        child: Stack(children: [
          Positioned(
              top: -boxWidth / 2.5 / 3.5,
              right: -boxWidth / 2.5 / 3.5,
              child: Container(
                  width: boxWidth / 2.5,
                  height: boxWidth / 2.5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2)))),
          Positioned(
              top: 0,
              bottom: 0,
              right: -boxWidth / 2.5 / 2,
              child: Container(
                  width: boxWidth / 2.5,
                  height: boxWidth / 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.4)))),
          SizedBox(
              height: double.maxFinite,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mediumSpacer(),
                    Text(
                        "${ref.watch(ClientProvider.userProvider)!.fullName} -",
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato',
                            fontSize: FontSizeManager.medium * 0.9,
                            fontWeight: FontWeightManager.medium)),
                    const Spacer(),
                    AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) {
                          return RichText(
                              text: TextSpan(style: defaultStyle, children: [
                            TextSpan(
                                text: formatter.format(controller.value *
                                    ref.watch(clientProvider)!.walletBalance)),
                            TextSpan(
                                text: ".00",
                                style: defaultStyle.copyWith(
                                    fontSize: FontSizeManager.large,
                                    color: Colors.white.withOpacity(0.4))),
                            const TextSpan(text: " NGN")
                          ]));
                        }),
                    regularSpacer(),
                    const Text("+15% 0 NGN",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Lato',
                            fontSize: FontSizeManager.medium * 0.9,
                            fontWeight: FontWeightManager.semibold)),
                    const Spacer(),
                    Text("#${ClientProvider.readOnlyClient!.referralCode}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Quicksand',
                            fontSize: FontSizeManager.medium * 0.8,
                            fontWeight: FontWeightManager.regular))
                  ]))
        ]));
  }

  Widget menu() {
    return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: IconSizeManager.extralarge * 1.2,
            childAspectRatio: 0.8,
            mainAxisSpacing: SizeManager.regular * 1.2,
            crossAxisSpacing: SizeManager.regular * 0.8),
        itemCount: menuItems().length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final item = menuItems()[index];
          return InkWell(
              onTap: () {
                if (item.onClick != null) {
                  item.onClick!();
                  return;
                }
                SnackbarManager.showBasicSnackbar(
                    context: context, message: "Coming in next update");
              },
              child: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        (ColorManager.accentColor).withOpacity(0.12),
                        (ColorManager.accentColor).withOpacity(0.25)
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius:
                          BorderRadius.circular(SizeManager.small * 1.1)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIcon(
                            svgRes: item.svgRes,
                            color: ColorManager.accentColor,
                            size: const Size.square(
                                IconSizeManager.medium * 0.9)),
                        smallSpacer(),
                        Text(item.label,
                            style: const TextStyle(
                                fontFamily: 'Lato',
                                fontWeight: FontWeightManager.medium,
                                fontSize: FontSizeManager.small * 0.85))
                      ])));
        });
  }

  List<WalletMenuItemModel> menuItems() {
    return [
      // WalletMenuItem(
      // svgRes: AssetManager.svgFile(name: 'wallet'), label: "Fund"),
      WalletMenuItemModel(
          svgRes: AssetManager.svgFile(name: 'withdraw'),
          label: "Withdraw",
          onClick: () => Navigator.pushNamed(context, Routes.withdrawRoute),
          color: Colors.red),
      WalletMenuItemModel(
          onClick: () => Navigator.pushNamed(context, Routes.viewContacts),
          svgRes: AssetManager.svgFile(name: 'invite'),
          label: "Refer",
          color: Colors.orange),
      WalletMenuItemModel(
          svgRes: AssetManager.svgFile(name: 'wallet'),
          label: "History",
          onClick: () => Navigator.pushNamed(context, Routes.walletHistoryRoute),
          color: Colors.indigo),
      WalletMenuItemModel(
          svgRes: AssetManager.svgFile(name: 'group'),
          label: "Referred",
          onClick: () => Navigator.pushNamed(context, Routes.referredRoute),
          )
      // WalletMenuItem(
      // svgRes: AssetManager.svgFile(name: 'withdraw')
      // label: "Transfer",
      // color: Colors.cyan),
      // WalletMenuItem(
      // svgRes: AssetManager.svgFile(name: 'settings'),
      // label: "Settings",
      // color: Colors.purple),

      // WalletMenuItem(
      // svgRes: AssetManager.svgFile(name: 'invite'), label: "Refer"),
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
          Row(children: [
            Text("Transactions",
                style: defaultStyle, textAlign: TextAlign.start),
            const Spacer(),
            TextButton(
                onPressed: null,
                child: Text('View All',
                    style: defaultStyle.copyWith(
                        fontSize: FontSizeManager.regular,
                        color: ColorManager.accentColor,
                        fontWeight: FontWeightManager.semibold,
                        fontFamily: 'Quicksand')))
          ]),
          ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.small),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => Column(
                    children: [
                      WalletTransactionWidget(
                          transaction: walletHistory[index]),
                      if (index == 2 || index == walletHistory.last)
                        const Gap(SizeManager.bottomBarHeight)
                    ],
                  ),
              separatorBuilder: (context, index) => Divider(
                  thickness: 0.8,
                  color: ColorManager.secondary.withOpacity(0.08)),
              itemCount: walletHistory.length >= 3 ? 3 : walletHistory.length)
        ]);
  }
}
