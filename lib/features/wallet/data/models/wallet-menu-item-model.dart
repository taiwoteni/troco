import 'package:flutter/material.dart';

class WalletMenuItemModel {
  final String svgRes, label;
  final Color? color;
  final void Function()? onClick;

  const WalletMenuItemModel(
      {required this.svgRes, required this.label, this.color, this.onClick});
}
