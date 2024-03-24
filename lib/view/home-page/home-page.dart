import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/custom-views/profile-icon.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/custom-views/transaction-item-widget.dart';
import 'package:troco/models/client.dart';
import 'package:troco/providers/client-provider.dart';

import 'package:carousel_slider/carousel_slider.dart';

import '../../models/transaction.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late Client client;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSystemUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: SizeManager.medium),
        child: Column(
          children: [
            appBarWidget(),
            largeSpacer(),
            carouselWidget(),
            mediumSpacer(),
            latestTransactionsWidget(),
          ],
        ),
      ),
    );
  }

  Widget appBarWidget() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProfileIcon(
                profile: DecorationImage(
                    image: FileImage(
                        File(ref.watch(ClientProvider.userProvider)!.profile)),
                    fit: BoxFit.cover),
                size: IconSizeManager.medium * 1.3,
              ),
              SvgIcon(
                svgRes: AssetManager.svgFile(name: "bell"),
                color: ColorManager.accentColor,
                size: const Size.square(IconSizeManager.medium),
              )
            ],
          ),
          largeSpacer(),
          nameWidget(),
        ],
      ),
    );
  }

  Widget nameWidget() {
    final defaultStyle = TextStyle(
        fontFamily: 'Quicksand',
        color: ColorManager.secondary,
        height: 1.5,
        fontSize: FontSizeManager.large * 1.1,
        fontWeight: FontWeightManager.medium);
    return RichText(
        textAlign: TextAlign.start,
        text: TextSpan(style: defaultStyle, children: [
          const TextSpan(text: "Good Morning,\n"),
          TextSpan(
              text: "${ref.watch(ClientProvider.userProvider)!.fullName}.",
              style: defaultStyle.copyWith(
                  color: ColorManager.primary,
                  fontWeight: FontWeightManager.semibold))
        ]));
  }

  Widget carouselWidget() {
    const defaultStyle = TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontSize: FontSizeManager.regular * 1.1,
        fontWeight: FontWeightManager.semibold);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeManager.medium * 1.4),
      child: CarouselSlider.builder(
          itemCount: 3,
          itemBuilder: (context, index, realIndex) => Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(
                    vertical: SizeManager.regular,
                    horizontal: SizeManager.medium),
                decoration: BoxDecoration(
                  color: index == 0
                      ? Colors.green
                      : index == 1
                          ? Colors.purple
                          : Colors.red.shade700,
                  borderRadius: BorderRadius.circular(SizeManager.medium),
                ),
                child: Stack(
                  children: [
                    Positioned(
                        bottom: -5,
                        right: -5,
                        child: index == 0
                            ? completeIcon()
                            : index == 1
                                ? ongoingIcon()
                                : cancelIcon()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        regularSpacer(),
                        Text(
                          "${index == 0 ? "Completed" : index == 1 ? "Ongoing" : "Cancelled"} Transactions",
                          style: defaultStyle,
                        ),
                        const Spacer(),
                        Text(
                          "N100,000",
                          style: defaultStyle.copyWith(
                              fontWeight: FontWeightManager.bold,
                              fontSize: FontSizeManager.extralarge * 1.1),
                        ),
                        const Spacer(),
                        mediumSpacer(),
                      ],
                    ),
                  ],
                ),
              ),
          options: CarouselOptions(
            autoPlay: true,
            scrollPhysics: const AlwaysScrollableScrollPhysics(),
            enlargeCenterPage: true,
            viewportFraction: 0.7,
            height: 130,
            autoPlayInterval: const Duration(seconds: 6),
          )),
    );
  }

  Widget cancelIcon() {
    return Icon(
      CupertinoIcons.xmark,
      size: IconSizeManager.extralarge * 1.5,
      color: Colors.white.withOpacity(0.4),
    );
  }

  Widget completeIcon() {
    return Icon(
      CupertinoIcons.checkmark,
      size: IconSizeManager.extralarge * 1.5,
      color: Colors.white.withOpacity(0.4),
    );
  }

  Widget ongoingIcon() {
    return SvgIcon(
      svgRes: AssetManager.svgFile(name: 'transaction'),
      size: const Size.square(IconSizeManager.extralarge * 1.4),
      color: Colors.white.withOpacity(0.4),
    );
  }

  Widget latestTransactionsWidget() {
    final defaultStyle = TextStyle(
        fontFamily: 'Quicksand',
        color: ColorManager.primary,
        fontSize: FontSizeManager.large,
        fontWeight: FontWeightManager.bold);
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latest Transactions",
            style: defaultStyle,
            textAlign: TextAlign.start,
          ),
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => TransactionItemWidget(
                    transaction: transactions()[index],
                  ),
              separatorBuilder: (context, index) => mediumSpacer(),
              itemCount: transactions().length)
        ],
      ),
    );
  }

  List<Transaction> transactions() {
    return [
      const Transaction.fromJson(json: {
        "transaction detail": "selling My Passport Ultra Hard Drive",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Selling",
        "transaction amount": 50000.00,
        "transaction status": "Finalizing",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "buying macbook pro",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 100000.00,
        "transaction status": "Pending",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "shipping Tera Batteries",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Selling",
        "transaction amount": 250000.00,
        "transaction status": "Completed",
      }),
    ];
  }
}
