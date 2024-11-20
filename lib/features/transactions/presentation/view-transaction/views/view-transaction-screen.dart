// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/drag-handle.dart';
import 'package:troco/core/components/others/onboarding-indicator.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/report/presentation/widgets/report-transaction-sheet.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/pricings-notifier.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transaction-tab-index.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/transaction-details-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/transaction-progress-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/rounded-tab-indicator.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/tab-item.dart';
import 'package:troco/features/transactions/utils/service-role.dart';
import 'package:troco/features/transactions/utils/transaction-status-converter.dart';

import '../../../../../core/components/animations/lottie.dart';
import '../../../../auth/presentation/providers/client-provider.dart';
import '../../../utils/enums.dart';
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

    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        final json = ref.read(currentTransactionProvider).clone().toJson();
        json.remove("pricing");
        json.remove("accountDetailes");
        json.remove("driverInformation");
        debugPrint(json.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    listenToTransactionsChanges();
    transaction = ref.watch(currentTransactionProvider);
    salesItems = transaction.salesItem;
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
        if (item.noImage) {
          return Image.asset(
            AssetManager.imageFile(name: "task"),
            width: double.maxFinite,
            height: double.maxFinite,
          );
        }
        return CachedNetworkImage(
          imageUrl: item.mainImage(),
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
          TransactionsDetailPage(transaction: transaction),
          TransactionProgressPage(transaction: transaction),
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

  List<PopupMenuItem> popupMenus() {
    return [
      /// Only show this menu if i'm not the actual client (That is the real creator) and
      /// Real Client hasn't accepted terms and conditions (Status is on Pending)
      if (!transaction.realClient &&
          transaction.transactionStatus == TransactionStatus.Pending)
        PopupMenuItem(
          value: 'edit',
          labelTextStyle: WidgetStateTextStyle.resolveWith(
            (states) {
              return TextStyle(
                  color: ColorManager.secondary,
                  fontWeight: FontWeightManager.semibold,
                  fontFamily: 'quicksand');
            },
          ),
          child: const Text("Edit Transaction"),
        ),
      PopupMenuItem(
        value: 'report',
        labelTextStyle: WidgetStateTextStyle.resolveWith(
          (states) {
            return TextStyle(
                color: ColorManager.secondary,
                fontWeight: FontWeightManager.semibold,
                fontFamily: 'quicksand');
          },
        ),
        child: const Text("Report Transaction"),
      ),
      if (transaction.transactionStatus != TransactionStatus.Completed)
        PopupMenuItem(
            value: 'group',
            labelTextStyle: WidgetStateTextStyle.resolveWith(
              (states) {
                return TextStyle(
                    color: ColorManager.secondary,
                    fontWeight: FontWeightManager.semibold,
                    fontFamily: 'quicksand');
              },
            ),
            child: const Text("View Order"))
    ];
  }

  Widget menuButton() {
    return PopupMenuButton(
      itemBuilder: (context) => popupMenus(),
      iconColor: Colors.white,
      color: ColorManager.background,
      onSelected: (value) async {
        if (value == 'edit') {
          /// To edit, we just assign the transaction data to the data from the...
          /// this transaction. The create-transaction-progress-page, knows how to...
          /// handle the rest.
          TransactionDataHolder.clear(ref: ref);
          TransactionDataHolder.assignFrom(transaction: transaction);
          TransactionDataHolder.isEditing = true;
          for (final item in transaction.salesItem) {
            ref.read(pricingsProvider.notifier).addItem(item: item);
          }
          Navigator.pushNamed(context, Routes.createTransactionRoute,
              arguments: transaction.group);
          return;
        }

        if (value == 'report') {
          await ReportTransactionSheet.bottomSheet(
              context: context, transaction: transaction);
          return;
        }

        if (value == 'group') {
          context.pushNamed(
              routeName: Routes.chatRoute, arguments: transaction.group);
          return;
        }
      },
    );
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
          const Spacer(),
          menuButton(),
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
          ref.read(currentTransactionProvider.notifier).state = t;
        }
      });
    });
  }
}
