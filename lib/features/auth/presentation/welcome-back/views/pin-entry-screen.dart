import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/auth/presentation/welcome-back/provider/loading-provider.dart';
import 'package:troco/features/auth/presentation/welcome-back/widgets/pin-input-widget.dart';
import 'package:troco/features/auth/presentation/welcome-back/widgets/pin-keypad-widget.dart';
import 'package:vibration/vibration.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen>
    with TickerProviderStateMixin {
  String transactionPin = "";
  late AnimationController controller;
  bool animatingRight = false;
  bool loading = false;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);

    if (transactionPin.length == 4) {
      validate();
    }
  }

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSplashUiOverlayStyle());

      // Logic to shake the pin row.
      controller.addStatusListener((status) async {
        if (status == AnimationStatus.completed && !animatingRight) {
          await controller.reverse();
          setState(() => animatingRight = true);
          controller.forward();
        } else if (status == AnimationStatus.completed && animatingRight) {
          await controller.reverse();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: ColorManager.themeColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          label(),
          largeSpacer(),
          pinInputs(),
          extraLargeSpacer(),
          keyPad(),
          extraLargeSpacer(),
          changeAccount(),
        ],
      ),
    );
  }

  Widget label() {
    return const Text(
      "Enter Transaction Pin",
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: 'lato',
          color: Colors.white,
          fontSize: FontSizeManager.medium,
          fontWeight: FontWeightManager.semibold),
    );
  }

  Widget pinInputs() {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Padding(
            padding: EdgeInsets.only(
              left: animatingRight
                  ? controller.value * SizeManager.extralarge
                  : 0,
              right: !animatingRight
                  ? controller.value * SizeManager.extralarge
                  : 0,
            ),
            child: child,
          );
        },
        child: PinInputWidget(pinsEntered: transactionPin.length));
  }

  Widget changeAccount() {
    const style = TextStyle(
        fontFamily: 'lato',
        color: Colors.white70,
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.regular);

    return RichText(
      text: TextSpan(style: style, children: [
        const TextSpan(text: "Not You?  "),
        TextSpan(
            text: "Change Account",
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeightManager.semibold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.authRoute,
                  (route) => false,
                );
              })
      ]),
      textAlign: TextAlign.center,
    );
  }

  Widget keyPad() {
    final keys = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...keys.getRange(0, 3).map(
                    (e) => PinKeypadWidget(
                        onTap: () => setState(() =>
                            transactionPin = transactionPin + e.toString()),
                        text: e.toString()),
                  ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...keys.getRange(3, 6).map(
                    (e) => PinKeypadWidget(
                        onTap: () => setState(() =>
                            transactionPin = transactionPin + e.toString()),
                        text: e.toString()),
                  ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...keys.getRange(6, 9).map(
                    (e) => PinKeypadWidget(
                        onTap: () => setState(() =>
                            transactionPin = transactionPin + e.toString()),
                        text: e.toString()),
                  ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filled(
                  style: const ButtonStyle(
                      fixedSize: WidgetStatePropertyAll(Size.square(73)),
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.transparent),
                      shape: WidgetStatePropertyAll(CircleBorder())),
                  onPressed: () => setState(() => transactionPin = ""),
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: Colors.white,
                    size: IconSizeManager.medium * 0.8,
                  )),
              PinKeypadWidget(
                  onTap: () =>
                      setState(() => transactionPin = "${transactionPin}0"),
                  text: 0.toString()),
              IconButton.filled(
                  style: const ButtonStyle(
                      fixedSize: WidgetStatePropertyAll(Size.square(73)),
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.transparent),
                      shape: WidgetStatePropertyAll(CircleBorder())),
                  onPressed: () => setState(() => transactionPin =
                      transactionPin.trim().isEmpty
                          ? ""
                          : transactionPin.substring(
                              0, transactionPin.length - 1)),
                  icon: const Icon(
                    Icons.backspace_rounded,
                    color: Colors.white,
                    size: IconSizeManager.medium * 0.8,
                  )),
            ],
          )
        ],
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount keyPadDelegate() {
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: SizeManager.medium,
      mainAxisSpacing: SizeManager.medium,
    );
  }

  Future<void> validate() async {
    bool theSame = false;
    if (ClientProvider.readOnlyClient!.transactionPin == null) {
      ref.watch(loadingProvider.notifier).state!.repeat(reverse: true);
      final response = await AuthenticationRepo.verifyTransactionPin(
          transactionPin: transactionPin);
      log(response.body);
      ref.watch(loadingProvider)!.reset();
      theSame = !response.error;
      if (theSame) {
        final json = ClientProvider.readOnlyClient!.toJson();
        json["transactionPin"] = transactionPin;
        ClientProvider.saveUserData(ref: ref, json: json);
        ref.watch(clientProvider.notifier).state = Client.fromJson(json: json);
      }
    } else {
      theSame = transactionPin == ClientProvider.readOnlyClient!.transactionPin;
    }

    if (theSame) {
      // vibrate
      if (await Vibration.hasVibrator() ?? false) {
        controller.forward();
        Vibration.vibrate(duration: 100);
        setState(() => transactionPin = "");
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.homeRoute,
        (route) => false,
      );
    }
  }
}
