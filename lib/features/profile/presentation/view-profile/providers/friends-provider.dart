import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/auth/domain/entities/client.dart';

final friendsProfileProvider = StateProvider<List<Client>>(
  (ref) => [],
);
