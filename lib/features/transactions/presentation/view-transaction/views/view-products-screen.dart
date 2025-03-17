import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/animations/lottie.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/onboarding-indicator.dart';
import '../../../domain/entities/product.dart';

class ViewProductScreen extends ConsumerStatefulWidget {
  const ViewProductScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewProductScreenState();
}

class _ViewProductScreenState extends ConsumerState<ViewProductScreen> {
  late List<SalesItem> items;
  late PageController controller;
  int productIndex = 0;
  int imageIndex = 0;

  @override
  void initState() {
    controller = PageController();
    items = [];
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        setState(() {
          items = ref.watch(currentTransactionProvider).salesItem;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: productIndex == 0,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (productIndex != 0) {
            controller.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          }
        }
      },
      child: Scaffold(
        backgroundColor: ColorManager.background,
        body: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              productsSlider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      largeSpacer(),
                      body(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget indicators() {
    return Container(
        width: double.maxFinite,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(
            left: SizeManager.medium,
            bottom: SizeManager.large,
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
                items.length,
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

  Widget productsSlider() {
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.sizeOf(context).height * 0.4 +
          MediaQuery.viewPaddingOf(context).top,
      child: Stack(
        children: [
          slider(),
          Positioned(top: 0, right: 0, left: 0, child: controls()),
          Positioned(bottom: 0, right: 0, left: 0, child: indicators()),
        ],
      ),
    );
  }

  Widget slider() {
    return SizedBox.expand(
        child: PageView.builder(
      controller: controller,
      itemCount: items.length,
      onPageChanged: (value) {
        setState(() {
          imageIndex = 0;
          productIndex = value;
        });
      },
      itemBuilder: (context, index) {
        final product = items[index];
        String image = "";
        try {
          image = product.images[imageIndex];
        } catch (e) {
          image = product.images.isEmpty ? "" : product.images[0];
        }

        if (product.noImage) {
          return Image.asset(
            AssetManager.imageFile(name: "task"),
            width: double.maxFinite,
            height: double.maxFinite,
            fit: BoxFit.cover,
          );
        }
        return CachedNetworkImage(
          imageUrl: image,
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

  Widget productName() {
    final item = items[productIndex];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${item.name.substring(0, item.name.length > 25 ? 23 : null)}${item.name.length > 25 ? ".." : ""}",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'Quicksand',
              wordSpacing: -0.5,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 1.21),
        ),
        regularSpacer(),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
              vertical: SizeManager.small, horizontal: SizeManager.small),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.65),
          ),
          child: const Icon(
            Icons.shopping_basket,
            color: Colors.white,
            size: IconSizeManager.small * 0.6,
          ),
        ),
      ],
    );
  }

  Widget productPrice() {
    final item = items[productIndex];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sell_rounded,
          color: ColorManager.accentColor,
          size: IconSizeManager.small * 1.1,
        ),
        smallSpacer(),
        Text(
          item.priceString,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'Lato',
              wordSpacing: -0.5,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.9),
        ),
      ],
    );
  }

  Widget productsQuantity() {
    final item = items[productIndex];
    final no = item.quantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Quantity: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "$no",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget productsQuality() {
    final item = items[productIndex];
    bool product = item is Product;
    bool service = item is Service;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          product ? "Quality: " : "Requirement: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          product
              ? (item).productCategory
              : service
                  ? item.serviceRequirement.name
                  : (item as VirtualService).serviceRequirement.name,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget productsCondition() {
    final product = items[productIndex] as Product;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Condition: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          ProductConditionConverter.convertToString(
              condition: product.productCondition),
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget serviceRequirements() {
    final service = items[productIndex] as Service;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Requirements: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          service.serviceRequirement.name,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget escrowFee() {
    final product = items[productIndex];
    final no = product.quantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Escrow Fee: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "${NumberFormat.currency(decimalDigits: 2, locale: 'en_NG', symbol: '').format(product.escrowCharge * no)} NG",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget escrowPercentage() {
    final product = items[productIndex];
    // final no = product.quantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Escrow Percentage: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "${product.escrowPercentage}%",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget totalAmount() {
    final product = items[productIndex];
    final no = product.quantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Price: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "${NumberFormat.currency(decimalDigits: 2, locale: 'en_NG', symbol: '').format(product.finalPrice * no)} NG",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget divider() {
    return Divider(
      color: ColorManager.secondary.withOpacity(0.09),
    );
  }

  Widget imageItem(
      {required final String profileUrl, required final int index}) {
    return GestureDetector(
      onTap: () => setState(() => imageIndex = index),
      child: Container(
        width: IconSizeManager.extralarge,
        height: IconSizeManager.extralarge,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManager.regular),
            image: DecorationImage(
                image: CachedNetworkImageProvider(profileUrl),
                fit: BoxFit.cover),
            border: imageIndex == index
                ? Border.all(color: ColorManager.accentColor, width: 2)
                : null),
      ),
    );
  }

  Widget imageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items[productIndex].images.map(
        (e) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: SizeManager.regular),
            child: imageItem(
                profileUrl: e, index: items[productIndex].images.indexOf(e)),
          );
        },
      ).toList(),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          productName(),
          regularSpacer(),
          productPrice(),
          extraLargeSpacer(),
          regularSpacer(),
          productsQuality(),
          regularSpacer(),
          if (ref.watch(currentTransactionProvider).transactionCategory ==
              TransactionCategory.Product) ...[
            divider(),
            regularSpacer(),
            productsCondition(),
            regularSpacer(),
          ],
          divider(),
          regularSpacer(),
          productsQuantity(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          escrowPercentage(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          escrowFee(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          totalAmount(),
          if (!items[productIndex].noImage) ...[mediumSpacer(), imageRow()]
        ],
      ),
    );
  }
}
