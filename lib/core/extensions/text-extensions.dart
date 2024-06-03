import 'package:flutter/material.dart';

extension FontExtension on Text {
  Text lato() => Text(
        data ?? "",
        style: style?.copyWith(fontFamily: "Lato") ??
            const TextStyle(fontFamily: "lato"),
      );

  Text quicksand() => Text(
        data ?? "",
        style: style?.copyWith(fontFamily: "Quicksand") ??
            const TextStyle(fontFamily: "quicksand"),
      );
}
