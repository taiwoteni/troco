import 'package:flutter/material.dart';

class HomeItemModel{
  final String icon, label;
  final Widget page;

  const HomeItemModel(
      {required this.icon, required this.label, required this.page});
}
