// ignore_for_file: unused_element

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/images/stacked-image-list.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/animations/lottie.dart';

class ChatWidget extends ConsumerWidget {
  final Chat chat;
  final bool firstSender, lastSender, sameSender, lastMessage, lastSent;
  const ChatWidget(
      {super.key,
      required this.chat,
      this.lastSent = false,
      this.lastMessage = false,
      this.firstSender = true,
      this.sameSender = false,
      this.lastSender = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSender =
        ref.watch(ClientProvider.userProvider)!.userId == chat.senderId;
    final alignViewsBottom =
        !(chat.hasAttachment ? true : chat.message!.length >= 116);

    final showViews = (lastMessage ? true : lastSent) && isSender;

    BorderRadius generalBubble() {
      return BorderRadius.circular(SizeManager.large);
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
      return !chat.hasMessage
          ? const SizedBox.square(
              dimension: 0,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeManager.regular,
                  vertical: SizeManager.small * 0.7),
              child: Text(
                chat.message!,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: isSender ? Colors.white : ColorManager.primary,
                    fontSize: FontSizeManager.regular * 0.95,
                    fontWeight: FontWeightManager.medium),
              ),
            );
    }

    Widget content() {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SizeManager.regular * 1.3,
            vertical: SizeManager.regular * 1),
        decoration: BoxDecoration(
          color: isSender
              ? chat.read
                  ? ColorManager.accentColor
                  : ColorManager.themeColor
              : ColorManager.background,
          borderRadius: border,
        ),
        child: informationWidget(),
      );
    }

    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
        left: (lastSender ? lastSender : lastMessage) && !isSender ? 0 : 55,
        right: SizeManager.medium,
        // bottom: lastSender?,
        top: sameSender

            /// I removed lastSender from the [top: lastSender || sameSender]
            /// because sameSender is always true if it is the lastSender.
            ? (firstSender && lastSender)
                ? SizeManager.medium * 1.05
                : SizeManager.small * 0.95
            : lastMessage
                ? SizeManager.small * 0.95
                : SizeManager.medium * 1.05,
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: isSender ? TextDirection.ltr : TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: alignViewsBottom
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .6),
                child: Column(
                  crossAxisAlignment: isSender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (chat.hasAttachment) ...[
                      attachmentWidget(),
                      smallSpacer(),
                    ],
                    content(),
                  ],
                ),
              ),
              profileIcon(isSender: isSender),
              loadingWidget(),
            ],
          ),
          if (showViews) stackedImages(),
        ],
      ),
    );
  }

  Widget profileIcon({required final bool isSender}) {
    return ((lastSender ? lastSender : lastMessage) && !isSender)
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ProfileIcon(url: chat.profile, size: 35),
          )
        : const SizedBox.square(
            dimension: 0,
          );
  }

  Widget loadingWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.ease,
      width: chat.loading ? IconSizeManager.regular + SizeManager.small : 0,
      alignment: Alignment.centerRight,
      child: Transform.scale(
        scale: 1.6,
        child: LottieWidget(
            lottieRes: AssetManager.lottieFile(name: "loading"),
            size: const Size.square(IconSizeManager.regular),
            color: ColorManager.secondary),
      ),
    );
  }

  Widget attachmentWidget() {
    return Container(
      width: double.maxFinite,
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
    );
  }

  Widget stackedImages() {
    final List<ImageProvider<Object>> images = chat.loading
        ? []
        : [
            NetworkImage(ClientProvider.readOnlyClient!.profile),
            NetworkImage(ClientProvider.readOnlyClient!.profile),
            AssetImage(AssetManager.imageFile(
                name: "product-image-demo", ext: Extension.jpg)),
          ];

    /// Logic to ensure chat views only show at the last message
    /// or last sent message has been done, therefore the read list
    /// will only be visible during those times as well as in cases
    /// whereby, only 1 sender's chat is in the group or all current chats are unsent chat
    /// so before we show, we have to know whether the read lists are actually
    /// not empty due to the two scenarios given above.
    final hasViews = images.isNotEmpty;

    return Visibility(
      visible: hasViews,

      /// we use maintain state and maintain animation inorder to
      /// still let the animation play even though it is triggered
      /// when the child is just getting visible
      maintainAnimation: true,
      maintainState: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        padding: const EdgeInsets.only(top: SizeManager.small),
        curve: Curves.ease,
        height: hasViews ? 22 + SizeManager.small : 0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StackedImageListWidget(
              images: images,
              iconSize: 18,
            ),
            regularSpacer(),
            Text(
              "${images.length} view${images.length == 1 ? "" : "s"}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'Lato',
                fontWeight: FontWeightManager.medium,
                fontSize: FontSizeManager.small * 0.9,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Icon(
                Icons.chevron_right_rounded,
                color: ColorManager.secondary,
                size: IconSizeManager.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
