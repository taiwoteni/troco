import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/welcome-back/widgets/pin-input-widget.dart';
import 'package:troco/features/auth/presentation/welcome-back/widgets/pin-keypad-widget.dart';
import 'package:vibration/vibration.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  String transactionPin = "";
  late AnimationController controller;
  bool animatingRight = false;

  @override
  void setState(VoidCallback fn,
      /// added this default named argument to differentiate
      /// whether the VoidCallback has to do with transactionPin
      {bool pinState = true}) {
    if (!mounted) {
      return;
    }

    // we use [pinState] to determine wether the state has to do with
    // the transaction pin.
    // So using this, we can check and prevent users from typing more than 4 digits.


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
      controller.addStatusListener((status) async {
        if (status == AnimationStatus.completed && !animatingRight) {
          await controller.reverse();
          setState(() => animatingRight = true, pinState: false);
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
          pinInputs(),
          extraLargeSpacer(),
          keyPad(),
        ],
      ),
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
    bool theSame = transactionPin.trim() == "2911";
    if (!theSame) {
      // vibrate
      if (await Vibration.hasVibrator() ?? false) {
        controller.forward();
        Vibration.vibrate(duration: 100);
        setState(() => transactionPin="");
      }
    }
    else{
        Navigator.pushNamedAndRemoveUntil(context, Routes.homeRoute, (route) => false,);

    }
  }
}
