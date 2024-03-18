import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [_buttonProviders] is used to store the list of states used for the buttons.
List<StateProvider<bool>> _buttonProviders = [];

/// [_buttonKeys] is used to store the list of keys used for the buttons.
List<Key> _buttonKeys = [];

/// [_buttonProvider] is used to as a single placeholder for the state of a loadable button.
final _buttonProvider = StateProvider<bool>((ref) => false);

class OtpButtonProvider {
  final Key key;
  OtpButtonProvider({required this.key}) {
    checkProvider();
  }
  void checkProvider() {
    if (!_buttonKeys.contains(key)) {
      _buttonKeys.add(key);
      _buttonProviders
          .add(StateProvider((ref) => _buttonProviders.isEmpty ? true : false));
    }
  }

  static void dispose() {
    _buttonKeys.clear();
    _buttonProviders.clear();
  }

  static StateProvider<bool> provider({required final Key buttonKey}) {
    return _buttonProviders[_buttonKeys.indexOf(buttonKey)];
  }

  static void disable({required final Key buttonKey, required WidgetRef ref}) {
    StateProvider<bool> buttonProvider =
        _buttonProviders[_buttonKeys.indexOf(buttonKey)];
    ref.watch(buttonProvider.notifier).state = false;
  }

  static void enable({required final Key buttonKey, required WidgetRef ref}) {
    StateProvider<bool> buttonProvider =
        _buttonProviders[_buttonKeys.indexOf(buttonKey)];
    ref.watch(buttonProvider.notifier).state = true;
  }

  static bool enabled({required final Key buttonKey, required WidgetRef ref}) {
    StateProvider<bool> buttonProvider =
        _buttonProviders[_buttonKeys.indexOf(buttonKey)];
    return ref.watch(buttonProvider.notifier).state;
  }
}
