import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';

final groupRepoProvider = Provider<GroupRepo>((ref) => GroupRepo());

final groupsProvider = FutureProvider.autoDispose <List<Group>>((ref) async {
  return ref.watch(groupRepoProvider).getGroups();
});
