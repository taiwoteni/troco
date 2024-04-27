import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabIndexProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

final tabControllerProvider =
    StateProvider<PageController>((ref) => PageController());

final menuToggleIndexProvider = StateProvider.autoDispose<bool>((ref) {
  return true;
});
