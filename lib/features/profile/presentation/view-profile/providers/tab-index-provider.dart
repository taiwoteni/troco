import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileTabIndexProvider = AutoDisposeStateProvider<int>(
  (ref) => 0,
);
