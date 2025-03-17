// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/groups-provider.dart';
import 'groups-list.dart';

class CollectionsTab extends ConsumerStatefulWidget {
  const CollectionsTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends ConsumerState<CollectionsTab> {
  bool hasShownError = false;

  @override
  Widget build(BuildContext context) {
    listenToGroupsChanges();
    final groups = ref.watch(groupsListProvider);
    return GroupList(groups: groups);
  }

  void listenToGroupsChanges() {
    ref.listen(
      groupsStreamProvider,
      (previous, next) {
        next.whenData(
          (value) {
            setState(() {});
          },
        );
      },
    );
  }
}
