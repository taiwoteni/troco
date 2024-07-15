import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/transactions/data/models/driver-details-holder.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/file-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../auth/utils/phone-number-converter.dart';
import '../../../domain/entities/driver.dart';
import '../../../utils/date-input-formatter.dart';
import '../../../utils/date-verification-validation.dart';

class AddDriverDetailsForm extends ConsumerStatefulWidget {
  const AddDriverDetailsForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddDriverDetailsFormState();
}

class _AddDriverDetailsFormState extends ConsumerState<AddDriverDetailsForm> {
  bool loading = false;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  String? plateNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              driverName(),
              mediumSpacer(),
              row(),
              mediumSpacer(),
              destination(),
              mediumSpacer(),
              estimatedDeliveryTime(),
              mediumSpacer(),
              extraLargeSpacer(),
              button(),
              extraLargeSpacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget row() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Plate number",
              style: TextStyle(
                  color: ColorManager.secondary,
                  fontFamily: 'lato',
                  fontSize: FontSizeManager.small * 0.8,
                  fontWeight: FontWeightManager.regular),
            ),
            regularSpacer(),
            plateNumber != null ? plateNumberWidget() : pickPlateNumber()
          ],
        ),
        largeSpacer(),
        Expanded(child: phoneNumber())
      ],
    );
  }

  Widget driverName() {
    return InputFormField(
      label: 'Driver Name',
      validator: (value) {
        if (value == null) {
          return "* enter driver name";
        }
        if (value.trim().isEmpty) {
          return "* enter driver name";
        }
        return null;
      },
      onSaved: (value) {
        DriverDetailsHolder.driverName = value;
      },
      inputType: TextInputType.name,
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "person"),
          fit: BoxFit.cover,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
    );
  }

  Widget companyName() {
    return InputFormField(
      label: 'Company Name',
      validator: (value) {
        if (value == null) {
          return "* enter company name";
        }
        if (value.trim().isEmpty) {
          return "* enter company name";
        }
        return null;
      },
      onSaved: (value) {
        DriverDetailsHolder.companyName = value;
      },
      inputType: TextInputType.name,
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "company-icon"),
          fit: BoxFit.cover,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
    );
  }

  Widget phoneNumber() {
    return InputFormField(
      inputType: TextInputType.phone,
      label: "phone",
      validator: (value) {
        if (value == null) {
          return "* phone number";
        }
        if (value.startsWith("+234") && value.length != 14) {
          return "* phone number";
        }
        if (value.length != 11) {
          return "* phone number";
        }
        return validatePhoneNumber(value.trim()) ? null : "* phone number.";
      },
      onSaved: (value) {
        if (value == null) {
          return;
        }
        DriverDetailsHolder.driverPhoneNumber =
            PhoneNumberConverter.convertToFull(value);
      },
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: Icon(
          CupertinoIcons.phone_solid,
          color: ColorManager.secondary,
        ),
      ),
    );
  }

  Widget pickPlateNumber() {
    return InkWell(
      onTap: () async {
        final pickedFile =
            await FileManager.pickImage(imageSource: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            plateNumber = pickedFile.path;
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
          color: ColorManager.accentColor.withOpacity(0.15),
        ),
        child: Icon(
          CupertinoIcons.add,
          color: ColorManager.accentColor,
          size: IconSizeManager.medium,
        ),
      ),
    );
  }

  Widget destination() {
    return InputFormField(
      label: 'Driver Destination',
      validator: (value) {
        if (value == null) {
          return "* enter destination";
        }
        if (value.trim().isEmpty) {
          return "* enter destination";
        }
        return null;
      },
      onSaved: (value) {
        DriverDetailsHolder.destination = value;
      },
      inputType: TextInputType.streetAddress,
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: Icon(
          CupertinoIcons.location_solid,
          color: ColorManager.secondary,
          // size: const Size.square(IconSizeManager.regular),
        ),
      ),
    );
  }

  Widget plateNumberWidget() {
    return Container(
      width: 70,
      height: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular * 1.3),
          image: DecorationImage(
              image: FileImage(File(plateNumber!)), fit: BoxFit.cover)),
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
            "Add Driver Details",
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
              onPressed: () {
                loading ? null : Navigator.pop(context);
                DriverDetailsHolder.clear();
              },
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

  Widget estimatedDeliveryTime() {
    return InputFormField(
      label: 'Est. Time (DD/MM/YYYY)',
      inputType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10,
            maxLengthEnforcement:
                MaxLengthEnforcement.truncateAfterCompositionEnds),
        DateInputFormatter(),
      ],
      validator: (value) {
        if (value == null) {
          return "* enter date";
        }
        if (value.trim().isEmpty) {
          return "* enter date";
        }
        if (!DateValidator.isValidDate(value.trim(), expritation: true)) {
          return "* enter valid date";
        }
        return null;
      },
      onSaved: (value) {
        DriverDetailsHolder.estimatedDeliveryTime = value;
      },
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: Icon(
          CupertinoIcons.time,
          color: ColorManager.secondary,
        ),
      ),
    );
  }

  Widget button() {
    return CustomButton(
      label: "Add Driver Information",
      buttonKey: buttonKey,
      onPressed: next,
      usesProvider: true,
    );
  }

  Future<void> next() async {
    setState(() => loading = true);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => loading = false);
    if (formKey.currentState!.validate() && plateNumber != null) {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      formKey.currentState!.save();
      DriverDetailsHolder.plateNumber = plateNumber!;
      Navigator.pop(
          context, Driver.fromJson(json: DriverDetailsHolder.toJson()));
      DriverDetailsHolder.clear();
    } else {
      DriverDetailsHolder.clear();
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }

  bool validatePhoneNumber(String phoneNumber) {
    final String number = phoneNumber.trim();
    // Define the regex pattern for a phone number
    RegExp regExp = RegExp(r'^\d{11,14}$');
    // Check if the input matches the regex pattern
    bool is11 = number.length == 11 && !number.contains("+");
    bool is14 = number.length == 14 && number.startsWith("+234");
    bool is13 = number.length == 13 && number.startsWith("234");
    bool is12 = number.length == 12;
    return (regExp.hasMatch(number) || is11 || is14) && !is13 && !is12;
  }
}
