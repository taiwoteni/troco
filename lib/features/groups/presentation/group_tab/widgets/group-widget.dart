// ignore_for_file: dead_code

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/presentation/providers/chat-provider.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

import '../../../../chat/domain/entities/chat.dart';

class CollectionWidget extends ConsumerStatefulWidget {
  final Group group;
  const CollectionWidget({super.key, required this.group});

  @override
  ConsumerState<CollectionWidget> createState() => _CollectionWidgetState();
}

class _CollectionWidgetState extends ConsumerState<CollectionWidget> {
  late Group group;
  late List<Chat> chats;

  @override
  void initState() {
    group = widget.group;
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Color color = ColorManager.accentColor;
    chats = [
      ...((group.toJson()["messages"] ?? []) as List)
          .map((e) => Chat.fromJson(json: e)),
      ...AppStorage.getUnsentChats(groupId: group.groupId)
    ];

    final messageStyle = TextStyle(
        color: color,
        fontFamily: 'Quicksand',
        fontSize: FontSizeManager.regular * 0.9,
        fontWeight: FontWeightManager.regular);
    bool chatIsEmpty = chats.isEmpty;
    bool clientIsLastSender = chats.isEmpty
        ? false
        : chats.last.senderId == ClientProvider.readOnlyClient!.userId;
    int unseenMessages = chats
        .where(
          (chat) =>
              !chat.read &&
              chat.senderId != ClientProvider.readOnlyClient!.userId,
        )
        .toList()
        .length;
    Chat? lastChat = chatIsEmpty ? null : chats.last;

    listenToChatChanges();
    return ListTile(
        onTap: () async {
          ref.watch(chatsGroupProvider.notifier).state = group.groupId;
          await Navigator.pushNamed(context, Routes.chatRoute,
              arguments: widget.group);
          setState(() {});
        },
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
                  "•",
                  style: TextStyle(
                      color: ColorManager.secondary,
                      fontSize: FontSizeManager.small * 0.5),
                ),
                regularSpacer(),
                Text(
                  chatIsEmpty
                      ? chatTimeFormatter(time: group.createdTime)
                      : chatTimeFormatter(time: chats.last.time),
                  style: TextStyle(
                      color: ColorManager.secondary,
                      fontFamily: 'Quicksand',
                      fontSize: FontSizeManager.small,
                      fontWeight: FontWeightManager.regular),
                )
              ],
            ),
            const Gap(SizeManager.small),
          ],
        ),
        titleTextStyle: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: ColorManager.primary,
            fontFamily: 'Lato',
            fontSize: FontSizeManager.medium * 1.1,
            fontWeight: FontWeightManager.semibold),
        subtitle: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(style: messageStyle, children: [
              TextSpan(
                  text: chatIsEmpty
                      ? null
                      : lastChat!.senderId ==
                              ClientProvider.readOnlyClient!.userId
                          ? "You:  "
                          : lastChat.senderId != group.adminId
                              ? (lastChat.senderId != group.creator
                                  ? "Buyer:  "
                                  : "Seller:  ")
                              : "Admin:  ",
                  style: messageStyle.copyWith(
                      color: clientIsLastSender ? ColorManager.secondary : null,
                      fontWeight: FontWeightManager.semibold)),
              if ((!chatIsEmpty && lastChat!.loading) ||
                  (lastChat != null && lastChat.hasAttachment)) ...[
                WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      lastChat.loading
                          ? Icons.access_time_rounded
                          : lastChat.isImage
                              ? CupertinoIcons.photo_fill
                              : CupertinoIcons.play_rectangle_fill,
                      size: IconSizeManager.small * 0.85,
                      color: (lastChat.hasAttachment && !clientIsLastSender)
                          ? ColorManager.accentColor
                          : ColorManager.secondary,
                    )),
                const TextSpan(text: " "),
              ],
              TextSpan(
                  text: chatIsEmpty
                      ? '"${group.groupName}" was created'
                      : !lastChat!.hasMessage
                          ? lastChat.isImage
                              ? "Photo"
                              : "Video"
                          : lastChat.message!.replaceAll("\n", ""),
                  style: messageStyle.copyWith(
                    fontWeight:
                        unseenMessages == 0 ? null : FontWeightManager.semibold,
                    color: clientIsLastSender ? ColorManager.secondary : null,
                  )),
            ])),
        leading: const GroupProfileIcon(
          size: 53,
        ),
        trailing: chatIsEmpty || unseenMessages == 0
            ? null
            : Container(
                height: 25,
                width: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorManager.accentColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  unseenMessages.toString(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontSize: FontSizeManager.medium * 0.7,
                      fontWeight: FontWeightManager.extrabold),
                ),
              ));
  }

  String chatTimeFormatter({required DateTime time}) {
    final bool isSameYear = DateTime.now().year == time.year;
    final bool isSameMonth = DateTime.now().month == time.month && isSameYear;
    final bool isSameDay = DateTime.now().day == time.day && isSameMonth;
    final bool isSameTime = isSameDay &&
        "${DateTime.now().hour}:${DateTime.now().minute}" ==
            "${time.hour + 1}:${time.minute}";
    final bool isYesterday = DateTime.now().day - 1 == time.day && !isSameDay;

    if (isSameDay) {
      final DateTime date = time.copyWith(hour: time.hour + 1);

      return isSameTime ? "now" : DateFormat.jm().format(date);
    } else {
      if (isYesterday) {
        return "yesterday";
      } else {
        return "${DateFormat.E().format(time)}, ${DateFormat.MMMd().format(time)}";
      }
    }
  }

  Future<void> listenToChatChanges() async {
    ref.listen(chatsStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          setState(() {
            chats = data;
          });
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      );
    });
  }
}
