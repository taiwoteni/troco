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
import 'package:troco/core/components/texts/inputs/dropdown-input-field.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/product-images-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/transactions/utils/virtual-service-requirement-converter.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../views/view-added-products-screen.dart';

class AddVirtualServiceWidget extends ConsumerStatefulWidget {
  const AddVirtualServiceWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddVirtualServiceWidgetState();
}

class _AddVirtualServiceWidgetState extends ConsumerState<AddVirtualServiceWidget> {
  VirtualServiceRequirement? selectedRequirement;
  int quantity = 1;
  bool productImageError = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String price = "";
  String name = "";

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

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
              serviceName(),
              mediumSpacer(),
              regularSpacer(),
              serviceRequirements(),
              mediumSpacer(),
              regularSpacer(),
              servicePrice(),
              mediumSpacer(),
              regularSpacer(),
              serviceQuantity(),
              mediumSpacer(),
              regularSpacer(),
              uploadDocument(),
              largeSpacer(),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            "Add Virtual Service",
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
              onPressed: () => loading ? null : Navigator.pop(context),
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

  Widget serviceName() {
    return Column(
      children: [
        InfoText(
          text: "Service Name",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          label: 'name of service',
          validator: (value) {
            if (value == null) {
              return "* enter a service name";
            }
            if (value.trim().isEmpty) {
              return "* enter a service name";
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

  Widget serviceRequirements() {
    return Column(
      children: [
        InfoText(
          text: "Service Requirement",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        DropdownInputFormField(
          items: VirtualServiceRequirement.values.map((e) => e.name).toList(),
          value: selectedRequirement == null ? "" : selectedRequirement!.name,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedRequirement =
                    VirtualServiceRequirementsConverter.convertToEnum(
                        requirement: value);
              });
            }
          },
          hint: 'e.g "Exchange"',
          onValidate: (value) {
            if (value == null) {
              return "* enter service type";
            }
            if (value.trim().isEmpty) {
              return "* enter service type";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget servicePrice() {
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

  Widget serviceQuantity() {
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

  Widget uploadDocument() {
    final List<String> productImages = ref.watch(productImagesProvider);
    return Column(
      children: [
        InfoText(
          text: " Upload Document Files",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InfoText(
          text: " (Each document should be clear and have a max size of 2MB)",
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
                pickServiceImage()
              else
                serviceImage(position: 0),
              if (productImages.isEmpty || productImages.length < 2)
                pickServiceImage()
              else
                serviceImage(position: 1),
              if (productImages.isEmpty || productImages.length < 3)
                pickServiceImage()
              else
                serviceImage(position: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget button() {
    return CustomButton.medium(
      label: "Add Virtual Service",
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
          productImageError = ref.read(productImagesProvider).isEmpty;
        });
        if (formKey.currentState!.validate() && !productImageError) {
          formKey.currentState!.save();
          final serviceImages = List.from(ref.read(productImagesProvider));
          Map<dynamic, dynamic> serviceJson = {
            "serviceId": const Uuid().v4(),
            "serviceName": name,
            "servicePrice": int.parse(price),
            "serviceRequirement": selectedRequirement!.name,
            "quantity": quantity,
            "pricingImage": serviceImages[0],
          };
          if (mounted) {
            Navigator.pop(context, VirtualService.fromJson(json: serviceJson));
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

  Widget pickServiceImage() {
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

  Widget serviceImage({required final int position}) {
    return OpenContainer(
      closedElevation: 0,
      tappable: !loading,
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
