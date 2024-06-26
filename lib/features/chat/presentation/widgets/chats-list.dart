// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/chat/domain/repositories/chat-repository.dart';
import 'package:troco/features/chat/presentation/widgets/admin-chat-widget.dart';
import 'package:troco/features/chat/presentation/widgets/chat-header.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

import '../../../../core/app/size-manager.dart';
import '../../../auth/presentation/providers/client-provider.dart';
import '../../domain/entities/chat.dart';
import 'chat-widget.dart';

/// The Containing the Chats Listview
class ChatLists extends ConsumerStatefulWidget {
  List<Chat> chats;
  final Group group;
  ChatLists({super.key, required this.chats, required this.group});

  @override
  ConsumerState<ChatLists> createState() => _ChatListsState();
}

class _ChatListsState extends ConsumerState<ChatLists> {
  @override
  Widget build(BuildContext context) {
    for (final currentChat in widget.chats) {
      if (currentChat.senderId != ClientProvider.readOnlyClient!.userId) {
        if (!currentChat.read) {
          markAsRead(chat: currentChat);
        }
      }
    }
    return ListView.builder(
      key: Key("${widget.group.groupId}-chats-list"),
      shrinkWrap: true,
      itemCount: widget.chats.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final Chat currentChat = widget.chats[index];

        final bool isFirstMessage = index == 0;
        final bool isLastMessage = index == widget.chats.length - 1;

        /// By default all this values are false except for firstTimeSender;
        bool sameSender = false,
            firstTimeSender = true,
            lastTimeSender = false,
            lastSent = false;

        /// If itsn't the first messager, neither the last,
        /// Then, [sameSender] is wether the pervious chat was sent by the sender
        /// of this [currentChat]
        /// else, it remains false.
        if (!isFirstMessage && !isLastMessage) {
          sameSender = currentChat.senderId == widget.chats[index - 1].senderId;
        }

        /// If it isn't the first message, the firstTimeSender is
        /// if the sender of the previous message is not the same as the currentMessage
        /// Hence, durning the firstMessage firstTimeSender is true,
        /// but messages after that, firstTimeSender is only true, IF its the currentMessage
        /// is directly after a receiver just sent his last or only Message.
        if (!isFirstMessage) {
          firstTimeSender =
              currentChat.senderId != widget.chats[index - 1].senderId;
        }

        /// If it isn't the last message, the lastTimeSender is
        /// if the sender of the currentMessage is the same as the sender of
        /// the nextMessage.
        /// Hence, if it isn't the lastMessage, it is false (for now)
        /// or if it is the same sender as the nextMessage, it is false also.
        ///
        /// This is to know wether this is the last message sent by the sender
        /// directly before a message by the receiver or admin
        if (!isLastMessage) {
          lastTimeSender =
              currentChat.senderId != widget.chats[index + 1].senderId;
        } else {
          ///
          if (!isFirstMessage) {
            lastTimeSender =
                currentChat.senderId != widget.chats[index - 1].senderId;
          }
        }

        final lastSentChat = widget.chats.lastWhere(
          (chat) => !chat.loading,
          orElse: () => widget.chats.last,
        );
        lastSent = currentChat == lastSentChat;
        return Column(
          key: ObjectKey(widget.chats[index]),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index == 0)
              ChatHeader(chats: widget.chats, group: widget.group),
            Padding(
              padding: EdgeInsets.only(
                  bottom: isLastMessage ? SizeManager.large : 0),
              child: currentChat.senderId == widget.group.adminId
                  ? AdminChatWidget(
                      group: widget.group,
                      chat: currentChat,
                      lastSent: lastSent,
                      firstSender: firstTimeSender,
                      lastSender: lastTimeSender,
                      sameSender: sameSender,
                      lastMessage: isLastMessage,
                    )
                  : ChatWidget(
                      group: widget.group,
                      chat: currentChat,
                      lastSent: lastSent,
                      firstSender: firstTimeSender,
                      lastSender: lastTimeSender,
                      sameSender: sameSender,
                      lastMessage: isLastMessage,
                    ),
            ),
            // for (Chat chat in ref.watch(pendingChatListProvider(widget.group.groupId)))
            //   ChatWidget(chat: chat, deviceClient: deviceClient)
          ],
        );
      },
    );
  }

  void markAsRead({required final Chat chat}) {
    //For those who may go offline.
    //Just like whatsapp, as u open a chat and close it, it's all marked as read.

    final chats =
        List<Chat>.from(AppStorage.getChats(groupId: widget.group.groupId));
    final savedChats = <Chat>[];
    for (final cachedChat in chats) {
      final json = cachedChat.toJson();
      (json["readBy"] as List).add(ClientProvider.readOnlyClient!.userId);
      savedChats.add(Chat.fromJson(json: json));
    }
    AppStorage.saveChats(chats: chats, groupId: widget.group.groupId);

    ChatRepo.markAsRead(groupId: widget.group.groupId, messageId: chat.chatId);
  }
}
