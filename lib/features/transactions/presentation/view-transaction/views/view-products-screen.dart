import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/animations/lottie.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/onboarding-indicator.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/transaction.dart';

class ViewProductScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  const ViewProductScreen({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewProductScreenState();
}

class _ViewProductScreenState extends ConsumerState<ViewProductScreen> {
  late List<SalesItem> items;
  late PageController controller;
  int productIndex = 0;

  @override
  void initState() {
    controller = PageController();
    items = widget.transaction.salesItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            productsSlider(),
            largeSpacer(),
            body(),
          ],
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
        setState(() => productIndex = value);
      },
      itemBuilder: (context, index) {
        final product = items[index];
        return CachedNetworkImage(
          imageUrl: product.image,
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
    final product = items[productIndex];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${product.name.substring(0, product.name.length > 25 ? 23 : null)}${product.name.length > 25 ? ".." : ""}",
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
    final product = items[productIndex];
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
          product.priceString,
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
    final product = items[productIndex];
    final no = product.quantity;
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "$no",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
    );
  }

  Widget productsCategory() {
    final product = items[productIndex] as Product;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Category: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          product.productCategory,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
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
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          service.serviceRequirement.name,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
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
              fontSize: FontSizeManager.medium * 0.85),
        ),
        Text(
          "${NumberFormat.currency(decimalDigits: 2, locale: 'en_NG', symbol: '').format(product.price * no)} NG",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.92),
        ),
      ],
    );
  }

  Widget divider() {
    return Divider(
      color: ColorManager.secondary.withOpacity(0.09),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          productName(),
          regularSpacer(),
          productPrice(),
          extraLargeSpacer(),
          regularSpacer(),
          productsCategory(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          productsCondition(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          productsQuantity(),
          regularSpacer(),
          divider(),
          regularSpacer(),
          totalAmount(),
        ],
      ),
    );
  }
}
