import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/groups/data/models/group-member-model.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../widgets/empty-screen.dart';
import '../widgets/group-widget.dart';
import '../providers/groups-provider.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage> {
  @override
  Widget build(BuildContext context) {
    final asyncConfig = ref.watch(groupsProvider);
    return asyncConfig.when(
        data: (e) {
          final List<Group> data = e.map((e) => e).toList();
          return data.isEmpty
              ? const EmptyScreen(
                  label: "No Business Groups.\nCreate a Business Group",
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: SizeManager.small),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) => ChatContactWidget(
                        group: data[index],
                      ),
                  separatorBuilder: (context, index) => Divider(
                        thickness: 0.8,
                        color: ColorManager.secondary.withOpacity(0.08),
                      ),
                  itemCount: data.length);
        },
        error: (error, stackTrace) {
          log(error.toString(), stackTrace: stackTrace);
          return const EmptyScreen(
            label: "Error loading business groups",
          );
        },
        loading: () => const EmptyScreen(
              label: "Loading business groups",
            ));
  }
}
