import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/providers/enabled-provider.dart';

class InputFormField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String Function(String? value)? onValidate;
  final void Function(String? value)? onSaved;
  final String label;
  final TextInputType inputType;
  final bool isPassword;
  final Widget prefixIcon;
  const InputFormField({
    super.key,
    this.onValidate,
    this.onSaved,
    required this.label,
    required this.prefixIcon,
    this.inputType = TextInputType.text,
    this.isPassword = false,
    this.controller,
  });

  @override
  ConsumerState<InputFormField> createState() => _InputFormFieldState();
}

class _InputFormFieldState extends ConsumerState<InputFormField> {
  bool obscure = false;
  @override
  void initState() {
    obscure = widget.isPassword ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: widget.onSaved,
      validator: widget.onValidate,
      obscureText: obscure,
      autocorrect: !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      controller: widget.controller,
      cursorColor: ColorManager.themeColor,
      cursorRadius: const Radius.circular(20),
      readOnly: !ref.watch(enabledProvider),
      keyboardType: widget.inputType,
      style: TextStyle(
          color: ColorManager.primary,
          fontSize: FontSizeManager.medium,
          fontWeight: FontWeightManager.medium,

          fontFamily: 'Lato'),
      decoration: InputDecoration(
          prefixIcon: Theme(
              data: ThemeManager.getApplicationTheme()
                  .copyWith(useMaterial3: false),
              child: widget.prefixIcon),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  iconSize: IconSizeManager.regular,
                  icon: Image.asset(
                    AssetManager.iconFile(
                        name: obscure ? 'eyes-opened' : 'eyes-closed'),
                    fit: BoxFit.cover,
                    width: IconSizeManager.regular,
                    height: IconSizeManager.regular,
                    color: ColorManager.themeColor,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: SizeManager.medium * 1.2,
              vertical: SizeManager.medium * 1.4),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: ColorManager.tertiary,
          hintStyle: TextStyle(
              color: ColorManager.secondary,
              fontSize: FontSizeManager.medium,
              fontWeight: FontWeightManager.medium,
              fontFamily: 'Lato'),
          hintText: widget.label,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorManager.themeColor, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(SizeManager.large)),
          border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorManager.themeColor, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(SizeManager.large)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorManager.themeColor, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(SizeManager.large))),
    );
  }
}
