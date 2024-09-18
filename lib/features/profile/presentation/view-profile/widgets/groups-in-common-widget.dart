import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/features/auth/domain/entities/client.dart';

import '../../../../../core/app/routes-manager.dart';
import '../../../../chat/presentation/providers/chat-provider.dart';
import '../../../../groups/domain/entities/group.dart';

class GroupsInCommonWidget extends ConsumerStatefulWidget {
  final Group group;
  final Client client;
  final bool inCommon, applyHorizontalPadding;
  const GroupsInCommonWidget(
      {super.key,
      required this.group,
      this.inCommon = true,
      this.applyHorizontalPadding = true,
      required this.client});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupsInCommonWidgetState();
}

class _GroupsInCommonWidgetState extends ConsumerState<GroupsInCommonWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        if (!widget.inCommon) {
          return;
        }
        ref.watch(chatsGroupProvider.notifier).state = widget.group.groupId;
        await Navigator.pushNamed(context, Routes.chatRoute,
            arguments: widget.group);
      },
      contentPadding: const EdgeInsets.symmetric(
          vertical: SizeManager.small, horizontal: 0),
      dense: true,
      leading: const GroupProfileIcon(
        size: IconSizeManager.large,
      ),
      title: Text(widget.group.groupName),
      subtitle: Text(
          widget.group.creator == widget.client.userId ? "Seller" : "Buyer"),
      titleTextStyle: TextStyle(
          fontFamily: 'Lato',
          color: ColorManager.primary,
          fontSize: FontSizeManager.regular,
          fontWeight: FontWeightManager.semibold),
      subtitleTextStyle: TextStyle(
          fontFamily: 'Lato',
          color: ColorManager.secondary,
          fontSize: FontSizeManager.small,
          fontWeight: FontWeightManager.regular),
    );
  }
}
