import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/providers/enabled-provider.dart';

import '../app/color-manager.dart';
import '../app/font-manager.dart';
import '../app/theme-manager.dart';

class DropdownInputFormField extends ConsumerStatefulWidget {
  /// The [margin] attribute is used to specify the margin of the
  /// Dropdown Input Field.
  final EdgeInsets? margin;

  /// The [items] should be a list of strings.
  /// The values of the datatypes should be ignored.
  /// This is only used for the "representation" of the items on the dropdown.
  final List<String> items;

  /// The [hint] to be displayed for the dropdown widget.
  final String hint;

  /// The selected [value] of the dropdown widget.
  final String value;

  /// The [prefixIcon] of the dropdown widget.
  /// Can be null if u don't want to show it.
  final Widget? prefixIcon;
  final String Function(dynamic value)? onValidate;

  /// [onChanged] is a callback called whenever the user selects an item.
  /// The [onChanged.value] parameter is String since it's the visual representation
  /// tha the user sees that will be clicked.
  final void Function(String? value)? onChanged;

  const DropdownInputFormField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    this.margin,
    this.prefixIcon,
    this.onValidate,
    this.onChanged,
  });

  @override
  ConsumerState<DropdownInputFormField> createState() =>
      _DropdownInputFormFieldState();
}

class _DropdownInputFormFieldState
    extends ConsumerState<DropdownInputFormField> {
  @override
  Widget build(BuildContext context) {
    final TextStyle hintStyle = TextStyle(
        color: ColorManager.secondary,
        fontSize: FontSizeManager.medium,
        fontWeight: FontWeightManager.medium,
        fontFamily: 'Lato');

    return Container(
      width: double.maxFinite,
      padding: widget.margin == null ? EdgeInsets.zero : widget.margin!,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeManager.large),
      ),
      child: DropdownButtonFormField<String>(
          value: widget.value.trim() == "" ? null : widget.value,
          items: widget.items
              .map((item) => DropdownMenuItem<String>(
                    enabled: ref.watch(enabledProvider),
                    value: item,
                    child: Text(
                      item.toString(),
                      style: hintStyle.copyWith(color: ColorManager.primary),
                    ),
                  ))
              .toList(),
          hint: Text(
            widget.hint,
            style: hintStyle,
          ),
          selectedItemBuilder: (context) => widget.items
              .map((item) => Text(
                    item.toString(),
                    style: hintStyle.copyWith(color: ColorManager.primary),
                  ))
              .toList(),
          isExpanded: true,
          elevation: 1,
          focusColor: Colors.transparent,
          validator: widget.onValidate,
          onChanged: widget.onChanged,
          padding: EdgeInsets.zero,
          decoration: decoration(),
          enableFeedback: ref.watch(enabledProvider),
          isDense: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(SizeManager.large)),
    );
  }

  InputDecoration decoration() {
    return InputDecoration(
        isDense: true,
        enabled: ref.watch(enabledProvider),
        prefixIcon: widget.prefixIcon == null
            ? null
            : Theme(
                data: ThemeManager.getApplicationTheme()
                    .copyWith(useMaterial3: false),
                child: widget.prefixIcon!,
              ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: SizeManager.medium * 1.2,
            vertical: SizeManager.medium * 1.3),
        filled: true,
        fillColor: ColorManager.tertiary,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorManager.themeColor, style: BorderStyle.none),
            borderRadius: BorderRadius.circular(SizeManager.large)),
        disabledBorder: OutlineInputBorder(
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
            borderRadius: BorderRadius.circular(SizeManager.large)));
  }
}
