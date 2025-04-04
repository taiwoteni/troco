import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';

class InputFormField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onSaved;
  final void Function(String value)? onChanged;
  final Future<String?> Function()? onRedirect;
  final List<TextInputFormatter>? inputFormatters;
  final String label;
  final String? initialValue;
  final int lines;
  final String? prefixText, errorText;
  final bool showtrailingIcon, readOnly;
  final TextInputType inputType;
  final bool isPassword;
  final Widget? prefixIcon, suffixIcon;
  const InputFormField({
    super.key,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.prefixText,
    required this.label,
    required this.prefixIcon,
    this.inputFormatters,
    this.initialValue,
    this.suffixIcon,
    this.lines = 1,
    this.errorText,
    this.inputType = TextInputType.text,
    this.onRedirect,
    this.showtrailingIcon = false,
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
    controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ColorManager.accentColor,
          selectionColor: ColorManager.accentColor.withOpacity(0.2),
          selectionHandleColor: ColorManager.accentColor,
        ),
      ),
      child: TextFormField(
          autofocus: false,
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
          inputFormatters: widget.inputFormatters,
          // minLines: widget.lines,
          minLines: widget.lines == 1 ? 1 : widget.lines,
          maxLines: widget.lines == 1 ? 1 : null,
          obscureText: obscure,
          autocorrect: !widget.isPassword,
          enableSuggestions: !widget.isPassword,
          controller: controller,
          cursorColor: ColorManager.themeColor,
          cursorRadius: const Radius.circular(20),
          readOnly: widget.readOnly,
          textInputAction: widget.lines > 1 ? TextInputAction.newline : null,
          keyboardType:
              widget.lines > 1 ? TextInputType.multiline : widget.inputType,
          style: defaultStyle(),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon != null
                ? Theme(
                    data: ThemeManager.getApplicationTheme()
                        .copyWith(useMaterial3: false),
                    child: widget.prefixIcon!)
                : null,
            prefixText: widget.prefixText,
            prefixStyle:
                defaultStyle().copyWith(color: ColorManager.accentColor),
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
                : widget.showtrailingIcon
                    ? IconButton(
                        onPressed: null,
                        iconSize: IconSizeManager.regular,
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          size: IconSizeManager.regular,
                          color: ColorManager.themeColor,
                        ),
                      )
                    : widget.suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: SizeManager.medium * 1.2,
                vertical: SizeManager.medium * 1.4),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: ColorManager.tertiary,
            hintStyle: defaultStyle().copyWith(color: ColorManager.secondary),
            hintText: widget.label,
            hintMaxLines: widget.lines,
            errorText: widget.errorText,
            errorStyle: defaultStyle()
                .copyWith(color: Colors.red, fontSize: FontSizeManager.regular),
            errorBorder: defaultBorder(),
            focusedErrorBorder: defaultBorder(),
            enabledBorder: defaultBorder(),
            border: defaultBorder(),
            focusedBorder: defaultBorder(),
          )),
    );
  }

  TextStyle defaultStyle() {
    return TextStyle(
        color: ColorManager.primary,
        fontSize: widget.prefixIcon == null
            ? FontSizeManager.medium * 0.8
            : FontSizeManager.medium,
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
