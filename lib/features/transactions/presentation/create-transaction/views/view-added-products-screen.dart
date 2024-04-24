import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/product-images-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/basecomponents/images/svg.dart';

class ViewAddedProductsScreen extends ConsumerStatefulWidget {
  final int? currentPosition;
  const ViewAddedProductsScreen({super.key, this.currentPosition});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewAddedProductsScreenState();
}

class _ViewAddedProductsScreenState
    extends ConsumerState<ViewAddedProductsScreen> {
  List<String> images = [];
  late PageController controller;
  @override
  void initState() {
    controller = PageController(initialPage: widget.currentPosition ?? 0);
    super.initState();
    setState(() {
      images = ref.read(productImagesProvider);
    });
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getTransactionScreenUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: appBar(),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        child: PageView(
          controller: controller,
          children: images.map((e) {
            return Container(
              width: double.maxFinite,
              height: double.maxFinite,
              alignment: Alignment.center,
              child: Container(
                width: double.maxFinite,
                alignment: Alignment.center,
                constraints: const BoxConstraints(maxHeight: 400),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.file(
                      File(e),
                      width: double.maxFinite,
                      height: double.maxFinite,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SizeManager.medium,
                          vertical: SizeManager.regular),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: SizeManager.regular,
                                  horizontal: SizeManager.regular),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.65)),
                              child: Text(
                                "${images.indexOf(e) + 1}/${images.length}",
                                style: const TextStyle(
                                  fontFamily: 'quicksand',
                                  color: Colors.white,
                                  fontSize: FontSizeManager.small,
                                  fontWeight: FontWeightManager.semibold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    vertical: SizeManager.regular * 0.9,
                                    horizontal: SizeManager.regular * 0.9),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.65),
                                ),
                                child: const Icon(
                                  Icons.shopping_basket,
                                  color: Colors.white,
                                  size: IconSizeManager.regular * 0.8,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.accentColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Products",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
