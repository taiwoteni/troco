import 'package:flutter_riverpod/flutter_riverpod.dart';

final pricingsImagesProvider = StateProvider<List<String>>((ref) {
  return [];
});

final removedImagesItemsProvider = StateProvider<List<Map>>(
  (ref) => [],
);
