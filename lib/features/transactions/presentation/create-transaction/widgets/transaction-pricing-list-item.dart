import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/pricings-notifier.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/service.dart';

class TransactionPricingListWidget extends ConsumerStatefulWidget {
  SalesItem item;
  final bool editable;
  TransactionPricingListWidget(
      {super.key, required this.item, this.editable = true});

  @override
  ConsumerState<TransactionPricingListWidget> createState() =>
      _TransactionPricingListWidgetState();
}

class _TransactionPricingListWidgetState
    extends ConsumerState<TransactionPricingListWidget> {
  @override
  void initState() {
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
          if (widget.editable) quantityWidget(),
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
            image: widget.item.noImage
                ? AssetImage(AssetManager.imageFile(name: "task"))
                : widget.item.mainImage().startsWith('http')
                    ? NetworkImage(widget.item.mainImage())
                    : FileImage(File(widget.item.mainImage())),
          )),
    );
  }

  Widget productDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.item.name,
          style: TextStyle(
              fontFamily: 'quicksand',
              color: ColorManager.secondary,
              fontSize: FontSizeManager.regular,
              fontWeight: FontWeightManager.semibold),
        ),
        smallSpacer(),
        Text(
          "${widget.item.priceString} NGN",
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            if (widget.item.quantity <= 1) {
              return;
            }
            ref
                .read(pricingsProvider.notifier)
                .reduceQuantity(item: widget.item);
            TransactionDataHolder.items = ref.read(pricingsProvider);

            // /// I get the products from transactionProductions.
            // /// and overwite it by affecting changes there.
            //
            // final items = List<SalesItem>.from(TransactionDataHolder.items!);
            // final currentItem =
            //     items.firstWhere((element) => element.id == widget.item.id);
            // final currentItemJson = currentItem.toJson();
            // final int formerQuantity = quantity;
            // currentItemJson["quantity"] =
            //     formerQuantity == 1 ? 1 : formerQuantity - 1;
            // setState(() {
            //   quantity = quantity == 1 ? 1 : quantity - 1;
            // });
            //
            // final formerIndex = items.indexOf(currentItem);
            // final itemObject = TransactionDataHolder.transactionCategory ==
            //         TransactionCategory.Service
            //     ? Service.fromJson(json: currentItemJson)
            //     : TransactionDataHolder.transactionCategory ==
            //             TransactionCategory.Virtual
            //         ? VirtualService.fromJson(json: currentItemJson)
            //         : Product.fromJson(json: currentItemJson);
            // items.insert(formerIndex, itemObject);
            // items.removeAt(formerIndex + 1);
            // TransactionDataHolder.items = items;
          },
          icon: SvgIcon(
            svgRes: AssetManager.svgFile(name: "minus"),
            size: const Size.square(IconSizeManager.regular * 1.4),
            color: ColorManager.accentColor,
          ),
        ),
        const Gap(SizeManager.regular),
        Text(
          widget.item.quantity.toString(),
          style: TextStyle(
              fontFamily: "quicksand",
              color: ColorManager.secondary,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium),
        ),
        const Gap(SizeManager.regular),
        IconButton(
          onPressed: () {
            ref
                .read(pricingsProvider.notifier)
                .increaseQuantity(item: widget.item);
            TransactionDataHolder.items = ref.read(pricingsProvider);
            // /// I get the products from transactionProductions.
            // /// and overwite it by affecting changes there.
            //
            // final items = List<SalesItem>.from(TransactionDataHolder.items!);
            //
            // final currentItem =
            //     items.firstWhere((element) => element.id == widget.item.id);
            // final currentItemJson = currentItem.toJson();
            // final int formerQuantity = quantity;
            // currentItemJson["quantity"] = formerQuantity + 1;
            // setState(() {
            //   quantity = quantity + 1;
            // });
            //
            // final formerIndex = items.indexOf(currentItem);
            // final itemObject = TransactionDataHolder.transactionCategory ==
            //         TransactionCategory.Service
            //     ? Service.fromJson(json: currentItemJson)
            //     : TransactionDataHolder.transactionCategory ==
            //             TransactionCategory.Virtual
            //         ? VirtualService.fromJson(json: currentItemJson)
            //         : Product.fromJson(json: currentItemJson);
            // items.insert(formerIndex, itemObject);
            // items.removeAt(formerIndex + 1);
            // TransactionDataHolder.items = items;
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
