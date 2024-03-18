import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
class AppPlatform{
  final BuildContext _context;
  AppPlatform(BuildContext context):_context = context;

  static bool isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  static bool isDesktop = kIsWeb || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.fuchsia;
  static bool isAndroid = defaultTargetPlatform == TargetPlatform.android;
  static bool isIos = defaultTargetPlatform == TargetPlatform.iOS;


  bool get isTablet{
    final double longestSide = MediaQuery.of(_context).size.longestSide;
    return longestSide>600 && isMobile;
  }
}