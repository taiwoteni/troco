import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/button/presentation/provider/enabled-provider.dart';

/// [_buttonProviders] is used to store the list of states used for the buttons.
final List<StateProvider<Map<String, bool>>> _buttonProviders = [];

/// [_buttonKeys] is used to store the list of keys used for the buttons.
final List<UniqueKey> _buttonKeys = [];

/// [_buttonProvider] is used to as a single placeholder for the state of a loadable button.
/// It uses StateProvider.family<Map,UniqueKey> inorder to use it's UniqueKey to uniquely identify
/// values in the List.
final _buttonProvider =
    StateProvider.family<Map<String, bool>, UniqueKey>((ref, key) {
  return {'loading': false, 'enabled': true}; // Initial attributes
});

class ButtonProvider {
  final UniqueKey key;
  ButtonProvider({required this.key}) {
    checkProvider();
  }

  void checkProvider() {
    if (!_buttonKeys.contains(key)) {
      _buttonKeys.add(key);
      _buttonProviders.add(_buttonProvider(key));
    }
  }

  /// Only use [delete] when other screens depending on ButtonProvider
  /// have been disposed.
  static void delete({required final UniqueKey key}) {
    _buttonProviders.removeAt(_buttonKeys.indexOf(key));
    _buttonKeys.removeAt(_buttonKeys.indexOf(key));
  }

  static void disable(
      {required final UniqueKey buttonKey,
      required WidgetRef ref,
      bool? disableAll}) {
    final buttonProvider = _buttonProviders[_buttonKeys.indexOf(buttonKey)];
    final bool loading = ref.watch(buttonProvider)["loading"] as bool;
    ref.watch(enabledProvider.notifier).state = !(disableAll ?? false);
    ref.read(buttonProvider.notifier).state = {
      "loading": loading,
      "enabled": false
    };
  }

  static void enable(
      {required final UniqueKey buttonKey, required WidgetRef ref}) {
    final buttonProvider = _buttonProviders[_buttonKeys.indexOf(buttonKey)];
    final bool loading = ref.watch(buttonProvider)["loading"] as bool;
    ref.watch(enabledProvider.notifier).state = true;
    ref.read(buttonProvider.notifier).state = {
      "loading": loading,
      "enabled": true,
    };
  }

  static bool enabledValue(
      {required final UniqueKey buttonKey, required WidgetRef ref}) {
    final buttonProvider =
        _buttonProviders.elementAt(_buttonKeys.indexOf(buttonKey));
    return ref.watch(buttonProvider)["enabled"] as bool;
  }

  static void startLoading(
      {required final UniqueKey buttonKey, required WidgetRef ref}) {
    StateProvider<Map<String, bool>> buttonProvider =
        _buttonProviders[_buttonKeys.indexOf(buttonKey)];
    final bool enabled = ref.watch(buttonProvider)["enabled"] as bool;
    ref.watch(buttonProvider.notifier).state = {
      "enabled": enabled,
      "loading": true
    };
  }

  static void stopLoading(
      {required final UniqueKey buttonKey, required WidgetRef ref}) {
    StateProvider<Map<String, bool>> buttonProvider =
        _buttonProviders[_buttonKeys.indexOf(buttonKey)];
    final bool enabled = ref.watch(buttonProvider)["enabled"] as bool;
    ref.watch(buttonProvider.notifier).state = {
      "enabled": enabled,
      "loading": false
    };
  }

  static bool loadingValue(
      {required final UniqueKey buttonKey, required WidgetRef ref}) {
    if (!_buttonKeys.contains(buttonKey)) {
      return false;
    }
    StateProvider<Map<String, bool>> buttonProvider =
        _buttonProviders.elementAt(_buttonKeys.indexOf(buttonKey));
    return ref.watch(buttonProvider)["loading"] as bool;
  }
}
