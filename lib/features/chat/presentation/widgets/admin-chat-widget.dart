import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/app/color-manager.dart';
import '../../domain/entities/chat.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';

class AdminChatWidget extends ConsumerWidget {
  final Chat chat;
  final bool firstSender, lastSender, sameSender, lastMessage;
  const AdminChatWidget(
      {super.key,
      required this.chat,
      this.lastMessage = false,
      this.firstSender = true,
      this.sameSender = false,
      this.lastSender = false});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Widget informationWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!chat.hasAttachment)
            Container(
              width: 250,
              constraints: const BoxConstraints(
                minHeight: 100,
                maxHeight: 250,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // TODO: ONCE FINBAR GIVES API, CHANGE TO NETWORK IMAGE
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(chat.profile),
                      fit: BoxFit.cover)),
          ),
          if (chat.hasMessage)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeManager.regular,
                  vertical: SizeManager.small * 0.7),
              child: Text(
                chat.message!,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: ColorManager.primary,
                    fontSize: FontSizeManager.regular * 0.95,
                    fontWeight: FontWeightManager.medium),
              ),
            )
        ],
      );
    }


    return Container(


      
    );
  }
}