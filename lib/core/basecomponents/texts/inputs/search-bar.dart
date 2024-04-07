import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';

class SearchBarWidget extends StatefulWidget {
  final String label;
  final EdgeInsetsGeometry? margin;
  final void Function(String value)? onChanged;
  const SearchBarWidget(
      {super.key, required this.label, this.margin, required this.onChanged});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: TextField(
        controller: controller,
        cursorColor: Colors.white,
        cursorRadius: const Radius.circular(10),
        style: const TextStyle(
            fontFamily: 'Lato',
            color: Colors.white,
            fontSize: FontSizeManager.regular,
            fontWeight: FontWeightManager.semibold),
        onChanged: widget.onChanged,
        maxLines: 1,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: SizeManager.regular, vertical: SizeManager.medium),
            fillColor: Colors.white.withOpacity(0.2),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: Colors.white,
              size: IconSizeManager.regular,
            ),
            hintText: widget.label,
            hintStyle: TextStyle(
                fontSize: FontSizeManager.regular,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeightManager.semibold),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeManager.medium),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SizeManager.medium),
                borderSide: BorderSide.none)),
      ),
    );
  }
}
