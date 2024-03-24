import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';

class InputFormField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onSaved;
  final void Function(String value)? onChanged;
  final Future<String?> Function()? onRedirect;
  final String label;
  final String? prefixText,errorText;
  final bool showLeadingIcon, readOnly;
  final TextInputType inputType;
  final bool isPassword;
  final Widget prefixIcon;
  const InputFormField({
    super.key,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.prefixText,
    required this.label,
    required this.prefixIcon,
    this.errorText,
    this.inputType = TextInputType.text,
    this.onRedirect,
    this.showLeadingIcon = false,
    this.readOnly = false,
    this.isPassword = false,
    this.controller,
  });

  @override
  ConsumerState<InputFormField> createState() => _InputFormFieldState();
}

class _InputFormFieldState extends ConsumerState<InputFormField> {
  bool obscure = false;
  late TextEditingController controller;
  @override
  void initState() {
    obscure = widget.isPassword ? true : false;
    controller = widget.controller ?? TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        autofocus: true,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        validator: widget.validator,
        onTap: () async {
          if (widget.onRedirect != null) {
            final s = await widget.onRedirect!();
            setState(() {
              controller.text = s ?? "";
            });
          }
        },
        obscureText: obscure,
        autocorrect: !widget.isPassword,
        enableSuggestions: !widget.isPassword,
        controller: controller,
        cursorColor: ColorManager.themeColor,
        cursorRadius: const Radius.circular(20),
        readOnly: widget.readOnly,
        keyboardType: widget.inputType,
        style: defaultStyle(),
        decoration: InputDecoration(
          prefixIcon: Theme(
              data: ThemeManager.getApplicationTheme()
                  .copyWith(useMaterial3: false),
              child: widget.prefixIcon),
          prefixText: widget.prefixText,
          prefixStyle: defaultStyle().copyWith(color: ColorManager.accentColor),
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
              : widget.showLeadingIcon
                  ? IconButton(
                      onPressed: null,
                      iconSize: IconSizeManager.regular,
                      icon: Icon(
                        Icons.arrow_drop_down_rounded,
                        size: IconSizeManager.regular,
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
          hintStyle: defaultStyle().copyWith(color: ColorManager.secondary),
          hintText: widget.label,
          errorText: widget.errorText,
          errorStyle: defaultStyle().copyWith(
              color: Colors.red,
              fontSize: FontSizeManager.regular),
          errorBorder: defaultBorder(),
          focusedErrorBorder: defaultBorder(),
          enabledBorder: defaultBorder(),
          border: defaultBorder(),
          focusedBorder: defaultBorder(),
        ));
  }

  TextStyle defaultStyle() {
    return TextStyle(
        color: ColorManager.primary,
        fontSize: FontSizeManager.medium,
        fontWeight: FontWeightManager.medium,
        fontFamily: 'Lato');
  }

  InputBorder defaultBorder() {
    return OutlineInputBorder(
        borderSide:
            BorderSide(color: ColorManager.themeColor, style: BorderStyle.none),
        borderRadius: BorderRadius.circular(SizeManager.large));
  }
}
