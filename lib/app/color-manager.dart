import 'package:flutter/material.dart';

class ColorManager {
  static Color accentColor = const Color(0xFF109E15);
  static Color themeColor = const Color(0xFF398e3d);
  static Color primaryDark = Colors.white;
  static Color secondaryDark = const Color.fromRGBO(224, 224, 224, 1);
  static Color background = Colors.white;
  static Color primary = Colors.black;
  static Color secondary = Colors.black54;
  static Color tertiary = const Color.fromARGB(243, 250, 247, 247);

  static final List<ColorSwatch> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.yellow,
    Colors.indigo,
    Colors.limeAccent,
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.teal,
    Colors.deepOrange,
    Colors.brown,
  ];

  static final List<Map<String, Color>> colorSet =
      colors.map((color) => {"primary": color, "accent": color[200]!}).toList();

  static String colorToHex(Color color) {
    // Ensure the alpha value is included in the hex representation
    String alpha = color.alpha.toRadixString(16).padLeft(2, '0');
    String red = color.red.toRadixString(16).padLeft(2, '0');
    String green = color.green.toRadixString(16).padLeft(2, '0');
    String blue = color.blue.toRadixString(16).padLeft(2, '0');

    // Combine all components into the hex string
    String hex = '#$alpha$red$green$blue';

    return hex.toUpperCase(); // Convert to uppercase for consistency
  }
}
