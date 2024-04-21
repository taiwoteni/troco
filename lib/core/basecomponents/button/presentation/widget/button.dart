// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/animations/lottie.dart';

import '../../../../app/color-manager.dart';
import '../provider/button-provider.dart';

class CustomButton extends ConsumerStatefulWidget {
  final UniqueKey? buttonKey;
  final String label;
  final String size;
  final void Function()? onPressed;
  final Color? color;
  final bool usesProvider;
  final EdgeInsets? margin;

  CustomButton({
    super.key,
    required this.label,
    this.buttonKey,
    this.size = "large",
    this.usesProvider = false,
    this.onPressed,
    this.color,
    this.margin,
  }) {
    if (usesProvider) {
      if (buttonKey == null) {
        throw Exception("usesProvider should only be true if a key is given!");
      }
    }
  }

  CustomButton.medium({
    super.key,
    required this.label,
    this.buttonKey,
    this.size = "medium",
    this.usesProvider = false,
    this.onPressed,
    this.margin,
    this.color,

  }) {
    if (usesProvider) {
      if (buttonKey == null) {
        throw Exception("usesProvider should only be true if a key is given!");
      }
    }
  }

  CustomButton.small({
    super.key,
    required this.label,
    this.buttonKey,
    this.size = "small",
    this.usesProvider = false,
    this.onPressed,
    this.color,

    this.margin,
  }) {
    if (usesProvider) {
      if (buttonKey == null) {
        throw Exception("usesProvider should only be true if a key is given!");
      }
    }
  }

  @override
  ConsumerState<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends ConsumerState<CustomButton> {
  @override
  Widget build(BuildContext context) {
    bool usesProvider = widget.usesProvider;
    bool loading = false;
    bool enabled = true;
    if (usesProvider) {
      ButtonProvider(key: widget.buttonKey!);
      //To add this key to button provider
      // Key would be true since useProvider is true and no error is thrown.
      loading =
          ButtonProvider.loadingValue(buttonKey: widget.buttonKey!, ref: ref);
      enabled =
          ButtonProvider.enabledValue(buttonKey: widget.buttonKey!, ref: ref);
    }
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular((widget.size == "medium")
            ? SizeManager.medium
            : widget.size == "small"
                ? SizeManager.regular * 1.2
                : SizeManager.large),
        child: Material(
          child: InkWell(
            onTap: enabled ? widget.onPressed : null,
            splashColor: ColorManager.accentColor,
            splashFactory: InkRipple.splashFactory,
            child: Container(
              key: widget.key,
              width: double.maxFinite,
              height: (widget.size == "medium")
                  ? SizeManager.extralarge * 1.7
                  : (widget.size == "small")
                      ? SizeManager.large * 1.8
                      : SizeManager.extralarge * 2,
              decoration: BoxDecoration(
                  color: !enabled && !loading
                      ? ColorManager.tertiary
                      : widget.color ?? ColorManager.themeColor),
              alignment: Alignment.center,
              child: loading
                  ? LottieWidget(
                      lottieRes: AssetManager.lottieFile(name: 'loading'),
                      size: Size.square(
                          widget.size == "large" || widget.size == "medium"
                              ? IconSizeManager.large
                              : IconSizeManager.large * 0.7),
                      color: Colors.white,
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(
                          color: !enabled
                              ? ColorManager.secondary
                              : ColorManager.primaryDark,
                          fontSize: (widget.size == "medium")
                              ? FontSizeManager.large * 0.7
                              : widget.size == "large"
                                  ? FontSizeManager.large * 0.8
                                  : FontSizeManager.regular * 0.8,
                          fontFamily: 'Lato',
                          fontWeight: FontWeightManager.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
