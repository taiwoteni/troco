// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import '../../../../../core/components/others/spacer.dart';

class SelectReturnProductWidget extends StatefulWidget {
  bool selected;
  final void Function() onChecked;
  final SalesItem item;
  final bool isDisplay;

  SelectReturnProductWidget(
      {super.key,
      required this.selected,
      required this.onChecked,
      this.isDisplay = false,
      required this.item});

  @override
  State<SelectReturnProductWidget> createState() =>
      _SelectPaymentMethodWidgetState();
}

class _SelectPaymentMethodWidgetState extends State<SelectReturnProductWidget> {
  late SalesItem item;

  @override
  void initState() {
    item = widget.item;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () {
        widget.onChecked();
      },
      child: Container(
        width: double.maxFinite,
        height: widget.isDisplay ? 85 : 95,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
        decoration: BoxDecoration(
            color: widget.selected
                ? ColorManager.accentColor.withOpacity(0.05)
                : ColorManager.background,
            border: Border.all(
                color: widget.selected
                    ? ColorManager.accentColor
                    : ColorManager.secondary.withOpacity(0.09),
                width: 2),
            borderRadius: BorderRadius.circular(SizeManager.regular)),
        child: Row(
          children: [
            productImage(),
            extraLargeSpacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.primary,
                      fontSize: FontSizeManager.regular,
                      fontWeight: FontWeightManager.semibold),
                ),
                Text(
                  "${item.priceString}NGN",
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.accentColor,
                      fontSize: FontSizeManager.small * 0.9,
                      fontWeight: FontWeightManager.semibold),
                ),
              ],
            ),
            const Spacer(),
            if (!widget.isDisplay)
              Radio(
                  value: widget.selected,
                  groupValue: true,
                  fillColor: MaterialStatePropertyAll(ColorManager.accentColor),
                  activeColor: ColorManager.accentColor,
                  toggleable: false,
                  onChanged: null),
          ],
        ),
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
            image: CachedNetworkImageProvider(item.mainImage()),
          )),
    );
  }
}
