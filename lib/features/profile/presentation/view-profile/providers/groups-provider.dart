import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

final groupsProfileProvider = StateProvider<List<Group>>(
  (ref) => [],
);
