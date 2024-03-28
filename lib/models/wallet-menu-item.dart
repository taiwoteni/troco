import 'package:flutter/material.dart';

class WalletMenuItem{
  final String svgRes, label;
  final Color? color;
  final void Function()? onClick;

  const WalletMenuItem({required this.svgRes, required this.label,this.color, this.onClick});
}