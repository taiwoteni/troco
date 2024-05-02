import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class OtpInputField extends ConsumerStatefulWidget {
  final void Function(String value)? onEntered;
  final bool last, first, obscure;
  const OtpInputField(
      {super.key,
      this.onEntered,
      this.obscure = false,
      this.last = false,
      this.first = false});

  @override
  ConsumerState<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends ConsumerState<OtpInputField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 70,
      child: TextFormField(
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: widget.obscure,
        showCursor: false,
        textCapitalization: TextCapitalization.characters,
        cursorColor: ColorManager.themeColor,
        cursorRadius: const Radius.circular(SizeManager.large),
        style: TextStyle(
            color: ColorManager.primary,
            fontFamily: 'Lato',
            fontWeight: FontWeightManager.bold,
            fontSize: FontSizeManager.large),
        textAlign: TextAlign.center,
        textInputAction:
            widget.last ? TextInputAction.go : TextInputAction.next,
        onChanged: (value) {
          if (widget.onEntered != null) {
            widget.onEntered!(value);
          }
          if (value.length == 1) {
            if (!widget.last) {
              FocusScope.of(context).nextFocus();
            }
          } else {
            if (!widget.first) {
              FocusScope.of(context).previousFocus();
            }
          }
        },
        decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: ColorManager.tertiary,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeManager.large * 0.9),
                borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeManager.large * 0.9),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeManager.large * 0.9),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeManager.large * 0.9),
                borderSide:
                    BorderSide(color: ColorManager.themeColor, width: 1.5))),
      ),
    );
  }
}
