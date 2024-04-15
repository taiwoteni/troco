import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/chat/presentation/providers/pending-chat-list-provider.dart';
import 'package:troco/features/chat/presentation/widgets/chat-header.dart';
import 'package:troco/features/groups/domain/entities/group.dart';

import '../../../../core/app/size-manager.dart';
import '../../../auth/presentation/providers/client-provider.dart';
import '../../domain/entities/chat.dart';
import 'chat-widget.dart';

/// The Containing the Chats Listview
class ChatLists extends ConsumerStatefulWidget {
  final List<Chat> chats;
  final Group group;
  const ChatLists({super.key, required this.chats, required this.group});

  @override
  ConsumerState<ChatLists> createState() => _ChatListsState();
}

class _ChatListsState extends ConsumerState<ChatLists> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: Key("${widget.group.groupId}-chats-list"),
      shrinkWrap: true,
      itemCount: widget.chats.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final Chat currentChat = widget.chats[index];

        final bool isFirstMessage = index == 0;
        final bool isLastMessage = index == widget.chats.length - 1;
        bool sameSender = false, firstTimeSender = true, lastTimeSender = false;

        if (!isFirstMessage && !isLastMessage) {
          sameSender = currentChat.senderId == widget.chats[index - 1].senderId;
        }
        if (!isFirstMessage) {
          firstTimeSender =
              currentChat.senderId != widget.chats[index - 1].senderId;
        }
        if (!isLastMessage) {
          lastTimeSender =
              currentChat.senderId != widget.chats[index + 1].senderId;
        } else {
          if (!isFirstMessage) {
            lastTimeSender =
                currentChat.senderId == widget.chats[index - 1].senderId;
          }
        }

        return Column(
          key: ObjectKey(widget.chats[index]),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index == 0)
              ChatHeader(chats: widget.chats, group: widget.group),
            Padding(
              padding: EdgeInsets.only(
                  bottom: isLastMessage ? SizeManager.large : 0),
              child: ChatWidget(
                deviceClient: ref.read(ClientProvider.userProvider)!,
                chat: currentChat,
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

  // Widget pendingChatListWidgets(){
    
    
  // }
}
