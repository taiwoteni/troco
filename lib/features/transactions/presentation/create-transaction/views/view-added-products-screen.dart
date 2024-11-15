import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/product-images-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/components/images/svg.dart';

class ViewAddedItemsScreen extends ConsumerStatefulWidget {
  final int? currentPosition;
  final String? itemId;
  const ViewAddedItemsScreen({super.key, this.currentPosition, this.itemId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewAddedProductsScreenState();
}

class _ViewAddedProductsScreenState
    extends ConsumerState<ViewAddedItemsScreen> {
  List<String> images = [];
  String? itemId;
  late PageController controller;
  @override
  void initState() {
    controller = PageController(initialPage: widget.currentPosition ?? 0);
    itemId = widget.itemId;
    super.initState();
    setState(() {
      images = List.from(ref.read(pricingsImagesProvider));
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
        child: images.isEmpty
            ? LottieWidget(
                lottieRes: AssetManager.lottieFile(name: 'loading_image'),
                size: const Size.fromHeight(400))
            : PageView(
                controller: controller,
                children: images.map((e) {
                  return Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          width: double.maxFinite,
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image(
                                  image: e.startsWith('http')
                                      ? CachedNetworkImageProvider(e)
                                      : FileImage(File(e)),
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  fit: BoxFit.cover),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: SizeManager.medium,
                                    vertical: SizeManager.regular),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            color:
                                                Colors.black.withOpacity(0.65)),
                                        child: Text(
                                          "${images.indexOf(e) + 1}/${images.length}",
                                          style: const TextStyle(
                                            fontFamily: 'quicksand',
                                            color: Colors.white,
                                            fontSize: FontSizeManager.small,
                                            fontWeight:
                                                FontWeightManager.semibold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  SizeManager.regular * 0.9,
                                              horizontal:
                                                  SizeManager.regular * 0.9),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.black.withOpacity(0.65),
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
                        extraLargeSpacer(),
                        removeBtn(images.indexOf(e))
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget removeBtn(int position) {
    return GestureDetector(
      onTap: () {
        if (images[position].startsWith('http')) {
          final providerState =
              ref.read(removedImagesItemsProvider.notifier).state;
          if (providerState.any(
            (element) => element['_id'] == itemId,
          )) {
            final index = providerState.indexWhere(
              (element) => element['_id'] == itemId,
            );
            final item = providerState[index];
            final removedLists = (item['removedImages'] ?? []) as List;
            removedLists.add(images[position]);
            item['removedImages'] = removedLists;
            ref.watch(removedImagesItemsProvider.notifier).state[index] = item;
          } else {
            final item = <dynamic, dynamic>{'_id': itemId};
            item['removedImages'] = [images[position]];
            ref.watch(removedImagesItemsProvider.notifier).state.add(item);
          }
        }

        setState(() {
          images.removeAt(position);
        });
        ref.read(pricingsImagesProvider).removeAt(position);

        if (images.isEmpty) {
          context.pop();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
        child: DottedBorder(
            color: ColorManager.accentColor,
            strokeWidth: 2,
            borderType: BorderType.RRect,
            dashPattern: const [5, 6],
            radius: const Radius.circular(SizeManager.regular),
            child: Container(
              width: double.maxFinite,
              height: SizeManager.extralarge * 2,
              alignment: Alignment.center,
              child: Text(
                "Remove",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorManager.accentColor,
                    fontFamily: 'lato',
                    fontWeight: FontWeightManager.bold,
                    fontSize: FontSizeManager.large * 0.8),
              ),
            )),
      ),
    );
  }

  String getHeaderName() {
    switch (TransactionDataHolder.transactionCategory) {
      case TransactionCategory.Service:
        return "Tasks";
      case TransactionCategory.Virtual:
        return "Virtual-Items";
      default:
        return "Products";
    }
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
                  getHeaderName(),
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
