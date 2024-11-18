import 'package:flutter/material.dart';

extension NavigatorExtension on BuildContext {
  Future<T?> pushNamed<T extends Object?>(
      {required final String routeName, final Object? arguments}) {
    return Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?>(
      {required final String routeName, final Object? arguments}) {
    return Navigator.pushReplacementNamed(this, routeName,
        arguments: arguments);
  }

  void pop<T extends Object?>({final T? result}) {
    return Navigator.pop(this, result);
  }
}
