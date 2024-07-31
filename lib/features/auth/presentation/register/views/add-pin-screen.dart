import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/texts/inputs/otp-input-field.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import '../../../domain/entities/client.dart';
import '../../success/views/auth-success-screen.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';

class SetTransactionPinScreen extends ConsumerStatefulWidget {
  const SetTransactionPinScreen({super.key});

  @override
  ConsumerState<SetTransactionPinScreen> createState() =>
      _SetTransactionPinScreenState();
}

class _SetTransactionPinScreenState
    extends ConsumerState<SetTransactionPinScreen> {
  final UniqueKey key = UniqueKey();
  bool registerSuccess = false;
  String pin1 = "", pin2 = "", pin3 = "", pin4 = "";

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSystemUiOverlayStyle());
      ButtonProvider.disable(buttonKey: key, ref: ref);
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
    if (pin1.isNotEmpty &&
        pin2.isNotEmpty &&
        pin3.isNotEmpty &&
        pin4.isNotEmpty) {
      ButtonProvider.enable(buttonKey: key, ref: ref);
    } else {
      ButtonProvider.disable(buttonKey: key, ref: ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return registerSuccess
        ? const AuthSuccessScreen()
        : Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Scaffold(
              appBar: appBar(),
              resizeToAvoidBottomInset: false,
              backgroundColor: ColorManager.background,
              body: SingleChildScrollView(
                child: Center(
                  child: Form(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      titleWidget(),
                      mediumSpacer(),
                      descriptionWidget(),
                      mediumSpacer(),
                      pinRow(),
                      mediumSpacer(),
                      finishButton()
                    ],
                  )),
                ),
              ),
            ),
          );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                FocusScope(
                  canRequestFocus: false,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    iconSize: 40,
                    icon: SvgIcon(
                      svgRes: AssetManager.svgFile(name: 'back'),
                      fit: BoxFit.cover,
                      color: ColorManager.themeColor,
                      size: const Size.square(40),
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  "Create pin",
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

  Widget titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: Text(
        "Transaction Pin",
        textAlign: TextAlign.start,
        style: TextStyle(
            fontFamily: 'Lato',
            color: ColorManager.primary,
            fontSize: FontSizeManager.extralarge,
            fontWeight: FontWeightManager.extrabold),
      ),
    );
  }

  Widget descriptionWidget() {
    final TextStyle defaultStyle = TextStyle(
        fontFamily: 'Lato',
        height: 2,
        color: ColorManager.secondary,
        fontSize: FontSizeManager.medium,
        fontWeight: FontWeightManager.semibold);
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(style: defaultStyle, children: [
          const TextSpan(text: "Enter your "),
          TextSpan(
              text: "private transaction pin.\n",
              style: defaultStyle.copyWith(
                  color: ColorManager.accentColor,
                  fontWeight: FontWeightManager.bold)),
          const TextSpan(text: "It's used to verify you during transactions.")
        ]),
      ),
    );
  }

  Widget pinRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OtpInputField(
            obscure: true,
            first: true,
            onEntered: (value) {
              setState(() => pin1 = value);
            },
          ),
          OtpInputField(
            obscure: true,
            onEntered: (value) {
              setState(() => pin2 = value);
            },
          ),
          OtpInputField(
            obscure: true,
            onEntered: (value) {
              setState(() => pin3 = value);
            },
          ),
          OtpInputField(
            obscure: true,
            last: true,
            onEntered: (value) {
              setState(() => pin4 = value);
            },
          )
        ],
      ),
    );
  }

  Widget finishButton() {
    return CustomButton(
      buttonKey: key,
      onPressed: setupAccount,
      label: "SET",
      usesProvider: true,
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManager.large, vertical: SizeManager.medium),
    );
  }

  Future<void> setupAccount() async {
    ButtonProvider.startLoading(buttonKey: key, ref: ref);
    LoginData.transactionPin = pin1 + pin2 + pin3 + pin4;
    final pinResponse = await AuthenticationRepo.addTransactionPin(
        userId: LoginData.id!, pin: LoginData.transactionPin!);
    log(pinResponse.body);
    final response = await AuthenticationRepo.updateUser(
        userId: LoginData.id!, body: LoginData.toClientJson());
    final userResponse = await ApiInterface.findUser(userId: LoginData.id!);
    log(response.messageBody.toString());
    if (!response.error && !userResponse.error) {
      AppStorage.saveClient(
          client: Client.fromJson(json: userResponse.messageBody!["data"]));
      setState(() => registerSuccess = true);
    } else {
      ButtonProvider.stopLoading(buttonKey: key, ref: ref);
      log(response.messageBody.toString());
    }
  }
}
