import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/platform.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/basecomponents/animations/lottie.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/domain/repositories/chat-repository.dart';
import 'package:troco/features/chat/presentation/providers/chat-provider.dart';
import 'package:troco/features/chat/presentation/widgets/chat-header.dart';
import 'package:troco/features/chat/presentation/widgets/chats-list.dart';

import '../../../../core/app/font-manager.dart';
import '../../domain/entities/chat.dart';
import '../../../groups/domain/entities/group.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Group group;
  const ChatScreen({super.key, required this.group});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late Group group;
  bool canUsePixels = false;
  final FocusNode messageNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  late StreamSubscription chatStreamSubscription;
  late List<Chat> chats;
  bool sending = false;
  bool newMessage = false;
  bool fullScroll = true;
  bool isScrolling = false;

  @override
  void initState() {
    group = widget.group;
    chats = AppStorage.getChats(groupId: group.groupId);
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getChatUiOverlayStyle());
      scrollController.addListener(() {
        if (fullScroll) {
          if (scrollController.position.pixels.toInt() <
              scrollController.position.maxScrollExtent.toInt()) {
            setState(
              () => fullScroll = false,
            );
          }
        } else {
          if (scrollController.position.pixels.toInt() >=
              scrollController.position.maxScrollExtent.toInt()) {
            setState(
              () => fullScroll = true,
            );
          }
        }
      });
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      setState(
        () => canUsePixels = true,
      );
      messageNode.addListener(() {
        if (messageNode.hasFocus) {
          if (!AppPlatform.isDesktop) {
            setState(() => fullScroll = false);
          }
        }
      });
    });

    /// Inorder to help the send buttons and action buttons
    /// rebuild their state.
    controller.addListener(() => setState(
          () {},
        ));
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listenToChatChanges();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: appBar(),
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: ColorManager.tertiary,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                if (chats.isEmpty)
                  Column(
                    children: [
                      Gap(75 + MediaQuery.of(context).viewPadding.top),
                      ChatHeader(chats: chats, group: group),
                    ],
                  )
                else
                  ChatLists(chats: chats, group: group)
              ],
            ),
          ),
        ),
        floatingActionButton: fabWidget(),
        bottomNavigationBar: bottomBar(),
      ),
    );
  }

  /// The BottomBar that contains the  InputField
  /// to send messages and attachments
  Widget bottomBar() {
    return Container(
      padding: EdgeInsets.zero,
      width: double.maxFinite,
      constraints: const BoxConstraints(minHeight: 108, maxHeight: 250),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.large * 1.5)),
          boxShadow: [
            BoxShadow(
                offset: kElevationToShadow[1]![0].offset,
                blurRadius: kElevationToShadow[1]![0].blurRadius,
                blurStyle: kElevationToShadow[1]![0].blurStyle,
                spreadRadius: kElevationToShadow[1]![0].spreadRadius,
                color: ColorManager.secondary.withOpacity(0.2))
          ]),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SizeManager.large * 1.5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: SizeManager.medium,
              vertical: SizeManager.large * 1.45),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
                vertical: SizeManager.regular, horizontal: SizeManager.medium),
            decoration: BoxDecoration(
                color: ColorManager.tertiary,
                borderRadius: BorderRadius.circular(SizeManager.extralarge)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    cursorColor: ColorManager.accentColor,
                    focusNode: messageNode,
                    cursorRadius: const Radius.circular(SizeManager.large),
                    autofocus: false,
                    maxLines: null,
                    expands: false,
                    style: TextStyle(
                        color: ColorManager.primary,
                        fontFamily: 'Lato',
                        fontSize: FontSizeManager.regular,
                        fontWeight: FontWeightManager.medium),
                    decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "Type a Message",
                        filled: true,
                        fillColor: Colors.transparent,
                        hintStyle: TextStyle(
                            color: ColorManager.secondary,
                            fontFamily: 'Lato',
                            fontSize: FontSizeManager.regular,
                            fontWeight: FontWeightManager.medium)),
                  ),
                ),
                regularSpacer(),
                Container(
                  width: 2.5,
                  height: 20,
                  decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(SizeManager.large)),
                ),
                mediumSpacer(),
                if (controller.text.trim().isEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIcon(
                        svgRes: AssetManager.svgFile(name: "camera"),
                        color: ColorManager.secondary,
                        size: const Size.square(IconSizeManager.medium * 0.9),
                      ),
                      mediumSpacer(),
                      SvgIcon(
                        svgRes: AssetManager.svgFile(name: "attach"),
                        color: ColorManager.secondary,
                        size: const Size.square(IconSizeManager.medium * 0.9),
                      ),
                    ],
                  ),
                if (controller.text.trim().isNotEmpty)
                  AnimatedCrossFade(
                    firstCurve: Curves.ease,
                    secondCurve: Curves.ease,
                    duration: const Duration(milliseconds: 350),
                    crossFadeState: sending
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: GestureDetector(
                      onTap: sendChat,
                      child: SvgIcon(
                        svgRes: AssetManager.svgFile(name: "send"),
                        color: ColorManager.accentColor,
                        size: const Size.square(IconSizeManager.medium),
                      ),
                    ),
                    secondChild: Transform.scale(
                      scale: 1.7,
                      child: LottieWidget(
                          color: ColorManager.accentColor,
                          fit: BoxFit.cover,
                          lottieRes: AssetManager.lottieFile(name: "loading"),
                          size: const Size.square(IconSizeManager.medium)),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The AppBar contains the Groups icon, action button
  /// And business Days
  PreferredSizeWidget appBar() {
    /// Not using the usual [DateTime.day]- [Now.day] because of
    /// Situations whereby the days may not be of the same month.
    /// becos [DateTime.day] is the day of the month.
    final String daysRemaining =
        "${DateTime.now().difference(DateTime.now()).inDays + 1}";
    return PreferredSize(
      preferredSize:
          Size.fromHeight(75 + MediaQuery.of(context).viewPadding.top),
      child: Container(
          padding: const EdgeInsets.only(
              left: SizeManager.regular, right: SizeManager.medium),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(SizeManager.large * 1.5)),
              boxShadow: [
                BoxShadow(
                    offset: kElevationToShadow[1]![0].offset,
                    blurRadius: kElevationToShadow[1]![0].blurRadius,
                    blurStyle: kElevationToShadow[1]![0].blurStyle,
                    spreadRadius: kElevationToShadow[1]![0].spreadRadius,
                    color: ColorManager.secondary.withOpacity(0.08))
              ]),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(SizeManager.large * 1.5)),
            child: ListTile(
              tileColor: Colors.transparent,
              dense: true,
              contentPadding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top +
                      SizeManager.regular,
                  right: SizeManager.small,
                  bottom: SizeManager.regular),
              horizontalTitleGap: SizeManager.medium * 0.8,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SvgIcon(
                        svgRes: AssetManager.svgFile(name: 'back-chat'),
                        color: ColorManager.accentColor,
                        size: const Size.square(IconSizeManager.regular * 1.5),
                      )),
                  const GroupProfileIcon(
                    size: 47,
                  ),
                ],
              ),
              title: Text(group.groupName),
              titleTextStyle: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: ColorManager.primary,
                  fontFamily: 'Lato',
                  fontSize: FontSizeManager.medium * 1.3,
                  fontWeight: FontWeightManager.semibold),
              subtitle: Text(daysRemaining == "0"
                  ? "Last business day"
                  : "$daysRemaining business day${daysRemaining == "1" ? "" : "s"} left"),
              subtitleTextStyle: TextStyle(
                  color: ColorManager.accentColor,
                  fontFamily: 'Quicksand',
                  fontSize: FontSizeManager.regular * 0.8,
                  fontWeight: FontWeightManager.medium),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, Routes.createTransactionRoute);
                    },
                    highlightColor: ColorManager.accentColor.withOpacity(0.15),
                    style: const ButtonStyle(
                        splashFactory: InkRipple.splashFactory),
                    icon: SvgIcon(
                      svgRes: AssetManager.svgFile(name: "buy"),
                      color: group.members.isEmpty
                          ? ColorManager.secondary
                          : ColorManager.accentColor,
                      size: const Size.square(IconSizeManager.regular * 1.3),
                    ),
                  ),
                  regularSpacer(),
                  IconButton(
                    onPressed: () => null,
                    highlightColor: ColorManager.accentColor.withOpacity(0.15),
                    style: const ButtonStyle(
                        splashFactory: InkRipple.splashFactory),
                    icon: SvgIcon(
                      svgRes: AssetManager.svgFile(name: "add-member"),
                      color: ColorManager.accentColor,
                      size: const Size.square(IconSizeManager.regular * 1.3),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget? fabWidget() {
    return canUsePixels && chats.isNotEmpty
        ? Visibility(
            visible: !fullScroll ? !isScrolling : false,
            child: FloatingActionButton.small(
              onPressed: () async {
                setState(() {
                  newMessage = false;
                  isScrolling = true;
                });
                await scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.ease);
                setState(() => isScrolling = false);
              },
              shape: const StadiumBorder(),
              backgroundColor: ColorManager.background,
              foregroundColor: ColorManager.accentColor,
              child: const Icon(
                CupertinoIcons.chevron_down,
                size: IconSizeManager.small,
              ),
            ),
          )
        : null;
  }

  Future<void> sendChat() async {
    final String chatMessage = controller.text.trim();
    setState(() => sending = true);
    final response = await ChatRepo.sendChat(
        groupId: group.groupId,
        userId: ref.read(ClientProvider.userProvider)!.userId,
        message: chatMessage);
    setState(() {
      sending = false;
    });
    if (response.error) {
      log("Error When Sending Chat:${response.body}");
    } else {
      controller.text = "";
    }
  }

  Future<void> listenToChatChanges() async {
    ref.listen(chatsStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          setState(() {
            chats = data;
            newMessage = data.isEmpty
                ? false
                : !chats.last.read &&
                    chats.last.senderId !=
                        ref.read(ClientProvider.userProvider)!.userId;
          });
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent) {
            WidgetsFlutterBinding.ensureInitialized()
                .addPostFrameCallback((timeStamp) async {
              setState(() => isScrolling = true);
              await scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease);
              setState(() => isScrolling = false);
            });
          }
        },
        error: (error, stackTrace) => log(error.toString()),
        loading: () => null,
      );
    });
  }
}
