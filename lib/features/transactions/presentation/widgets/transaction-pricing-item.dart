import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';

import '../../domain/entities/product.dart';

class TransactionPricingWidget extends ConsumerWidget {
  final Product product;
  const TransactionPricingWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular),
          color: ColorManager.background,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 5),
                blurStyle: BlurStyle.outer,
                blurRadius: 5)
          ]),
      child: Column(
        children: [
          Expanded(
              child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(SizeManager.regular)),
            child: Container(
              margin: EdgeInsets.zero,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(SizeManager.regular)),
                  image: DecorationImage(
                      image: FileImage(File(product.productImages[0])),
                      fit: BoxFit.cover)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: SizeManager.small),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.3),
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 0,
                        onPressed: () => log("message"),
                        icon: const Icon(
                          size: IconSizeManager.regular * 1.3,
                          CupertinoIcons.xmark_circle_fill,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          "${product.quantity} Qty",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              fontFamily: 'quicksand',
                              color: Colors.white,
                              fontWeight: FontWeightManager.bold,
                              fontSize: FontSizeManager.regular * 1.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
          smallSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManager.regular * 1.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                smallSpacer(),
                Text(
                  product.productName,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontFamily: 'quicksand',
                      color: ColorManager.secondary,
                      fontWeight: FontWeightManager.semibold,
                      fontSize: FontSizeManager.regular * 0.85),
                ),
                regularSpacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sell_rounded,
                      color: ColorManager.accentColor,
                      size: IconSizeManager.small,
                    ),
                    smallSpacer(),
                    Text(
                      product.productPriceString,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'quicksand',
                          color: ColorManager.accentColor,
                          fontWeight: FontWeightManager.bold,
                          fontSize: FontSizeManager.regular),
                    ),
                  ],
                ),
                regularSpacer(),
                smallSpacer(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
