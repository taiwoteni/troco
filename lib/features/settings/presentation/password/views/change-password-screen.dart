import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
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
import '../../../../auth/domain/entities/client.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final Color infoColor = ColorManager.accentColor;
  final formKey = GlobalKey<FormState>();
  final UniqueKey buttonKey = UniqueKey();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool passwordValidationError = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }

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
                oldPassword(),
                mediumSpacer(),
                forgotPassword(),
                mediumSpacer(),
                newPassword(),
                mediumSpacer(),
                newPasswordGuidelines(),
                mediumSpacer(),
                confirmPassword(),
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
                  "Change Password",
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

  Widget oldPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Old Password",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            label: 'Type in your old password',
            isPassword: true,
            inputType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null) {
                return "* enter old password";
              }
              if (value.trim().isEmpty) {
                return "* enter old password";
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

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: InfoText(
        onPressed: () =>
            Navigator.pushNamed(context, Routes.forgotPasswordRoute),
        text: "Forgot Password?",
        alignment: Alignment.centerRight,
        fontWeight: FontWeightManager.semibold,
      ),
    );
  }

  Widget newPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "New Password",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            controller: newPasswordController,
            label: 'Type in the new password',
            isPassword: true,
            inputType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                setState(() {
                  passwordValidationError = true;
                });
                return null;
              }
              setState(() {
                passwordValidationError = !validatePassword(value);
              });

              return null;
            },
            onSaved: (value) {},
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget newPasswordGuidelines() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SizeManager.small,
              horizontal: SizeManager.medium * 1.5),
          child: InfoText(
            text: "* should be at least 8 digits in length.",
            color:
                passwordValidationError ? Colors.red : ColorManager.secondary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
                  vertical: SizeManager.small, horizontal: SizeManager.medium) *
              1.5,
          child: InfoText(
            text: "* should have at least a number and a letter.",
            color:
                passwordValidationError ? Colors.red : ColorManager.secondary,
          ),
        ),
      ],
    );
  }

  Widget confirmPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Confirm Password",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            controller: confirmPasswordController,
            label: 'Retype the new password',
            isPassword: true,
            inputType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null) {
                return "* confirm new password";
              }
              if (value.trim().isEmpty) {
                return "* confirm new password";
              }
              if (value != newPasswordController.text.trim()) {
                return "* passwords don't match";
              }
              return null;
            },
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  bool validatePassword(String input) {
    RegExp regExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return regExp.hasMatch(input);
  }

  Widget button() {
    return CustomButton(
      onPressed: changePassword,
      label: "Change",
      buttonKey: buttonKey,
      usesProvider: true,
      margin: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
    );
  }

  Future<void> changePassword() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    if (formKey.currentState!.validate() && !passwordValidationError) {
      final response = await SettingsRepository.updatePassword(
          userId: ClientProvider.readOnlyClient!.userId,
          oldPassword: ClientProvider.readOnlyClient!.password!,
          newPassword: newPasswordController.text.trim());
      log(response.body);

      if (!response.error) {
        final clientJson = ClientProvider.readOnlyClient!.toJson();
        clientJson["password"] = newPasswordController.text.trim();

        AppStorage.saveClient(client: Client.fromJson(json: clientJson));
        SnackbarManager.showBasicSnackbar(
            context: context, message: "Updated password successfully!");
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        Navigator.pop(context);
      } else {
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "Failed update password");
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
