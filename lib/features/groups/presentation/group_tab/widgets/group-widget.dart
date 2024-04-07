// ignore_for_file: dead_code

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/groups/data/models/group-model.dart';

class ChatContactWidget extends ConsumerStatefulWidget {
  final GroupModel group;
  const ChatContactWidget({super.key, required this.group});

  @override
  ConsumerState<ChatContactWidget> createState() => _ChatContactWidgetState();
}

class _ChatContactWidgetState extends ConsumerState<ChatContactWidget> {
  late GroupModel group;

  @override
  void initState() {
    group = widget.group;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color color = ColorManager.accentColor;

    final messageStyle = TextStyle(
        color: color,
        fontFamily: 'Quicksand',
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.regular);

    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeManager.medium),
      child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManager.medium),
          ),
          child: ListTile(
              onTap: () => Navigator.pushNamed(context, Routes.chatRoute,
                  arguments: widget.group),
              dense: true,
              tileColor: Colors.transparent,
              contentPadding: const EdgeInsets.only(
                left: SizeManager.medium,
                right: SizeManager.medium,
                top: SizeManager.small,
                bottom: SizeManager.small,
              ),
              horizontalTitleGap: SizeManager.medium * 0.8,
              title: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        group.groupName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      regularSpacer(),
                      Text(
                        '•',
                        style: TextStyle(
                            color: ColorManager.secondary,
                            fontSize: FontSizeManager.small * 0.5),
                      ),
                      regularSpacer(),
                      Text(
                        'pending',
                        style: TextStyle(
                            color: ColorManager.secondary,
                            fontFamily: 'Quicksand',
                            fontSize: FontSizeManager.small,
                            fontWeight: FontWeightManager.regular),
                      )
                    ],
                  ),
                  const Gap(SizeManager.regular * 1.1),
                ],
              ),
              titleTextStyle: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: ColorManager.primary,
                  fontFamily: 'Lato',
                  fontSize: FontSizeManager.medium * 1.1,
                  fontWeight: FontWeightManager.semibold),
              subtitle: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(style: messageStyle, children: [
                    TextSpan(
                        text: "You: ",
                        style: messageStyle.copyWith(
                            fontWeight: FontWeightManager.semibold)),
                    TextSpan(text: 'created "${group.groupName}"'),
                  ])),
              leading: const GroupProfileIcon(
                size: 53,
              ),
              trailing: true
                  ? null
                  : Container(
                      height: 25,
                      width: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        "5",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato',
                            fontSize: FontSizeManager.medium * 0.7,
                            fontWeight: FontWeightManager.extrabold),
                      ),
                    ))),
    );
  }
}
