// ignore_for_file: unused_element

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/images/stacked-image-list.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';
import 'package:troco/features/chat/domain/repositories/chat-repository.dart';
import 'package:troco/features/chat/presentation/providers/chat-provider.dart';
import 'package:troco/features/chat/presentation/widgets/edit-chat-sheet.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/routes-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/app/snackbar-manager.dart';
import '../../../../core/components/animations/lottie.dart';
import '../../../customer care/domain/repositories/customer-care-repository.dart';
import '../../../groups/domain/entities/group.dart';

class ChatWidget extends ConsumerStatefulWidget {
  final Chat chat;
  final Group group;
  final bool firstSender, lastSender, sameSender, lastMessage, lastSent;
  const ChatWidget(
      {super.key,
      required this.chat,
      required this.group,
      this.lastSent = false,
      this.lastMessage = false,
      this.firstSender = true,
      this.sameSender = false,
      this.lastSender = false});

  @override
  ConsumerState<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  late Chat chat;
  late bool firstSender, lastSender, sameSender, lastMessage, lastSent;
  late bool isSender, alignViewsBottom, failed;
  late String groupId;
  late Group group;
  late bool showViews;
  late FocusNode focusNode;

  @override
  void initState() {
    chat = widget.chat;
    groupId = widget.group.groupId;
    group = widget.group;
    firstSender = widget.firstSender;
    lastSender = widget.lastSender;
    sameSender = widget.sameSender;
    lastMessage = widget.lastMessage;
    lastSent = widget.lastSent;
    isSender = ClientProvider.readOnlyClient!.userId == chat.senderId;
    alignViewsBottom = chat.hasAttachment ? true : chat.message!.length >= 116;
    failed = chat.loading &&
        AppStorage.getUnsentChats(groupId: groupId).contains(chat);
    showViews = (lastMessage ? true : lastSender) && isSender;
    focusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final durationNotExceeded =
        DateTime.now().difference(chat.time).inMinutes <= 20;
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
          left: (lastSender ? lastSender : lastMessage) && !isSender ? 0 : 55,
          right: SizeManager.medium,
          // bottom: lastSender?,
          top: sameSender

              /// I removed lastSender from the [top: lastSender || sameSender]
              /// because sameSender is always true if it is the lastSender.
              ? SizeManager.small * 0.85
              : firstSender
                  ? SizeManager.medium * 1.2
                  : SizeManager.small * 0.85),
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
              GestureDetector(
                onTap: failed ? resend : null,
                child: isSender
                    ? (durationNotExceeded
                        ? CustomPopup(
                            isLongPress: true,
                            content: options(),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: SizeManager.large * 1.2),
                            child: bubbleWidget(),
                          )
                        : bubbleWidget())
                    : bubbleWidget(),
              ),
              profileIcon(isSender: isSender),
              loadingWidget(),
            ],
          ),
          if (showViews) stackedImages(context: context),
        ],
      ),
    );
  }

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

  Widget bubbleWidget() {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .6),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (chat.hasAttachment) ...[
            attachmentWidget(),
            smallSpacer(),
          ],
          if (chat.hasMessage) content(),
        ],
      ),
    );
  }

  Widget content() {
    final BorderRadius border = firstSender
        ? firstBubble(isSender: isSender)
        : !lastSender
            ? lastMessage
                ? lastBubble(isSender: isSender)
                : generalBubble()
            : lastBubble(isSender: isSender);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.regular * 1.3,
          vertical: SizeManager.regular * 1),
      decoration: BoxDecoration(
        color: isSender
            ? failed
                ? Colors.red
                : chat.readByOthers
                    ? ColorManager.accentColor
                    : ColorManager.themeColor
            : ColorManager.background,
        borderRadius: border,
      ),
      child: informationWidget(),
    );
  }

  Widget loadingWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.ease,
      width: chat.loading || failed
          ? IconSizeManager.regular + SizeManager.small
          : 0,
      alignment: Alignment.centerRight,
      child: failed
          ? const Icon(
              Icons.upload,
              color: Colors.red,
              size: IconSizeManager.regular,
            )
          : Transform.scale(
              scale: 1.6,
              child: LottieWidget(
                  lottieRes: AssetManager.lottieFile(name: "loading"),
                  size: const Size.square(IconSizeManager.regular),
                  color: ColorManager.secondary),
            ),
    );
  }

  Future<void> resend() async {
    setState(() => failed = false);
    final unsent =
        AppStorage.getUnsentChats(groupId: ref.watch(chatsGroupProvider));
    unsent.remove(chat);
    AppStorage.saveUnsentChats(
        chats: unsent, groupId: ref.watch(chatsGroupProvider));
    final response = await (chat.hasAttachment
        ? ChatRepo.sendAttachment(
            groupId: ref.watch(chatsGroupProvider),
            message: chat.message,
            attachment: chat.attachment!)
        : ChatRepo.sendChat(
            groupId: ref.watch(chatsGroupProvider), message: chat.message!));
    log(response.body);
    setState(() {
      failed = response.error;
    });

    if (response.error) {
      unsent.add(chat);
      AppStorage.saveUnsentChats(
          chats: unsent, groupId: ref.watch(chatsGroupProvider));
    }
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

  Widget attachmentWidget() {
    bool isUrl = chat.attachment!.startsWith("https://");
    final attachment = chat.attachment!;
    final thumbnail = chat.thumbnail;
    // log(attachment);
    return Hero(
      tag: chat.chatId,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Routes.viewAttachmentRoute,
              arguments: [chat, group]);
        },
        child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 250,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeManager.large),
                image: !isUrl
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: chat.isImage
                            ? FileImage(File(attachment))
                            : MemoryImage(thumbnail as Uint8List))
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
                          color: chat.isImage
                              ? null
                              : Colors.white.withOpacity(0.5),
                          colorBlendMode: chat.isImage ? null : BlendMode.hue,
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
                            size: IconSizeManager.large,
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
                    : null),
      ),
    );
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
                      name: "no_profile", ext: Extension.webp))
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

  Future<void> deleteMessage() async {
    FocusScope.of(context).requestFocus(focusNode);

    final result =
        await ChatRepo.deleteChat(chat: chat, groupId: group.groupId);

    debugPrint(result.body);

    if (result.error) {
      SnackbarManager.showBasicSnackbar(
        context: context,
        mode: ContentType.failure,
        message: "Error deleting message",
      );
      return;
    }
  }

  Future<void> editMessage() async {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
            child: EditChatSheet(
          chat: chat,
          group: group,
        ));
      },
    );
  }

  Widget options() {
    final textStyle = TextStyle(
        color: ColorManager.primary,
        fontFamily: 'lato',
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.bold);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chat.hasMessage) ...[
          GestureDetector(
            onTap: editMessage,
            child: Text(
              "Edit",
              style: textStyle.copyWith(color: ColorManager.accentColor),
            ),
          ),
          mediumSpacer()
        ],
        GestureDetector(
          onTap: deleteMessage,
          child: Text(
            "Delete",
            style: textStyle.copyWith(color: Colors.red),
          ),
        )
      ],
    );
  }
}
