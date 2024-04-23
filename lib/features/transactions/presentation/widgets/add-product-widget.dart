// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/basecomponents/texts/inputs/dropdown-input-field.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/presentation/providers/product-images-provider.dart';
import 'package:troco/features/transactions/presentation/views/view-added-products-screen.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/product-condition-converter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/button/presentation/provider/button-provider.dart';
import '../../../../core/basecomponents/button/presentation/widget/button.dart';
import '../../../../core/basecomponents/others/drag-handle.dart';
import '../../../../core/basecomponents/others/spacer.dart';
import '../../../../core/basecomponents/texts/inputs/text-form-field.dart';
import '../../../../core/basecomponents/texts/outputs/info-text.dart';
import '../../data/models/create-transaction-data-holder.dart';

class AddProductWidget extends ConsumerStatefulWidget {
  const AddProductWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddProductWidgetState();
}

class _AddProductWidgetState extends ConsumerState<AddProductWidget> {
  ProductCondition? selectedProductCondition;
  int quantity = 1;
  bool productImageError = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  String price = "";
  String name = "";

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ref.watch(productImagesProvider.notifier).state.clear();
    });
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
            "Add ${category == TransactionCategory.Product ? "Product" : "Service"}",
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
              onPressed: () => Navigator.pop(context),
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
          text:
              " ${category.name}${category == TransactionCategory.Virtual ? "-Service" : ""} Name",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          label: 'e.g "iPhone 13"',
          validator: (value) {
            if (value == null) {
              return "* enter a product name";
            }
            if (value.trim().isEmpty) {
              return "* enter a product name";
            }
            if (value.trim().length <= 4) {
              return "* should be at least 4 digits";
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
    final TransactionCategory category =
        TransactionDataHolder.transactionCategory ??
            TransactionCategory.Product;
    return Column(
      children: [
        InfoText(
          text:
              " ${category.name}${category == TransactionCategory.Virtual ? "-Service" : ""} Condition",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        DropdownInputFormField(
          items:
              ProductCondition.values.map((e) => e.name.toLowerCase()).toList(),
          value: selectedProductCondition?.name.toLowerCase() ?? "",
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedProductCondition =
                  ProductConditionConverter.convertToEnum(condition: value));
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
          label: 'NGN',
          inputType: TextInputType.phone,
          validator: (value) {
            if (value == null) {
              return "* enter price";
            }
            if (value.trim().isEmpty) {
              return "* enter price";
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
              return "* enter valid price";
            }
            return null;
          },
          onSaved: (value) {
            setState(() => price = value?.toString() ?? "");
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
    final List<String> productImages = ref.watch(productImagesProvider);
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
              if (productImages.isEmpty)
                pickProductImage()
              else
                productImage(position: 0),
              if (productImages.isEmpty || productImages.length < 2)
                pickProductImage()
              else
                productImage(position: 1),
              if (productImages.isEmpty || productImages.length < 3)
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
    final TransactionCategory category =
        TransactionDataHolder.transactionCategory ??
            TransactionCategory.Product;
    return CustomButton.medium(
      label:
          "Add ${category.name}${category == TransactionCategory.Virtual ? "-Service" : ""}",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          productImageError = ref.read(productImagesProvider).isEmpty;
        });
        if (formKey.currentState!.validate() && !productImageError) {
          formKey.currentState!.save();
          final productImages = List.from(ref.read(productImagesProvider));
          Map<dynamic, dynamic> productJson = {
            "productId": const Uuid().v4(),
            "productName": name,
            "productPrice": double.parse(price),
            "productCondition": selectedProductCondition!.name.toLowerCase(),
            "quantity": quantity,
            "productImages": productImages,
          };
          Navigator.pop(context, Product.fromJson(json: productJson));
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
            ref.read(productImagesProvider.notifier).state.add(pickedFile.path);
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
      transitionDuration: const Duration(milliseconds: 500),
      middleColor: ColorManager.background,
      onClosed: (data) {
        SystemChrome.setSystemUIOverlayStyle(
            ThemeManager.getTransactionScreenUiOverlayStyle());
      },
      closedBuilder: (context, action) {
        return Container(
          width: 70,
          height: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeManager.regular * 1.3),
              image: DecorationImage(
                  image: FileImage(
                      File(ref.watch(productImagesProvider)[position])),
                  fit: BoxFit.cover)),
        );
      },
      openBuilder: (context, action) {
        return ViewAddedProductsScreen(
          currentPosition: position,
        );
      },
    );
  }
}
