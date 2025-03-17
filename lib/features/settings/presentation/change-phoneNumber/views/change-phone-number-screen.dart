import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/otp/views/otp-screen.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/auth/utils/phone-number-converter.dart';
import 'package:troco/features/settings/domain/repository/settings-repository.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../auth/data/models/login-data.dart';
import '../../../../auth/data/models/otp-data.dart';

class ChangePhoneNumberScreen extends ConsumerStatefulWidget {
  const ChangePhoneNumberScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePhoneNumberScreenState();
}

class _ChangePhoneNumberScreenState
    extends ConsumerState<ChangePhoneNumberScreen> {
  final Color infoColor = ColorManager.accentColor;
  final formKey = GlobalKey<FormState>();
  final UniqueKey buttonKey = UniqueKey();

  late String newChangedPhoneNumber;

  String? phoneNumberError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        backgroundColor: ColorManager.background,
        resizeToAvoidBottomInset: false,
        appBar: appBar(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                largeSpacer(),
                oldPhoneNumber(),
                mediumSpacer(),
                newPhoneNumber(),
                smallSpacer(),
                newPhoneNumberGuidelines(),
                mediumSpacer(),
                password(),
                extraLargeSpacer(),
                button(),
                largeSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(72 + MediaQuery.of(context).viewPadding.top),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Change Phone Number",
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

  Widget newPhoneNumberGuidelines() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SizeManager.small,
              horizontal: SizeManager.medium * 1.5),
          child: InfoText(
            text: "* should be a valid phone number.",
            color: (phoneNumberError?.contains("valid") ?? false)
                ? Colors.red
                : ColorManager.secondary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
                  vertical: SizeManager.small, horizontal: SizeManager.medium) *
              1.5,
          child: InfoText(
            text: "* should be unique (i.e not have been registered with).",
            color: (phoneNumberError?.contains("exists") ?? false)
                ? Colors.red
                : ColorManager.secondary,
          ),
        ),
      ],
    );
  }

  Widget oldPhoneNumber() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Old Phone Number",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            label: 'Type in your old number',
            inputType: TextInputType.phone,
            validator: (value) {
              if (value == null) {
                return "* enter old number";
              }
              if (value.trim().isEmpty) {
                return "* enter old number";
              }
              if (PhoneNumberConverter.convertToFull(value.trim()) !=
                  ClientProvider.readOnlyClient!.phoneNumber) {
                return "* wrong number";
              }
              return null;
            },
            onSaved: (value) {},
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget newPhoneNumber() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "New Phone Number",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            label: 'Type in the new number',
            inputType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                setState(() {
                  phoneNumberError = "enter valid number";
                });
                return null;
              }
              if (!validatePhoneNumber(value)) {
                setState(() {
                  phoneNumberError = "enter valid number";
                });
              }
              setState(() {
                phoneNumberError = null;
              });

              return null;
            },
            onSaved: (value) {
              setState(() => newChangedPhoneNumber =
                  PhoneNumberConverter.convertToFull(value!));
            },
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget password() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Password",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            label: 'Type in your password',
            isPassword: true,
            inputType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null) {
                return "* enter password";
              }
              if (value.trim().isEmpty) {
                return "* enter password";
              }

              if (value.trim() != ClientProvider.readOnlyClient!.password) {
                return "* wrong password";
              }

              return null;
            },
            onSaved: (value) {},
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget button() {
    return CustomButton(
      onPressed: changePhoneNumber,
      label: "Change",
      buttonKey: buttonKey,
      usesProvider: true,
      margin: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
    );
  }

  Future<void> changePhoneNumber() async {
    setState(() => phoneNumberError = null);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    if (formKey.currentState!.validate() && phoneNumberError == null) {
      formKey.currentState!.save();
      final response = await SettingsRepository.changePhoneNumber(
          newPhoneNumber: newChangedPhoneNumber);
      debugPrint(response.body);
      if (response.error) {
        if (response.messageBody?["message"].toString().contains("exists") ??
            false) {
          setState(() {
            phoneNumberError = response.messageBody?["message"];
          });
        }
        SnackbarManager.showErrorSnackbar(
            context: context, message: "Error occurred");
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        return;
      }
      OtpData.clear();
      OtpData.phoneNumber = newChangedPhoneNumber;
      LoginData.otp = response.messageBody?["otp"];
      final verified = (await Navigator.pushNamed(context, Routes.otpRoute,
              arguments: OtpVerificationType.Update) as bool?) ??
          false;

      if (verified) {
        final client = AppStorage.getUser()!.toJson();
        client["phoneNumber"] = newChangedPhoneNumber;
        AppStorage.saveClient(client: Client.fromJson(json: client));
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Successfully changed your phone number");
        context.pop();
        return;
      }
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Otp validation failed");
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    } else {
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
