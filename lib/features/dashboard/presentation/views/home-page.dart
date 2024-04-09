import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/features/auth/data/models/client.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:troco/core/basecomponents/clippers/bottom-rounded.dart';

import '../widgets/transaction-item-widget.dart';
import '../../../transactions/data/model/transaction.dart';

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
          ThemeManager.getHomeUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: const EdgeInsets.only(bottom: SizeManager.bottomBarHeight),
        child: Column(
          children: [
            appBarWidget(),
            mediumSpacer(),
            const Spacer(),
            latestTransactionsWidget(),
          ],
        ),
      ),
    );
  }

  Widget appBarWidget() {
    return SizedBox(
      width: double.maxFinite,
      height: 342,
      child: Stack(
        children: [
          ClipPath(
            clipper: BottomRoundedClipper(),
            child: Container(
              width: double.maxFinite,
              height: 290,
              color: ColorManager.accentColor.withOpacity(0.8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(MediaQuery.of(context).viewPadding.top),
                  mediumSpacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium * 1.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const UserProfileIcon(
                          size: IconSizeManager.medium * 1.3,
                        ),
                        SvgIcon(
                          svgRes: AssetManager.svgFile(name: "bell"),
                          color: ColorManager.primaryDark,
                          size: const Size.square(IconSizeManager.medium),
                        )
                      ],
                    ),
                  ),
                  largeSpacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium * 1.5),
                    child: nameWidget(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(bottom: 0, child: carouselWidget()),
        ],
      ),
    );
  }

  Widget nameWidget() {
    final DateTime dateTime = DateTime.now();
    final String time = dateTime.hour < 12
        ? "Morning"
        : dateTime.hour < 16
            ? "Afternoon"
            : "Evening";
    final defaultStyle = TextStyle(
        fontFamily: 'Quicksand',
        color: ColorManager.background.withOpacity(0.8),
        height: 1.5,
        fontSize: FontSizeManager.large * 1.1,
        fontWeight: FontWeightManager.medium);
    return RichText(
        textAlign: TextAlign.start,
        text: TextSpan(style: defaultStyle, children: [
          TextSpan(text: "Good $time,\n"),
          TextSpan(
              text: "${ref.watch(ClientProvider.userProvider)!.fullName}.",
              style: defaultStyle.copyWith(
                  color: ColorManager.primaryDark,
                  fontWeight: FontWeightManager.bold))
        ]));
  }

  Widget carouselWidget() {
    const defaultStyle = TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontSize: FontSizeManager.regular * 0.9,
        fontWeight: FontWeightManager.semibold);
    return Container(
      width: MediaQuery.of(context).size.width,
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
                      ? Colors.blue
                      : index == 1
                          ? Colors.purple
                          : Colors.red.shade700,
                  borderRadius: BorderRadius.circular(SizeManager.medium),
                ),
                child: Stack(
                  children: [
                    Positioned(
                        bottom: 10,
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
                              fontSize: FontSizeManager.extralarge * 0.9),
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
            viewportFraction: 0.6,
            height: 120,
            autoPlayInterval: const Duration(seconds: 6),
          )),
    );
  }

  Widget cancelIcon() {
    return Icon(
      CupertinoIcons.xmark,
      size: IconSizeManager.extralarge,
      color: Colors.white.withOpacity(0.4),
    );
  }

  Widget completeIcon() {
    return Icon(
      CupertinoIcons.checkmark,
      size: IconSizeManager.extralarge,
      color: Colors.white.withOpacity(0.4),
    );
  }

  Widget ongoingIcon() {
    return SvgIcon(
      svgRes: AssetManager.svgFile(name: 'transaction'),
      size: const Size.square(IconSizeManager.extralarge),
      color: Colors.white.withOpacity(0.4),
    );
  }

  Widget latestTransactionsWidget() {
    final defaultStyle = TextStyle(
        fontFamily: 'Lato',
        color: ColorManager.primary,
        fontSize: FontSizeManager.large,
        fontWeight: FontWeightManager.bold);
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Text(
              "Latest Transactions",
              style: defaultStyle,
              textAlign: TextAlign.start,
            ),
          ),
          regularSpacer(),
          ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.small),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => TransactionItemWidget(
                    transaction: transactions()[index],
                  ),
              separatorBuilder: (context, index) => Divider(
                    thickness: 0.8,
                    color: ColorManager.secondary.withOpacity(0.08),
                  ),
              itemCount: transactions().length >= 3 ? 3 : transactions().length)
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
