import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:troco/core/components/clippers/bottom-rounded.dart';
import 'package:troco/features/dashboard/presentation/widgets/latest-transactions-list.dart';
import 'package:troco/features/dashboard/presentation/widgets/transaction-overview.dart';
import 'package:troco/features/groups/presentation/widgets/empty-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transactions-provider.dart';

import '../../../transactions/domain/entities/transaction.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<Transaction> transactions = [];
  final defaultStyle = TextStyle(
      fontFamily: 'quicksand',
      color: ColorManager.primary,
      fontSize: FontSizeManager.large * 0.85,
      fontWeight: FontWeightManager.bold);

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
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: ref.watch(transactionsStreamProvider).when(
          data: (transactions) {
            this.transactions = transactions;
            return transactions.isEmpty ? emptyBody() : body();
          },
          error: (error, stackTrace) {
            transactions = AppStorage.getTransactions();
            return transactions.isEmpty ? emptyBody() : body();
          },
          loading: () {
            transactions = AppStorage.getTransactions();
            return transactions.isEmpty ? emptyBody() : body();
          },
        ),
      ),
    );
  }

  Widget emptyBody() {
    return Column(children: [
      appBarWidget(),
      mediumSpacer(),
      EmptyScreen(
        lottie: AssetManager.lottieFile(name: "empty-transactions"),
        scale: 1.5,
        label: "You do not have any transactions.",
        expanded: true,
      ),
      const Gap(SizeManager.bottomBarHeight)
    ]);
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          appBarWidget(),
          mediumSpacer(),
          const TransactionOverview(),
          largeSpacer(),
          const LatestTransactionsList(),
          const Gap(SizeManager.bottomBarHeight)
        ],
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
              height: 280,
              color: ColorManager.accentColor.withOpacity(0.8),
              child: Stack(
                children: [
                  Positioned(
                    right: -45,
                    top: -50,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(MediaQuery.of(context).viewPadding.top),
                      largeSpacer(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: SizeManager.regular * 1.8,
                            right: SizeManager.medium * 1.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                              AssetManager.imageFile(name: "troco-white"),
                              width: 110,
                              height: 22,
                              fit: BoxFit.cover,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.pushNamed(
                                    context, Routes.notificationRoute);
                                SystemChrome.setSystemUIOverlayStyle(
                                    ThemeManager.getHomeUiOverlayStyle());
                              },
                              child: Icon(
                                Icons.notifications_rounded,
                                color: ColorManager.primaryDark,
                                size: IconSizeManager.medium * 0.9,
                              ),
                            ),
                            mediumSpacer(),
                            regularSpacer(),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context,Routes.viewProfileRoute,arguments: ClientProvider.readOnlyClient!),
                              child: const UserProfileIcon(
                                size: IconSizeManager.medium * 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      largeSpacer(),
                      regularSpacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SizeManager.medium * 1.6),
                        child: nameWidget(),
                      ),
                    ],
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
        color: ColorManager.background.withOpacity(0.9),
        height: 1.45,
        fontSize: FontSizeManager.large * 1.05,
        fontWeight: FontWeightManager.regular);
    return RichText(
        textAlign: TextAlign.start,
        text: TextSpan(style: defaultStyle, children: [
          TextSpan(
              text: "Good $time, \n",
              style: defaultStyle.copyWith(
                  fontSize: FontSizeManager.medium * 1.1)),
          TextSpan(
              text: "${ref.watch(ClientProvider.userProvider)!.fullName}.",
              style: defaultStyle.copyWith(
                  color: ColorManager.primaryDark,
                  fontWeight: FontWeightManager.bold))
        ]));
  }

  Widget carouselWidget() {
    // final bo ongoingTransactionBool = element.transactionStatus != TransactionStatus.Pending;
    final int totalTransactions = transactions
        .map((e) => e.transactionAmount)
        .fold(0, (previousValue, element) => (previousValue + element).toInt());
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
                          index == 1
                              ? "${NumberFormat.currency(symbol: '', locale: 'en_NG', decimalDigits: 0).format(totalTransactions)} NGN"
                              : "0 NGN",
                          style: defaultStyle.copyWith(
                              fontWeight: FontWeightManager.bold,
                              fontSize: FontSizeManager.large * 0.9),
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
}
