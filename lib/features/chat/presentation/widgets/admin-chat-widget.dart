// ignore_for_file: unused_element

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/images/stacked-image-list.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/animations/lottie.dart';
import '../../../groups/domain/entities/group.dart';

class AdminChatWidget extends ConsumerStatefulWidget {
  final Chat chat;
  final Group group;
  final bool firstSender, lastSender, sameSender, lastMessage, lastSent;
  const AdminChatWidget(
      {super.key,
      required this.chat,
      required this.group,
      this.lastSent = false,
      this.lastMessage = false,
      this.firstSender = true,
      this.sameSender = false,
      this.lastSender = false});

  @override
  ConsumerState<AdminChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<AdminChatWidget> {
  late Chat chat;
  late bool firstSender, lastSender, sameSender, lastMessage;
  late String groupId;
  late Group group;

  @override
  void initState() {
    chat = widget.chat;
    groupId = widget.group.groupId;
    group = widget.group;
    firstSender = widget.firstSender;
    lastSender = widget.lastSender;
    sameSender = widget.sameSender;
    lastMessage = widget.lastMessage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
          top: sameSender

              /// I removed lastSender from the [top: lastSender || sameSender]
              /// because sameSender is always true if it is the lastSender.
              ? SizeManager.small * 0.85
              : firstSender
                  ? SizeManager.medium * 1.2
                  : SizeManager.small * 0.85),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .75),
            child: content(),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeManager.regular),
          color: ColorManager.tertiary),
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular, vertical: SizeManager.small),
      child: Row(
        children: [
          const ProfileIcon(size: IconSizeManager.medium * 1.5, url: null),
          smallSpacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Troco Admin",
                style: TextStyle(
                    color: ColorManager.accentColor,
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.regular * 0.95,
                    fontWeight: FontWeightManager.semibold),
              ),
              Text(
                "Group Admin",
                style: TextStyle(
                    color: ColorManager.secondary,
                    fontFamily: 'lato',
                    fontSize: FontSizeManager.small * 0.7,
                    fontWeight: FontWeightManager.regular),
              ),
            ],
          )
        ],
      ),
    );
  }

  BorderRadius generalBubble() {
    return BorderRadius.circular(SizeManager.large);
  }

  BorderRadius middleBubble() {
    return BorderRadius.circular(SizeManager.medium);
  }

  Widget informationWidget() {
    return !chat.hasMessage
        ? const SizedBox.square(
            dimension: 0,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SizeManager.regular, vertical: SizeManager.regular),
            child: Text(
              chat.message!,
              style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: ColorManager.primary,
                  fontSize: FontSizeManager.regular * 0.95,
                  fontWeight: FontWeightManager.medium),
            ),
          );
  }

  Widget content() {
    final BorderRadius border = firstSender ? generalBubble() : middleBubble();

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular * 1.3,
          vertical: SizeManager.regular * 1),
      decoration: BoxDecoration(
        color: ColorManager.background,
        borderRadius: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (firstSender) ...[
            header(),
            smallSpacer(),
          ],
          if (chat.hasAttachment) ...[
            attachmentWidget(),
            smallSpacer(),
          ],
          informationWidget(),
        ],
      ),
    );
  }

  Widget attachmentWidget() {
    bool isUrl = chat.attachment!.startsWith("https://");
    final attachment = chat.attachment!;
    final thumbnail = chat.thumbnail;
    // log(attachment);
    return Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(
          minHeight: 100,
          maxHeight: 250,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManager.medium),
            image: !isUrl
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: chat.isImage
                        ? FileImage(File(attachment))
                        : MemoryImage(chat.thumbnail))
                : null),
        child: isUrl
            ? ClipRRect(
                borderRadius: BorderRadius.circular(SizeManager.large),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      width: double.maxFinite,
                      imageUrl:
                          chat.isImage ? attachment : thumbnail.toString(),
                      fit: BoxFit.cover,
                      height: double.maxFinite,
                      fadeInCurve: Curves.ease,
                      fadeOutCurve: Curves.ease,
                      placeholder: (context, url) {
                        return Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          color: ColorManager.lottieLoading,
                          child: LottieWidget(
                              lottieRes: AssetManager.lottieFile(
                                  name: "loading-image"),
                              size: const Size.square(
                                  IconSizeManager.extralarge)),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          color: ColorManager.lottieLoading,
                          child: LottieWidget(
                              lottieRes: AssetManager.lottieFile(
                                  name: "loading-image"),
                              size: const Size.square(
                                  IconSizeManager.extralarge)),
                        );
                      },
                    ),
                    if (!chat.isImage)
                      const Icon(
                        CupertinoIcons.play_fill,
                        color: Colors.white,
                        size: IconSizeManager.medium,
                      )
                  ],
                ),
              )
            : !chat.isImage
                ? const Icon(
                    CupertinoIcons.play_fill,
                    color: Colors.white,
                    size: IconSizeManager.medium,
                  )
                : null);
  }

  Widget stackedImages({required BuildContext context}) {
    final members = group.sortedMembers;
    final List<ImageProvider<Object>> images = chat.loading
        ? []
        : members
            .where((member) =>
                chat.readReceipts.contains(member.userId) &&
                member.userId != chat.senderId)
            .map<ImageProvider<Object>>(
              (e) => e.userId == group.adminId
                  ? AssetImage(AssetManager.imageFile(
                      name: "product-image-demo", ext: Extension.jpg))
                  : CachedNetworkImageProvider(e.profile),
            )
            .toList();

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
