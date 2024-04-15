// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';
import 'package:troco/features/auth/domain/entities/client.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';

class ChatWidget extends ConsumerWidget {
  final Chat chat;
  final Client deviceClient;
  final bool firstSender, lastSender, sameSender, lastMessage;
  const ChatWidget(
      {super.key,
      required this.chat,
      required this.deviceClient,
      this.lastMessage = false,
      this.firstSender = true,
      this.sameSender = false,
      this.lastSender = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSender =
        ref.watch(ClientProvider.userProvider)!.userId == chat.senderId;

    BorderRadius generalBubble() {
      return BorderRadius.only(
        topLeft: !isSender
            ? const Radius.circular(SizeManager.medium * 0.8)
            : const Radius.circular(SizeManager.large),
        bottomLeft: !isSender
            ? const Radius.circular(SizeManager.medium * 0.8)
            : const Radius.circular(SizeManager.large),
        topRight: isSender
            ? const Radius.circular(SizeManager.medium * 0.8)
            : const Radius.circular(SizeManager.large),
        bottomRight: isSender
            ? const Radius.circular(SizeManager.medium * 0.8)
            : const Radius.circular(SizeManager.large),
      );
    }

    BorderRadius lastBubble({required final bool isSender}) {
      return generalBubble().copyWith(
        topRight: isSender ? const Radius.circular(SizeManager.small) : null,
        topLeft: isSender ? null : const Radius.circular(SizeManager.small),
      );
    }

    BorderRadius firstBubble({required final bool isSender}) {
      return generalBubble().copyWith(
        bottomRight: isSender ? const Radius.circular(SizeManager.small) : null,
        bottomLeft: isSender ? null : const Radius.circular(SizeManager.small),
      );
    }

    final BorderRadius border = firstSender
        ? firstBubble(isSender: isSender)
        : !lastSender
            ? generalBubble()
            : lastBubble(isSender: isSender);

    Widget typingWidget() {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(ColorManager.secondary, BlendMode.srcIn),
        child: Lottie.asset(
          AssetManager.lottieFile(name: 'typing'),
          width: 40,
          height: 30,
          alignment: Alignment.center,
          fit: BoxFit.fill,
          repeat: true,
        ),
      );
    }

    Widget informationWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chat.hasAttachment)
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
                      image: FileImage(File(chat.attachment!)),
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
                    color: isSender ? Colors.white : ColorManager.primary,
                    fontSize: FontSizeManager.regular * 0.9,
                    fontWeight: FontWeightManager.medium),
              ),
            )
        ],
      );
    }

    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
        left: (lastSender ? lastSender : lastMessage) && !isSender ? 0 : 48,
        right: SizeManager.medium,
        top: lastSender || sameSender ? SizeManager.small : SizeManager.medium,
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: chat.hasAttachment
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center,
        children: [
          if ((lastSender ? lastSender : lastMessage) && !isSender)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: chat.profile != "null"
                  ? ProfileIcon(
                      profile: DecorationImage(
                          image: NetworkImage(chat.profile), fit: BoxFit.cover),
                      size: 28)
                  : const UserProfileIcon(
                      size: 28,
                      showOnlyDefault: true,
                    ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManager.regular * 1.3,
                vertical: SizeManager.regular),
            decoration: BoxDecoration(
              color: isSender
                  ? chat.read
                      ? ColorManager.accentColor
                      : ColorManager.themeColor
                  : ColorManager.background,
              borderRadius: border,
            ),
            child: informationWidget(),
          ),
        ],
      ),
    );
  }
}
