
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/groups/data/models/group-model.dart';

final groupsProvider = FutureProvider<List<GroupModel>>((ref) => []);