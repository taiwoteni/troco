
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/settings/domain/entity/settings.dart';

final settingsProvider = StateProvider<Settings>((ref) {
  return AppStorage.getSettings();
});