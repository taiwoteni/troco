// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/texts/inputs/dropdown-input-field.dart';
import 'package:troco/core/extensions/list-extension.dart';
import 'package:troco/core/extensions/string-extension.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';
import 'package:troco/features/transactions/utils/product-quality-converter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/currency_input_formatter.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../services/domain/entities/escrow-fee.dart';
import '../../../data/models/create-transaction-data-holder.dart';
import '../providers/pricings-notifier.dart';
import '../views/view-added-products-screen.dart';

class AddProductSheet extends ConsumerStatefulWidget {
  final Product? product;
  const AddProductSheet({super.key, this.product});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddProductWidgetState();

  static Future<Product?> bottomSheet(
      {required BuildContext context, Product? product}) async {
    return await showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        useSafeArea: false,
        backgroundColor: ColorManager.background,
        context: context,
        builder: (context) {
          return AddProductSheet(
            product: product,
          );
        });
  }
}

class _AddProductWidgetState extends ConsumerState<AddProductSheet> {
  ProductCondition? selectedProductCondition;
  ProductQuality? selectedProductQuality;
  late NumberFormat currencyFormatter;

  int quantity = 1;
  bool productImageError = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String price = "";
  String name = "";

  var images = <String>[];

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  void initState() {
    currencyFormatter = NumberFormat.currency(
      locale: 'en_NG',
      decimalDigits: 0,
      symbol: "",
    );
    selectedProductCondition = widget.product?.productCondition;
    selectedProductQuality = widget.product?.productQuality;
    quantity = widget.product?.quantity ?? 1;
    images = widget.product?.images ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
        color: ColorManager.background,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              extraLargeSpacer(),
              const DragHandle(),
              largeSpacer(),
              title(),
              mediumSpacer(),
              Divider(
                thickness: 1,
                color: ColorManager.secondary.withOpacity(0.08),
              ),
              mediumSpacer(),
              productName(),
              mediumSpacer(),
              regularSpacer(),
              productCondition(),
              mediumSpacer(),
              regularSpacer(),
              productQuality(),
              mediumSpacer(),
              regularSpacer(),
              productPrice(),
              mediumSpacer(),
              regularSpacer(),
              productQuantity(),
              mediumSpacer(),
              regularSpacer(),
              uploadPicture(),
              largeSpacer(),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    final TransactionCategory category =
        TransactionDataHolder.transactionCategory ??
            TransactionCategory.Product;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            widget.product != null ? "Edit Product" : "Add Product",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "Lato",
                fontSize: FontSizeManager.large * 0.9),
          ),
        ),
        Positioned(
          width: SizeManager.extralarge * 1.1,
          height: SizeManager.extralarge * 1.1,
          right: SizeManager.regular,
          child: IconButton(
              onPressed: () =>
                  loading ? null : Navigator.pop(context, widget.product),
              style: ButtonStyle(
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorManager.accentColor.withOpacity(0.2))),
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.accentColor,
                size: IconSizeManager.small,
              )),
        )
      ],
    );
  }

  Widget productName() {
    final TransactionCategory category =
        TransactionDataHolder.transactionCategory ??
            TransactionCategory.Product;
    return Column(
      children: [
        InfoText(
          text: " Product Name",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: widget.product?.name,
          label: 'e.g "iPhone 13"',
          validator: (value) {
            if (value == null) {
              return "* enter a product name";
            }
            if (value.trim().isEmpty) {
              return "* enter a product name";
            }

            return null;
          },
          onSaved: (value) {
            setState(() => name = value?.toString() ?? "");
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget productCondition() {
    return Column(
      children: [
        InfoText(
          text: "Product Condition",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        DropdownInputFormField(
          items: ProductCondition.values
              .map((e) =>
                  ProductConditionConverter.convertToString(condition: e))
              .toList(),
          value: selectedProductCondition == null
              ? ""
              : ProductConditionConverter.convertToString(
                  condition: selectedProductCondition!),
          onChanged: (value) {
            if (value != null) {
              final condition =
                  ProductConditionConverter.convertToEnum(condition: value);
              // To know wether selected value was truly changed or not
              if (condition != selectedProductCondition) {
                setState(() {
                  selectedProductCondition = condition;
                });
                if (![
                  ProductCondition.ForeignUsed,
                  ProductCondition.NigerianUsed
                ].contains(selectedProductCondition)) {
                  setState(() => selectedProductQuality = null);
                }
              }
            }
          },
          hint: 'e.g "New"',
          onValidate: (value) {
            if (value == null) {
              return "* enter a category";
            }
            if (value.trim().isEmpty) {
              return "* enter a category";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget productQuality() {
    final bool used = [
      ProductCondition.ForeignUsed,
      ProductCondition.NigerianUsed
    ].contains(selectedProductCondition);
    final List<ProductQuality> list = used
        ? [ProductQuality.Good, ProductQuality.Faulty]
        : [ProductQuality.High, ProductQuality.Low];
    return Column(
      children: [
        InfoText(
          text: "Product Quality",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        DropdownInputFormField(
          items: selectedProductCondition == null
              ? []
              : list
                  .map(
                    (e) => ProductQualityConverter.convertToString(quality: e),
                  )
                  .toList(),
          value: selectedProductQuality == null
              ? ""
              : ProductQualityConverter.convertToString(
                  quality: selectedProductQuality!),
          onChanged: (value) {
            if (value != null) {
              final quality =
                  ProductQualityConverter.convertToEnum(quality: value);
              setState(() {
                selectedProductQuality = quality;
              });
            }
          },
          hint: used ? 'e.g "High"' : 'e.g "Good"',
          onValidate: (value) {
            if (value == null) {
              return "* enter a quality";
            }
            if (value.trim().isEmpty) {
              return "* enter a quality";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget productPrice() {
    return Column(
      children: [
        InfoText(
          text: " Price",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          initialValue: widget.product?.price.toInt().format(currencyFormatter),
          label: 'NGN',
          inputType: TextInputType.phone,
          inputFormatters: [CurrencyInputFormatter()],
          validator: (value) {
            if (value == null) {
              return "* enter price";
            }
            if (value.trim().isEmpty) {
              return "* enter price";
            }
            if (!RegExp(r'^\d+(\.\d+)?$')
                .hasMatch(value.replaceAll(RegExp(r','), "").trim())) {
              return "* enter valid price";
            }
            return null;
          },
          onSaved: (value) {
            setState(() => price = value?.toString().replaceAll(",", "") ?? "");
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget productQuantity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoText(
          text: " Quantity",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        Container(
          width: 165,
          height: 45,
          decoration: BoxDecoration(
              border: Border.all(
                  color: ColorManager.secondary.withOpacity(0.15), width: 1.5),
              borderRadius: BorderRadius.circular(SizeManager.regular)),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity -= 1;
                      });
                    }
                  },
                  child: Center(
                    child: Icon(
                      CupertinoIcons.minus_circle_fill,
                      size: IconSizeManager.regular * 1.3,
                      color: ColorManager.accentColor,
                    ),
                  ),
                ),
              ),
              Container(
                height: double.maxFinite,
                width: 2,
                color: ColorManager.secondary.withOpacity(0.15),
              ),
              Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      quantity.toString(),
                      style: TextStyle(
                          fontFamily: "Lato",
                          color: ColorManager.primary,
                          fontWeight: FontWeightManager.extrabold,
                          fontSize: FontSizeManager.medium),
                    ),
                  )),
              Container(
                height: double.maxFinite,
                width: 2,
                color: ColorManager.secondary.withOpacity(0.15),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      quantity += 1;
                    });
                  },
                  child: Center(
                    child: Icon(
                      CupertinoIcons.plus_circle_fill,
                      size: IconSizeManager.regular * 1.3,
                      color: ColorManager.accentColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget uploadPicture() {
    return Column(
      children: [
        InfoText(
          text: " Upload Picture",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InfoText(
          text: " (Each image should be clear and have a max size of 2MB)",
          color: productImageError ? Colors.redAccent : ColorManager.secondary,
          fontSize: FontSizeManager.regular * 0.8,
          fontWeight: FontWeightManager.regular,
        ),
        largeSpacer(),
        SizedBox(
          width: double.maxFinite,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (images.isEmpty)
                pickProductImage()
              else
                productImage(position: 0),
              if (images.length < 2)
                pickProductImage()
              else
                productImage(position: 1),
              if (images.length < 3)
                pickProductImage()
              else
                productImage(position: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget button() {
    final isEditing = widget.product?.isEditing() == true;

    return CustomButton.medium(
      label: widget.product != null ? "Edit Product" : "Add Product",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        setState(() {
          loading = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          productImageError = images.isEmpty;
        });
        if (formKey.currentState!.validate() && !productImageError) {
          formKey.currentState!.save();
          const defaultCharge = EscrowCharge.fromJson(
              json: {"category": "product", "percentage": 10});
          final productCharge = AppStorage.getEscrowCharges().firstWhere(
            (charge) => charge.category == TransactionCategory.Product,
            orElse: () => defaultCharge,
          );

          final escrowCharge = (int.parse(price) * (productCharge.percentage));

          final productImages = images.toListString();
          Map<dynamic, dynamic> productJson = {
            "productId": isEditing
                ? widget.product?.id
                : (ref.read(pricingsProvider).length + 1).toString(),
            "productName": name,
            "productPrice": double.parse(price),
            "productCondition": ProductConditionConverter.convertToString(
                condition: selectedProductCondition!),
            "productQuality": ProductQualityConverter.convertToString(
                quality: selectedProductQuality!),
            "escrowPercentage": productCharge.percentage * 100,
            "escrowCharges": escrowCharge,
            "finalPrice": double.parse(price) + escrowCharge,
            "quantity": quantity,
            "pricingImage": productImages,
          };

          if (mounted) {
            Navigator.pop(context, Product.fromJson(json: productJson));
          }
        } else {
          setState(() {
            loading = false;
          });
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }

  Widget pickProductImage() {
    return InkWell(
      onTap: () async {
        final pickedFile =
            await FileManager.pickImage(imageSource: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            images.add(pickedFile.path);
          });
        }
      },
      highlightColor: ColorManager.accentColor.withOpacity(0.3),
      customBorder: const CircleBorder(),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.accentColor.withOpacity(0.2),
        ),
        child: Icon(
          CupertinoIcons.add,
          color: ColorManager.accentColor,
          size: IconSizeManager.medium,
        ),
      ),
    );
  }

  Widget productImage({required final int position}) {
    return OpenContainer(
      closedElevation: 0,
      tappable: !loading,
      transitionDuration: const Duration(milliseconds: 500),
      middleColor: ColorManager.background,
      onClosed: (data) {
        SystemChrome.setSystemUIOverlayStyle(
            ThemeManager.getTransactionScreenUiOverlayStyle());
        setState(
          () {},
        );
      },
      closedBuilder: (context, action) {
        final image = images.elementAtOrNull(position);
        return images.elementAtOrNull(position) == null
            ? pickProductImage()
            : Container(
                width: 70,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeManager.regular * 1.3),
                    image: DecorationImage(
                        image: image!.startsWith('http')
                            ? CachedNetworkImageProvider(image)
                            : FileImage(File(image)),
                        fit: BoxFit.cover)),
              );
      },
      openBuilder: (context, action) {
        return ViewAddedItemsScreen(
          currentPosition: position,
          images: images,
          onRemove: ({required image}) => setState(() => images.remove(image)),
          itemId: widget.product?.id,
        );
      },
    );
  }
}
