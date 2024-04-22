import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/color-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/images/svg.dart';
import '../../domain/entities/product.dart';

class TransactionPricingListWidget extends ConsumerStatefulWidget {
  final Product product;
  const TransactionPricingListWidget({super.key, required this.product});

  @override
  ConsumerState<TransactionPricingListWidget> createState() =>
      _TransactionPricingListWidgetState();
}

class _TransactionPricingListWidgetState
    extends ConsumerState<TransactionPricingListWidget> {
  int quantity = 0;

  @override
  void initState() {
    quantity = widget.product.quantity;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular, vertical: SizeManager.small),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular),
          color: ColorManager.background,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, -1),
                blurRadius: 1),
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, 5),
                blurStyle: BlurStyle.outer,
                spreadRadius: 0,
                blurRadius: 6),
          ]),
      child: Row(
        children: [
          productImage(),
          mediumSpacer(),
          Expanded(child: productDetails()),
          smallSpacer(),
          quantityWidget(),
        ],
      ),
    );
  }

  Widget productImage() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: FileImage(File(widget.product.productImages[0])),
          )),
    );
  }

  Widget productDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.product.productName,
          style: TextStyle(
              fontFamily: 'quicksand',
              color: ColorManager.secondary,
              fontSize: FontSizeManager.regular,
              fontWeight: FontWeightManager.semibold),
        ),
        smallSpacer(),
        Text(
          "${widget.product.productPriceString} NGN",
          style: TextStyle(
            fontFamily: 'quicksand',
            color: ColorManager.accentColor,
            fontSize: FontSizeManager.regular * 0.8,
            fontWeight: FontWeightManager.bold,
          ),
        ),
      ],
    );
  }

  Widget quantityWidget() {
    int quantity = widget.product.quantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            /// I get the products from transactionProductions.
            /// and overwite it by affecting changes there.

            if (quantity == 1) {
              return;
            }

            final products = TransactionDataHolder.products;
            final currentProduct = products!.firstWhere(
                (element) => element.productId == widget.product.productId);
            final currentProductJson = currentProduct.toJson();
            int formerQuantity = quantity;
            currentProductJson["quantity"] = --formerQuantity;
            setState(() {
              quantity -= 1;
            });

            final formerIndex = products.indexOf(currentProduct);
            products.insert(
                formerIndex, Product.fromJson(json: currentProductJson));
            products.removeAt(formerIndex + 1);
            TransactionDataHolder.products = products;
          },
          icon: SvgIcon(
            svgRes: AssetManager.svgFile(name: "minus"),
            size: const Size.square(IconSizeManager.regular * 1.4),
            color: ColorManager.accentColor,
          ),
        ),
        const Gap(SizeManager.regular),
        Text(
          quantity.toString(),
          style: TextStyle(
              fontFamily: "quicksand",
              color: ColorManager.secondary,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium),
        ),
        const Gap(SizeManager.regular),
        IconButton(
          onPressed: () {
            /// I get the products from transactionProductions.
            /// and overwite it by affecting changes there.

            final products = TransactionDataHolder.products;
            final currentProduct = products!.firstWhere(
                (element) => element.productId == widget.product.productId);
            final currentProductJson = currentProduct.toJson();
            int formerQuantity = quantity;
            currentProductJson["quantity"] = ++formerQuantity;
            setState(() {
              quantity += 1;
            });

            final formerIndex = products.indexOf(currentProduct);
            products.insert(
                formerIndex, Product.fromJson(json: currentProductJson));
            products.removeAt(formerIndex + 1);
            TransactionDataHolder.products = products;
          },
          icon: SvgIcon(
            svgRes: AssetManager.svgFile(name: "add"),
            size: const Size.square(IconSizeManager.regular * 1.4),
            color: ColorManager.accentColor,
          ),
        ),
        smallSpacer(),
      ],
    );
  }
}
