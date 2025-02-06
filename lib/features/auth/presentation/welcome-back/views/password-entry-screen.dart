import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../providers/client-provider.dart';

class PasswordEntryScreen extends ConsumerStatefulWidget {
  const PasswordEntryScreen({super.key});

  @override
  ConsumerState<PasswordEntryScreen> createState() =>
      _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends ConsumerState<PasswordEntryScreen> {
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.background,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
                top: MediaQuery.viewPaddingOf(context).top + SizeManager.medium,
                left: SizeManager.extralarge,
                child: header()),
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  title(),
                  extraLargeSpacer(),
                  regularSpacer(),
                  passwordInput(),
                  regularSpacer(),
                  forgotPassword(),
                  largeSpacer(),
                  button(),
                  extraLargeSpacer(),
                  logout(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    if (formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, Routes.homeRoute);
    }
  }

  Widget header() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(SizeManager.regular),
      child: Row(
        children: [
          Image.asset(
            AssetManager.imageFile(name: "troco"),
            width: 110,
            height: 28,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  Widget title() {
    final client = ref.watch(ClientProvider.userProvider)!;
    final defaultStyle = TextStyle(
        color: ColorManager.secondary,
        fontWeight: FontWeightManager.medium,
        fontSize: FontSizeManager.medium * 1.2,
        fontFamily: "lato");
    return RichText(
        text: TextSpan(style: defaultStyle, children: [
      const TextSpan(text: "Welcome back, "),
      TextSpan(
          text: client.firstName,
          style: defaultStyle.copyWith(
              color: ColorManager.primary, fontWeight: FontWeightManager.bold))
    ]));
  }

  Widget passwordInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: InputFormField(
        label: "Enter Password",
        onChanged: (value) {
          if (value.trim().length >= 8) {
            ButtonProvider.enable(buttonKey: buttonKey, ref: ref);
          } else {
            ButtonProvider.enable(buttonKey: buttonKey, ref: ref);
          }
        },
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
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Image.asset(
            AssetManager.iconFile(name: "padlock"),
            color: ColorManager.themeColor,
            fit: BoxFit.contain,
          ),
        ),
        inputType: TextInputType.visiblePassword,
        isPassword: true,
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

  Widget button() {
    return CustomButton(
        buttonKey: buttonKey,
        onPressed: signIn,
        usesProvider: true,
        margin:
            const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
        label: "Sign In");
  }

  Widget logout() {
    final style = TextStyle(
        fontFamily: 'Lato',
        color: ColorManager.primary,
        fontSize: FontSizeManager.regular * 1.1,
        fontWeight: FontWeightManager.semibold);
    final client = ClientProvider.readOnlyClient!;
    return RichText(
      text: TextSpan(style: style, children: [
        TextSpan(text: "Not ${client.firstName}? "),
        TextSpan(
          text: "Change Account",
          style: style.copyWith(color: ColorManager.accentColor),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushReplacementNamed(context, Routes.authRoute);
            },
        )
      ]),
    );
  }
}
