// ignore_for_file: dead_code

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/presentation/providers/chat-provider.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

import '../../../../chat/domain/entities/chat.dart';

class ChatContactWidget extends ConsumerStatefulWidget {
  final Group group;
  const ChatContactWidget({super.key, required this.group});

  @override
  ConsumerState<ChatContactWidget> createState() => _ChatContactWidgetState();
}

class _ChatContactWidgetState extends ConsumerState<ChatContactWidget> {
  late Group group;
  late List<Chat> chats;

  @override
  void initState() {
    group = widget.group;
    chats = (group.toJson()["messages"] as List)
        .map((e) => Chat.fromJson(json: e))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color color = ColorManager.accentColor;
    final messageStyle = TextStyle(
        color: color,
        fontFamily: 'Quicksand',
        fontSize: FontSizeManager.regular * 0.9,
        fontWeight: FontWeightManager.regular);
    bool chatIsEmpty = chats.isEmpty;
    bool clientIsLastSender = chats.isEmpty
        ? false
        : chats.last.senderId == ClientProvider.readOnlyClient!.userId;
    int indexOfLastTimeClientChatted = chats.lastIndexWhere(
        (chat) => chat.senderId == ClientProvider.readOnlyClient!.userId);
    var listOfMessagesFromLastTimeYouSent = clientIsLastSender
        ? chats
        : chats.isEmpty?[]: chats.sublist(indexOfLastTimeClientChatted);
    int unseenMessages = clientIsLastSender || chats.isEmpty
        ? 0
        : listOfMessagesFromLastTimeYouSent
                .where((chat) => !chat.read)
                .toList()
                .length -
            1;
    Chat? lastChat = chatIsEmpty ? null : chats.last;

    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeManager.medium),
      child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManager.medium),
          ),
          child: ListTile(
              onTap: () {
                ref.watch(chatsGroupProvider.notifier).state = group.groupId;
                Navigator.pushNamed(context, Routes.chatRoute,
                    arguments: widget.group);
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
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(style: messageStyle, children: [
                    TextSpan(
                        text: chatIsEmpty
                            ? null
                            : lastChat!.senderId ==
                                    ClientProvider.readOnlyClient!.userId
                                ? "You: "
                                : null,
                        style: messageStyle.copyWith(
                            color: clientIsLastSender
                                ? ColorManager.secondary
                                : null,
                            fontWeight: FontWeightManager.semibold)),
                    TextSpan(
                        text: chatIsEmpty
                            ? '"${group.groupName}" was created'
                            : lastChat!.message,
                        style: messageStyle.copyWith(
                          fontWeight: unseenMessages == 0
                              ? null
                              : FontWeightManager.semibold,
                          color: clientIsLastSender
                              ? ColorManager.secondary
                              : null,
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
                    ))),
    );
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
      return isSameTime
          ? "now"
          : "${time.hour + 1}:${time.minute.toString().padLeft(2, "0")}";
    } else {
      if (isYesterday) {
        return "yesterday";
      } else {
        return "${DateFormat.E().format(time)}, ${DateFormat.MMMd().format(time)}";
      }
    }
  }
}
