import 'dart:io';

class SizeManager {
  /// The [small] size is the smallest size. It is 4.0 by default
  static const double small = 4.0;

  /// The [regular] size is the secondt to the smallest size. It is 8.0 by default
  static const double regular = 8.0;

  /// The [medium] size is the medium size. It is 16.0 by default
  static const double medium = 16.0;

  /// The [large] size is the second to the largest size. It is 20.0 by default
  static const double large = 20.0;

  /// The [extralarge] size is the largest size. It is 32.0 by default
  static const double extralarge = 32.0;

  /// The [bottomBarHeight] is the height of the HomeScreen's bottom bar.
  /// It is 65.0 by default.
  static double bottomBarHeight = Platform.isIOS ? 75 : 68.0;
}

class IconSizeManager {
  /// The [small] size is the smallest icon size. It is 16.0 by default
  static const double small = 16.0;

  /// The [regular] size is the largest size. It is 20.0 by default
  static const double regular = 20.0;

  /// The [medium] size is the largest size. It is 30.0 by default
  static const double medium = 30.0;

  /// The [large] size is the largest size. It is 50.0 by default
  static const double large = 50.0;

  /// The [extralarge] size is the largest size. It is 65.0 by default
  static const double extralarge = 65;
}

const double defaultSize = SizeManager.medium;
