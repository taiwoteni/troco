import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/features/customer%20care/domain/repositories/customer-care-repository.dart';
import 'package:troco/features/customer%20care/presentation/providers/chat-provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/audio-manager.dart';
import '../../../../core/app/file-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/platform.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/app/snackbar-manager.dart';
import '../../../../core/app/theme-manager.dart';
import '../../../../core/cache/shared-preferences.dart';
import '../../../../core/components/animations/lottie.dart';
import '../../../../core/components/images/profile-icon.dart';
import '../../../../core/components/images/svg.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../auth/presentation/providers/client-provider.dart';
import '../../../chat/domain/entities/chat.dart';

import 'package:path/path.dart' as Path;
import 'dart:math' as Math;
import '../widgets/chats-list.dart';

class CustomerCareChatScreen extends ConsumerStatefulWidget {
  const CustomerCareChatScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomerCareChatScreenState();
}

class _CustomerCareChatScreenState
    extends ConsumerState<CustomerCareChatScreen> {
  bool canUsePixels = false;
  final FocusNode messageNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final TextEditingController controller = TextEditingController();
  late String sessionId;
  String? path;
  Uint8List? thumbnail;
  FileStat? fileStat;
  late List<Chat> chats;
  bool sending = false;
  bool newMessage = false;
  bool fullScroll = true;
  bool isScrolling = false;
  bool deleting = false;

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
        bottomNavigationBar: bottomBar(),
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: ColorManager.tertiary,
          child: SingleChildScrollView(
              controller: scrollController, child: ChatLists(chats: chats)),
        ),
      ),
    );
  }

  @override
  void initState() {
    sessionId = AppStorage.getCustomerCareSessionId() ?? "00??";
    // Normally, this is meant to be set to preset cc chats
    chats = [
      ...AppStorage.getCustomerCareChats(),
      ...AppStorage.getUnsentCustomerCareChats()
    ];
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

      final read = chats.every(
        (element) => element.read,
      );
      if (read) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      } else {
        final firstUnreadChat = chats.firstWhere(
          (element) => !element.read,
        );
        final fraction = chats.indexOf(firstUnreadChat) / chats.length;
        scrollController
            .jumpTo(scrollController.position.maxScrollExtent * fraction);
      }
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

      /// Inorder to help the send buttons and action buttons
      /// rebuild their state.
      controller.addListener(() => setState(
            () {},
          ));
    });
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
          padding: EdgeInsets.only(
              left: SizeManager.medium,
              right: SizeManager.medium,
              top: path != null ? SizeManager.medium : SizeManager.large * 1.45,
              bottom: SizeManager.large * 1.45),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                  visible: path != null,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      attach(),
                      regularSpacer(),
                    ],
                  )),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(
                    vertical: SizeManager.regular,
                    horizontal: SizeManager.medium),
                decoration: BoxDecoration(
                    color: ColorManager.tertiary,
                    borderRadius:
                        BorderRadius.circular(SizeManager.extralarge)),
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
                    if (path != null || controller.text.trim().isNotEmpty)
                      AnimatedCrossFade(
                        firstCurve: Curves.ease,
                        secondCurve: Curves.ease,
                        duration: const Duration(milliseconds: 350),
                        crossFadeState: sending
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: IconButton(
                          onPressed: sendChat,
                          icon: SvgIcon(
                            svgRes: AssetManager.svgFile(name: "send"),
                            color: ColorManager.accentColor,
                            size:
                                const Size.square(IconSizeManager.medium * 0.9),
                          ),
                        ),
                        secondChild: Transform.scale(
                          scale: 1.7,

                          /// IconButton is used becos of the extra padding it gives to
                          /// its Child.
                          /// I normally won't use it but inorder to be uniform with
                          /// other icons and be level the bottom bar
                          /// with a fixed size throughout, It's needed
                          child: IconButton(
                            onPressed: null,
                            icon: LottieWidget(
                                color: ColorManager.accentColor,
                                fit: BoxFit.cover,
                                lottieRes:
                                    AssetManager.lottieFile(name: "loading"),
                                size: const Size.square(
                                    IconSizeManager.medium * 0.9)),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget attach() {
    return AnimatedContainer(
      width: double.maxFinite,
      height: path != null ? 80 : 0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeManager.regular),
        color: ColorManager.tertiary,
      ),
      curve: Curves.ease,
      duration: const Duration(milliseconds: 500),
      child: Row(
        children: [
          Container(
            width: SizeManager.small * 1.3,
            height: double.maxFinite,
            decoration: BoxDecoration(
                color: ColorManager.accentColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(SizeManager.regular),
                    bottomLeft: Radius.circular(SizeManager.regular))),
          ),
          smallSpacer(),
          Container(
            width: 80,
            height: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(SizeManager.regular),
                  bottomRight: Radius.circular(SizeManager.regular)),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: path == null
                      ? AssetImage(AssetManager.imageFile(
                          name: "nike-shoe-sample", ext: Extension.jpeg))
                      : thumbnail != null
                          ? MemoryImage(thumbnail!)
                          : FileImage(File(path!))),
            ),
            child: Visibility(
                visible: path != null && getMimeType().toLowerCase() == "video",
                child: const Icon(
                  CupertinoIcons.play_fill,
                  color: Colors.white,
                  size: IconSizeManager.regular,
                )),
          ),
          mediumSpacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              regularSpacer(),
              Text(
                getFileName(),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'lato',
                    color: ColorManager.primary,
                    fontSize: FontSizeManager.regular * 0.9,
                    fontWeight: FontWeightManager.semibold),
              ),
              smallSpacer(),
              Text(
                getMimeType(),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'lato',
                    color: ColorManager.secondary,
                    fontSize: FontSizeManager.small * 0.8,
                    fontWeight: FontWeightManager.medium),
              ),
              smallSpacer(),
              Text(
                getFileSize(),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'lato',
                    color: ColorManager.themeColor,
                    fontSize: FontSizeManager.small * 0.8,
                    fontWeight: FontWeightManager.semibold),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                setState(() {
                  path = null;
                  thumbnail = null;
                  fileStat = null;
                });
              },
              icon: Icon(
                CupertinoIcons.xmark_circle_fill,
                color: ColorManager.secondary,
                size: IconSizeManager.regular * 1.2,
              )),
          regularSpacer(),
        ],
      ),
    );
  }

  /// The AppBar contains the Groups icon, action button
  /// And business Days
  PreferredSizeWidget appBar() {
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
              onTap: () {
                // Navigator.pushNamed(context, Routes.viewGroupRoute,
                //     arguments: group);
              },
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
                  const CustomerCareProfileIcon(size: 47),
                ],
              ),
              title: const Text("Customer Service"),
              titleTextStyle: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: ColorManager.primary,
                  fontFamily: 'Lato',
                  fontSize: FontSizeManager.medium * 1.3,
                  fontWeight: FontWeightManager.semibold),
              subtitle: const Text("Troco customer care"),
              subtitleTextStyle: TextStyle(
                  color: ColorManager.secondary,
                  fontFamily: 'Quicksand',
                  fontSize: FontSizeManager.regular * 0.8,
                  fontWeight: FontWeightManager.medium),
            ),
          )),
    );
  }

  Future<void> pickFile({required final bool gallery}) async {
    final _file = await (gallery
        ? FileManager.pickMedia()
        : FileManager.pickImage(imageSource: ImageSource.camera));

    XFile? file = _file == null
        ? null
        : XFile(gallery ? (_file as XFile?)!.path : (_file as File?)!.path);
    if (file != null) {
      if (["Video", "Image"].contains(getMimeType(path: file.path))) {
        fileStat = await File(file.path).stat();
        if (getMimeType(path: file.path).toLowerCase() == "video") {
          await _generateThumbnail(filePath: file.path);
        } else {
          setState(() => thumbnail = null);
        }
        setState(() => path = file.path);
      } else {
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "Only Select Image or Video");
      }
    }
  }

  String getMimeType({final String? path}) {
    if ((path ?? this.path) == null) {
      return "";
    }

    final extension =
        Path.extension(path ?? this.path!).substring(1).toLowerCase();
    return (path ?? this.path) == null
        ? ""
        : ["jpeg", "jpg", "img", "png", "bmp", "gif"].contains(extension)
            ? "Image"
            : ["mp4", "mov", "vid"].contains(extension)
                ? "Video"
                : "Document";
  }

  String getFileSize() {
    final size = fileStat == null ? 0 : fileStat!.size;
    bool mb = size >= (1024 * 1024);

    final mbString = "${(size / (1024 * 1024)).toStringAsFixed(0)}MB";
    final kbString = "${(size / (1024)).toStringAsFixed(0)}KB";

    return mb ? mbString : kbString;
  }

  String getFileName() {
    if (path == null) {
      return "";
    }
    return "TROCO-${getMimeType()}${Path.extension(path!)}";
  }

  Future<void> _generateThumbnail({required final String filePath}) async {
    final _thumbnail = await VideoThumbnail.thumbnailData(
      video: filePath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    setState(() {
      thumbnail = _thumbnail;
    });
  }

  Future<void> sendChat() async {
    /// The method to send a chat.
    /// We also have to make a method to still add a chat to the [pendingChatListProvider].
    /// We would add the loading attribute to specify that it's loading.
    /// Then after we know that it was sent, We would update it that it's not loading.
    final String chatMessage = controller.text.trim();
    final chatId = "chat-${Math.Random().nextInt(1000) + 2000}";
    final attachmentPath = path;

    // We create a List of Chats Named Pending Chats and equate it to the one
    // used in the _ChatScreenState class in addition to the new chat that os about to be created.

    // Asign a random id, with all necessary attributes with the loading set to
    // false.
    final pendingChatJson = {
      "_id": chatId,
      "content": chatMessage.isEmpty ? null : chatMessage,
      "sender": ClientProvider.readOnlyClient!.userId,
      "profile": ClientProvider.readOnlyClient!.profile,
      "attachment": attachmentPath,
      "thumbnail": thumbnail,
      "read": false,
      "loading": true,
      "timestamp": DateTime.now().toUtc().toIso8601String()
    } as Map<dynamic, dynamic>;

    // Add it to the List Chats fro, the [pendingChatListProvider].
    final chat = Chat.fromJson(json: pendingChatJson);
    final _chats = [...chats, chat];
    setState(
      () => chats = _chats,
    );
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
    setState(() {
      path = null;
      fileStat = null;
    });
    controller.text = "";

    /// We send the Chat through the API.
    final response = await CustomerCareRepository.sendChat(
        content: chatMessage, sessionId: sessionId);
    debugPrint("Error Sending Chat: " + response.body);

    // if (!response.error) {
    //   // To show stopped-loading animation if sent
    //   // and is still not overwritten by provider.
    //   if (chats
    //       .map(
    //         (e) => e.chatId,
    //       )
    //       .contains(chatId)) {
    //     pendingChatJson["loading"] = false;
    //     setState(() =>
    //         chats[chats.indexOf(chat)] = Chat.fromJson(json: pendingChatJson));
    //   }
    //   AudioManager.playSource(source: AudioManager.sendSource);
    // } else {
    //   final unsentChats = AppStorage.getUnsentChats(groupId: group.groupId);
    //   unsentChats.add(chat);
    //   AppStorage.saveUnsentChats(chats: unsentChats, groupId: group.groupId);
    // }
  }

  Future<void> listenToChatChanges() async {
    ref.listen(chatsStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          final unsentChats = AppStorage.getUnsentCustomerCareChats();
          bool newMessage = !data.every((element) => element.read);
          if (newMessage) {
            AudioManager.playSource(source: AudioManager.receiveSource);
          }
          setState(() {
            chats = unsentChats.isNotEmpty ? [...data, ...unsentChats] : data;
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
        error: (error, stackTrace) => null,
        loading: () => null,
      );
    });
  }
}
