// ignore_for_file: dead_code, must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/images/stacked-image-list.dart';
import 'package:troco/features/groups/presentation/group_tab/providers/groups-provider.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/routes-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/images/profile-icon.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../groups/domain/entities/group.dart';
import '../../domain/entities/chat.dart';

/// This Widget contains all the header details.
/// From the Group's details, to the other chat details
class ChatHeader extends ConsumerWidget {
  List<Chat> chats;
  Group group;
  ChatHeader({super.key, required this.chats, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool hasTransaction = group.hasTransaction;
    listenToGroupChanges(ref, hasTransaction);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mediumSpacer(),
        groupDetailsWidget(context: context, hasTransaction: hasTransaction),
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

  Widget groupDetailsWidget(
      {required final BuildContext context,
      required final bool hasTransaction}) {
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
            hasTransaction ? "Transaction Ongoing" : "No Transactions yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: hasTransaction
                  ? ColorManager.accentColor
                  : ColorManager.primary,
              fontFamily: 'Lato',
              fontWeight: hasTransaction
                  ? FontWeightManager.medium
                  : FontWeightManager.light,
              fontSize: FontSizeManager.small,
            ),
          ),
          regularSpacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.viewGroupRoute,
                  arguments: group);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StackedImageListWidget(
                  images: membersIcon(),
                  iconSize: 20,
                ),
                regularSpacer(),
                Text(
                  "${group.members.length} member${group.members.length == 1 ? "" : "s"}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColorManager.accentColor,
                    fontFamily: 'Lato',
                    fontWeight: FontWeightManager.medium,
                    fontSize: FontSizeManager.small,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: ColorManager.accentColor,
                    size: IconSizeManager.small,
                  ),
                ),
              ],
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

  Future<void> listenToGroupChanges(WidgetRef ref, bool hasTransactions) async {
    ref.listen(groupsStreamProvider, (previous, next) {
      ref.watch(groupsStreamProvider).whenData((value) {
        final group = value
            .singleWhere((element) => element.groupId == this.group.groupId);
        if (group.hasTransaction) {
          if (hasTransactions == false) {
            hasTransactions = true;
          } else {
            if (hasTransactions != false) {
              hasTransactions = false;
            }
          }
        }
      });
    });
  }

  List<ImageProvider<Object>> membersIcon() {
    return group.sortedMembers.map<ImageProvider<Object>>(
      (member) {
        if (member.profile == "null") {
          return AssetImage(
              AssetManager.imageFile(name: "no_profile", ext: Extension.webp));
        }
        return CachedNetworkImageProvider(
          member.profile,
        );
      },
    ).toList();
  }
}
