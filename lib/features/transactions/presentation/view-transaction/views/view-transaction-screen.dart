import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/core/basecomponents/others/drag-handle.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transaction-tab-index.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/transaction-details-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/transaction-progress-page.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/rounded-tab-indicator.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/tab-item.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/view-transactionproduct-clipper.dart';

import '../../../../../core/basecomponents/animations/lottie.dart';
import '../../../domain/entities/product.dart';

class ViewTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  const ViewTransactionScreen({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewTransactionScreenState();
}

class _ViewTransactionScreenState extends ConsumerState<ViewTransactionScreen> {
  late List<Product> products;
  late Transaction transaction;
  int productIndex = 0;

  @override
  void initState() {
    products = widget.transaction.products;
    transaction = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Column(
        children: [
          appBar(),
          Expanded(child: body()),
        ],
      ),
      extendBody: true,
    );
  }

  Widget appBar() {
    return ClipPath(
      clipper: TransactionProductClipper(),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.4 +
            MediaQuery.viewPaddingOf(context).top,
        child: Stack(
          children: [
            slider(),
            Positioned(top: 0, right: 0, left: 0, child: controls()),
            Positioned(left: 0, right: 0, bottom: 0, child: productName())
          ],
        ),
      ),
    );
  }

  Widget slider() {
    return SizedBox.expand(
        child: PageView.builder(
      itemCount: products.length,
      onPageChanged: (value) {
        setState(() => productIndex = value);
      },
      itemBuilder: (context, index) {
        final product = products[index];
        return CachedNetworkImage(
          imageUrl: product.productImage,
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
    return Container(
      height: double.maxFinite,
      padding: const EdgeInsets.only(
          bottom: SizeManager.regular, top: SizeManager.small),
      child: Column(
        children: [
          const DragHandle(scale: 0.8),
          regularSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomTabWidget(
                        transaction: widget.transaction,
                        isFirst: true,
                        description:
                            widget.transaction.transactionPurpose.name),
                    CustomTabWidget(
                        transaction: widget.transaction,
                        description: widget.transaction.transactionStatus.name),
                  ],
                ),
                smallSpacer(),
                RoundedTabIndicator(
                    firstSelected: ref.watch(tabIndexProvider) == 0),
              ],
            ),
          ),
          Expanded(
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
          ),
        ],
      ),
    );
  }

  Widget productName() {
    final product = products[productIndex];
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
      child: Text(
        product.productName,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white,
            fontSize: FontSizeManager.medium,
            fontWeight: FontWeightManager.extrabold,
            fontFamily: 'quicksand'),
      ),
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
        ],
      ),
    );
  }
}
