import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/custom-views/profile-icon.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/models/client.dart';
import 'package:troco/providers/client-provider.dart';

import '../../app/font-manager.dart';
import '../../custom-views/chat-widget.dart';
import '../../models/chat-model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Client client;
  const ChatScreen({super.key, required this.client});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late Client recipient;
  bool canUsePixels = false;
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  bool fullScroll = false;
  List<Chat> chats = [];

  @override
  void initState() {
    recipient = widget.client;
    chats = chatList();
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getChatUiOverlayStyle());
      scrollController.addListener(() {
        if (fullScroll) {
          if (scrollController.position.pixels <
              scrollController.position.maxScrollExtent) {
            setState(
              () => fullScroll = false,
            );
          }
        } else {
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent) {
            setState(
              () => fullScroll = true,
            );
          }
        }
      });
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 800), curve: Curves.ease);
      setState(
        () => canUsePixels = true,
      );
    });
    controller.addListener(() => setState(() {}));
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
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(79.33 + MediaQuery.of(context).viewPadding.top),
            child: appBar()),
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: ColorManager.tertiary,
          padding: const EdgeInsets.only(
            left: 0,
            right: 0,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                mediumSpacer(),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: chats.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final Chat currentChat = chats[index];

                    final bool isFirstMessage = index == 0;
                    final bool isLastMessage = index == chats.length - 1;
                    bool sameSender = false,
                        firstTimeSender = true,
                        lastTimeSender = false;

                    if (!isFirstMessage && !isLastMessage) {
                      sameSender =
                          currentChat.senderId == chats[index - 1].senderId;
                    }
                    if (!isFirstMessage) {
                      firstTimeSender =
                          currentChat.senderId != chats[index - 1].senderId;
                    }
                    if (!isLastMessage) {
                      lastTimeSender =
                          currentChat.senderId != chats[index + 1].senderId;
                    } else {
                      if (!isFirstMessage) {
                        lastTimeSender =
                            currentChat.senderId == chats[index - 1].senderId;
                      }
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: isLastMessage ? SizeManager.large : 0),
                      child: ChatWidget(
                        deviceClient: ref.read(ClientProvider.userProvider)!,
                        chat: currentChat,
                        recipient: widget.client,
                        firstSender: firstTimeSender,
                        lastSender: lastTimeSender,
                        sameSender: sameSender,
                        lastMessage: isLastMessage,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: fabWidget(),
        bottomNavigationBar: bottomBar(),
      ),
    );
  }

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
                  SvgIcon(
                    svgRes: AssetManager.svgFile(name: "send"),
                    color: ColorManager.accentColor,
                    size: const Size.square(IconSizeManager.medium),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Container(
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
                  color: ColorManager.secondary.withOpacity(0.2))
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
                ProfileIcon(
                  size: 45,
                  profile: DecorationImage(
                      fit: BoxFit.cover,
                      // TODO: CHANGE TO NETWORK ONCE FINBAR GIVES APIs
                      image: FileImage(File(recipient.profile))),
                ),
              ],
            ),
            title: Text(recipient.fullName),
            titleTextStyle: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: ColorManager.primary,
                fontFamily: 'Lato',
                fontSize: FontSizeManager.medium * 1.3,
                fontWeight: FontWeightManager.semibold),
            subtitle: const Text("online"),
            subtitleTextStyle: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'Quicksand',
                fontSize: FontSizeManager.regular * 0.8,
                fontWeight: FontWeightManager.regular),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgIcon(
                  svgRes: AssetManager.svgFile(name: "video-call"),
                  color: ColorManager.accentColor,
                  size: const Size.square(IconSizeManager.regular * 1.3),
                ),
                mediumSpacer(),
                SvgIcon(
                  svgRes: AssetManager.svgFile(name: "audio-call"),
                  color: ColorManager.accentColor,
                  size: const Size.square(IconSizeManager.regular * 1.3),
                )
              ],
            ),
          ),
        ));
  }

  Widget? fabWidget() {
    return canUsePixels
        ? Visibility(
            visible: !fullScroll,
            child: FloatingActionButton.small(
              onPressed: () {
                scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.ease);
              },
              shape: const StadiumBorder(),
              backgroundColor: ColorManager.accentColor,
              foregroundColor: Colors.white,
              child: const Icon(
                CupertinoIcons.chevron_down,
                size: IconSizeManager.small,
              ),
            ),
          )
        : null;
  }

  List<Chat> chatList() {
    return [
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "Hey Teni, How're You? 🙃",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiut",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message": "I'm Good You? 😎",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "Yh. I'm Good. How's School?",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "I heard that you aren't going to Babcock anymore",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "So which Uni, are you currently going to?",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiutcd",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message": "I'm Going to NIIT",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiutcd",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message": "Meaning National Institute Of Innovative Technology",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      const Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "message": "Oh wow?",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
      Chat.fromJson(json: {
        "id": "Alznccdsiutcd",
        "sender id": ref.read(ClientProvider.userProvider)!.userId,
        "message":
            "It's an institution that teaches both older (working class) and younger age groups Tech related courses. Both standalone and Full courses. It's used to learn and acquire skills for jobs. But they also have a special programme for those learning Software Engineering. Those learning S.E are taught for 2 yrs but given their well known reputation, Universities also admit students who have finished the two years and enables them to join directly into yhe final year.",
        "time": "2024-03-04T00:00:00.000",
        "read": false
      }),
      Chat.fromJson(json: {
        "id": "AlznchfU-jsa",
        "sender id": "AlzbchdUisdn0i9",
        "attachment": ref.read(ClientProvider.userProvider)!.profile,
        "message": "Why use this as ur Dp 😂?",
        "time": "2024-03-04T00:00:00.000",
        "read": true
      }),
    ];
  }
}
