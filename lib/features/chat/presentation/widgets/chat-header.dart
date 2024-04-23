// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/images/profile-icon.dart';
import '../../../../core/basecomponents/others/spacer.dart';
import '../../../groups/domain/entities/group.dart';
import '../../domain/entities/chat.dart';

/// This Widget contains all the header details.
/// From the Group's details, to the other chat details
class ChatHeader extends ConsumerWidget {
  final List<Chat> chats;
  final Group group;
  const ChatHeader({super.key, required this.chats, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mediumSpacer(),
        groupDetailsWidget(),
        groupCreationTime(),
        if (false) adminJoinedWidget(),
        addedWidget(),
        if (chats.isNotEmpty) ...[
          smallSpacer(),
          endToEndEncrypted(),
          mediumSpacer(),
          divider(),
          extraLargeSpacer(),
        ]
      ],
    );
  }

  Widget endToEndEncrypted() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: SizeManager.regular),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular * 1.1,
          vertical: SizeManager.regular * 1.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeManager.regular),
      ),
      child: Text(
        "Conversations are end-to-end Encrypted",
        style: TextStyle(
            color: ColorManager.themeColor,
            fontFamily: 'Lato',
            fontSize: FontSizeManager.regular * 0.75,
            fontWeight: FontWeightManager.semibold),
      ),
    );
  }

  Widget groupCreationTime() {
    return Container(
      margin: const EdgeInsets.only(
          top: SizeManager.regular, bottom: SizeManager.small),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular * 1.1,
          vertical: SizeManager.regular * 1.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeManager.regular),
      ),
      child: Text(
        '"${group.groupName}" was created',
        style: TextStyle(
            color: ColorManager.secondary,
            fontFamily: 'Lato',
            fontSize: FontSizeManager.regular * 0.75,
            fontWeight: FontWeightManager.semibold),
      ),
    );
  }

  Widget addedWidget() {
    return Container(
      margin: const EdgeInsets.only(
          top: SizeManager.regular, bottom: SizeManager.small),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular * 1.1,
          vertical: SizeManager.regular * 1.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeManager.regular),
      ),
      child: Text(
        'you were added',
        style: TextStyle(
            color: ColorManager.secondary,
            fontFamily: 'Lato',
            fontSize: FontSizeManager.regular * 0.75,
            fontWeight: FontWeightManager.semibold),
      ),
    );
  }

  Widget adminJoinedWidget() {
    return Container(
      margin: const EdgeInsets.only(
          top: SizeManager.regular, bottom: SizeManager.small),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular * 1.1,
          vertical: SizeManager.regular * 1.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeManager.regular),
      ),
      child: Text(
        'Admin Joined',
        style: TextStyle(
            color: ColorManager.secondary,
            fontFamily: 'Lato',
            fontSize: FontSizeManager.regular * 0.75,
            fontWeight: FontWeightManager.semibold),
      ),
    );
  }

  Widget groupDetailsWidget() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          vertical: SizeManager.medium, horizontal: SizeManager.medium),
      margin: const EdgeInsets.symmetric(
        horizontal: SizeManager.large,
        vertical: SizeManager.small,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular * 1.5),
          color: ColorManager.background),
      child: Column(
        children: [
          regularSpacer(),
          const GroupProfileIcon(
            size: IconSizeManager.extralarge * 0.95,
          ),
          regularSpacer(),
          Text(
            group.groupName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'Lato',
              fontWeight: FontWeightManager.semibold,
              fontSize: FontSizeManager.regular * 1.1,
            ),
          ),
          regularSpacer(),
          Text(
            "No Transactions yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'Lato',
              fontWeight: FontWeightManager.light,
              fontSize: FontSizeManager.small,
            ),
          ),
          regularSpacer(),
          Text(
            "${group.members.length} member${group.members.length == 1 ? "" : "s"}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'Lato',
              fontWeight: FontWeightManager.light,
              fontSize: FontSizeManager.small,
            ),
          ),
          regularSpacer(),
        ],
      ),
    );
  }

  Widget divider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.only(
                left: SizeManager.large, right: SizeManager.regular),
            height: 1,
            decoration: BoxDecoration(
                color: ColorManager.secondary.withOpacity(0.09),
                borderRadius: BorderRadius.circular(SizeManager.regular)),
          ),
        ),
        Text(
          "Business Starts",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorManager.secondary,
            fontFamily: 'Quicksand',
            fontWeight: FontWeightManager.medium,
            fontSize: FontSizeManager.regular * 0.9,
          ),
        ),
        Expanded(
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.only(
                right: SizeManager.large, left: SizeManager.regular),
            height: 1,
            decoration: BoxDecoration(
                color: ColorManager.secondary.withOpacity(0.09),
                borderRadius: BorderRadius.circular(SizeManager.regular)),
          ),
        )
      ],
    );
  }
}
