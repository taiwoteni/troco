// ignore_for_file: unused_element

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/drag-handle.dart';
import 'package:troco/core/components/others/onboarding-indicator.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transaction-tab-index.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/transaction-details-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/transaction-progress-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/rounded-tab-indicator.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/tab-item.dart';
import 'package:troco/features/transactions/utils/transaction-status-converter.dart';

import '../../../../../core/components/animations/lottie.dart';
import '../providers/current-transacton-provider.dart';
import '../providers/transactions-provider.dart';

class ViewTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  const ViewTransactionScreen({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewTransactionScreenState();
}

class _ViewTransactionScreenState extends ConsumerState<ViewTransactionScreen> {
  late List<SalesItem> salesItems;
  late Transaction transaction;
  late PageController controller;
  int productIndex = 0;

  @override
  void initState() {
    controller = PageController();
    salesItems = widget.transaction.salesItem;
    transaction = widget.transaction;
    log(transaction.toJson().toString());
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        // Still keeping transaction as a named argument
        //but later override it during initState
        transaction = ref.watch(currentTransactionProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    listenToTransactionsChanges();
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          appBar(),
          body(),
        ],
      ),
      extendBody: true,
    );
  }

  Widget appBar() {
    return SliverAppBar(
      systemOverlayStyle: ThemeManager.getGroupsUiOverlayStyle(),
      automaticallyImplyLeading: false,
      expandedHeight: MediaQuery.sizeOf(context).height * 0.4 +
          MediaQuery.viewPaddingOf(context).top,
      elevation: 0,
      forceElevated: false,
      forceMaterialTransparency: true,
      floating: true,
      snap: true,
      stretch: true,
      backgroundColor: ColorManager.background,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
        ],
        background: productsWidget(),
      ),
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100), child: tabBar()),
    );
  }

  Widget tabBar() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge * 1.5)),
          color: ColorManager.background),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mediumSpacer(),
          const DragHandle(scale: 0.8),
          regularSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomTabWidget(
                        transaction: transaction,
                        isFirst: true,
                        description: transaction.transactionPurpose.name),
                    CustomTabWidget(
                        transaction: transaction,
                        description:
                            TransactionStatusConverter.convertToStringStatus(
                                status: transaction.transactionStatus)),
                  ],
                ),
                smallSpacer(),
                const RoundedTabIndicator(),
                smallSpacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget productsWidget() {
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.sizeOf(context).height * 0.4 +
          MediaQuery.viewPaddingOf(context).top,
      child: Stack(
        children: [
          slider(),
          Positioned(top: 0, right: 0, left: 0, child: controls()),
          Positioned(top: 0, right: 0, left: 0, child: itemName()),
          Positioned(
              left: 0,
              right: 0,
              bottom: SizeManager.extralarge * 2,
              child: indicators())
        ],
      ),
    );
  }

  Widget slider() {
    return SizedBox.expand(
        child: PageView.builder(
      controller: controller,
      itemCount: salesItems.length,
      onPageChanged: (value) {
        setState(() => productIndex = value);
      },
      itemBuilder: (context, index) {
        final item = salesItems[index];
        return CachedNetworkImage(
          imageUrl: item.image,
          fit: BoxFit.cover,
          height: double.maxFinite,
          fadeInCurve: Curves.ease,
          fadeOutCurve: Curves.ease,
          placeholder: (context, url) {
            return Container(
              width: double.maxFinite,
              height: double.maxFinite,
              color: ColorManager.lottieLoading,
              child: LottieWidget(
                  lottieRes: AssetManager.lottieFile(name: "loading-image"),
                  size: const Size.square(IconSizeManager.extralarge * 0.9)),
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              width: double.maxFinite,
              height: double.maxFinite,
              color: ColorManager.lottieLoading,
              child: LottieWidget(
                  lottieRes: AssetManager.lottieFile(name: "loading-image"),
                  size: const Size.square(IconSizeManager.extralarge * 0.9)),
            );
          },
        );
      },
    ));
  }

  Widget body() {
    return SliverFillRemaining(
      child: PageView(
        onPageChanged: (value) =>
            ref.read(tabIndexProvider.notifier).state = value,
        physics: const BouncingScrollPhysics(),
        controller: ref.watch(tabControllerProvider),
        children: [
          TransactionsDetailPage(transaction: widget.transaction),
          TransactionProgressPage(transaction: widget.transaction),
        ],
      ),
    );
  }

  Widget itemName() {
    final item = salesItems[productIndex];
    return Container(
      width: double.maxFinite,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(
          left: SizeManager.medium,
          bottom: SizeManager.extralarge * 1.5,
          top: SizeManager.extralarge),
      child: Text(
        item.name,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white,
            fontSize: FontSizeManager.medium,
            fontWeight: FontWeightManager.extrabold,
            fontFamily: 'quicksand'),
      ),
    );
  }

  Widget indicators() {
    return Container(
        width: double.maxFinite,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(
            left: SizeManager.medium,
            bottom: SizeManager.extralarge * 1.5,
            top: SizeManager.medium),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.1),
          Colors.black.withOpacity(0.2),
          Colors.black.withOpacity(0.3),
          Colors.black.withOpacity(0.3),
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.5),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
                salesItems.length,
                (index) => GestureDetector(
                      onTap: () {
                        controller.animateToPage(index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                      child: OnboardingIndicator(
                          checkedColor: Colors.white,
                          checked: productIndex == index),
                    ))
          ],
        ));
  }

  Widget controls() {
    return Container(
      width: double.maxFinite,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.1),
        Colors.black.withOpacity(0.2),
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.4),
        Colors.black.withOpacity(0.5),
      ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
      padding: EdgeInsets.only(
        top: MediaQuery.viewPaddingOf(context).top / 2 + SizeManager.regular,
        right: SizeManager.medium,
        left: SizeManager.medium,
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: SvgIcon(
                svgRes: AssetManager.svgFile(name: 'back'),
                color: Colors.white,
                size: const Size.square(IconSizeManager.medium * 1.1),
              )),
        ],
      ),
    );
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        if (value
            .map((t) => t.transactionId)
            .contains(transaction.transactionId)) {
          final t = value.firstWhere(
              (tr) => tr.transactionId == transaction.transactionId);
          setState(() {
            transaction = t;
          });
          ref.watch(currentTransactionProvider.notifier).state = t;
        }
      });
    });
  }
}
