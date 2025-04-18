import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'dart:math' as Math;
import 'dart:developer';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/dialog-manager.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/platform.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/domain/repositories/chat-repository.dart';
import 'package:troco/features/chat/presentation/providers/chat-provider.dart';
import 'package:troco/features/chat/presentation/widgets/add-group-member.dart';
import 'package:troco/features/chat/presentation/widgets/chat-header.dart';
import 'package:troco/features/chat/presentation/widgets/chats-list.dart';
import 'package:troco/features/chat/presentation/widgets/leave-group-sheet.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';
import 'package:troco/features/groups/presentation/group_tab/providers/groups-provider.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../../core/app/audio-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/snackbar-manager.dart';
import '../../../transactions/presentation/create-transaction/providers/create-transaction-provider.dart';
import '../../../transactions/presentation/view-transaction/providers/transactions-provider.dart';
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
  bool isCreator = false;
  String? path;
  Uint8List? thumbnail;
  FileStat? fileStat;
  late List<Chat> chats;
  bool sending = false;
  bool newMessage = false;
  bool fullScroll = true;
  bool isScrolling = false;
  bool deleting = false;

  Transaction? transaction = null;

  @override
  void initState() {
    group = widget.group;
    chats = [
      ...AppStorage.getChats(groupId: group.groupId),
      ...AppStorage.getUnsentChats(groupId: group.groupId)
    ];
    isCreator = group.members.first == ClientProvider.readOnlyClient!.userId;
    transaction =
        AppStorage.getTransaction(transactionId: widget.group.groupId);
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      listenToGroupChanges();
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

  @override
  Widget build(BuildContext context) {
    /// To listen to Chat changes.
    /// In this methos i use stream.when. This can only be used in the Build Method.
    /// Do not remove from here.

    listenToChatChanges();
    listenToTransactionChanges();

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
                    Container(
                      width: 2.5,
                      height: 20,
                      decoration: BoxDecoration(
                          color: ColorManager.primary.withOpacity(0.10),
                          borderRadius:
                              BorderRadius.circular(SizeManager.large)),
                    ),
                    mediumSpacer(),
                    if (controller.text.trim().isEmpty && path == null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => pickFile(gallery: false),
                            icon: SvgIcon(
                              svgRes: AssetManager.svgFile(name: "camera"),
                              color: ColorManager.secondary,
                              size: const Size.square(
                                  IconSizeManager.medium * 0.9),
                            ),
                          ),
                          smallSpacer(),
                          IconButton(
                            onPressed: () => pickFile(gallery: true),
                            icon: SvgIcon(
                              svgRes: AssetManager.svgFile(name: "attach"),
                              color: ColorManager.secondary,
                              size: const Size.square(
                                  IconSizeManager.medium * 0.9),
                            ),
                          ),
                        ],
                      ),
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
    final bool hasExpired = group.transactionTime
        .add(const Duration(days: 1))
        .isBefore(DateTime.now());

    final String daysRemaining = hasExpired
        ? ""
        : "${group.transactionTime.difference(DateTime.now()).inDays + 1}";
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
              subtitle: Text(hasExpired
                  ? "Deadline reached"
                  : daysRemaining == "0"
                      ? "Last business day"
                      : "$daysRemaining business day${daysRemaining == "1" ? "" : "s"} left"),
              subtitleTextStyle: TextStyle(
                  color: hasExpired ? Colors.red : ColorManager.accentColor,
                  fontFamily: 'Quicksand',
                  fontSize: FontSizeManager.regular * 0.8,
                  fontWeight: FontWeightManager.medium),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed:
                        group.complete ? openTransactionPage : addGroupMember,
                    highlightColor: ColorManager.accentColor.withOpacity(0.15),
                    style: const ButtonStyle(
                        splashFactory: InkRipple.splashFactory),
                    icon: SvgIcon(
                      svgRes: AssetManager.svgFile(
                          name: !group.complete
                              ? "add-member"
                              : isCreator
                                  ? "delivery"
                                  : "buy"),
                      color: !group.complete
                          ? ColorManager.accentColor
                          : (group.hasTransaction
                              ? (isCreator
                                  ? ColorManager.accentColor
                                  : Colors.red)
                              : ColorManager.secondary),
                      size: const Size.square(IconSizeManager.regular * 1.3),
                    ),
                  ),
                  smallSpacer(),
                  Visibility(
                    visible: !group.hasTransaction,
                    child: IconButton(
                      onPressed: tryLeaveGroup,
                      highlightColor:
                          ColorManager.accentColor.withOpacity(0.15),
                      style: const ButtonStyle(
                          splashFactory: InkRipple.splashFactory),
                      icon: deleting
                          ? Transform.scale(
                              scale: 1.5,
                              child: LottieWidget(
                                  lottieRes:
                                      AssetManager.lottieFile(name: "loading"),
                                  color: Colors.red,
                                  size: const Size.square(
                                      IconSizeManager.regular * 1.3)),
                            )
                          : SvgIcon(
                              flip: true,
                              size: const Size.square(
                                  IconSizeManager.regular * 1.3),
                              color: Colors.red,
                              svgRes:
                                  AssetManager.svgFile(name: "remove-user")),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Future<void> tryLeaveGroup() async {
    final hasBuyer = group.members.length >= 3;
    final isSeller = group.creator == ClientProvider.readOnlyClient!.userId;
    if (!hasBuyer) {
      final go = await askLeaveGroup();
      if (!go) {
        return;
      }

      final removeSelf =
          await leaveGroup(userId: ClientProvider.readOnlyClient!.userId);

      if (removeSelf) {
        SnackbarManager.showBasicSnackbar(
            context: context, message: "Order deleted.");
        context.pop();
        return;
      }

      SnackbarManager.showErrorSnackbar(
          context: context,
          message: "Couldn't delete order. Try again some other time");
      return;
    }

    if (!isSeller) {
      final askLeave = await askLeaveGroup();
      if (askLeave) {
        /// Would return true if the buyer left without fail
        final deleteRequestResponse = await leaveGroup(userId: group.buyerId);

        if (deleteRequestResponse) {
          SnackbarManager.showBasicSnackbar(
              context: context, message: "Left Order.");
          context.pop();
          return;
        }

        SnackbarManager.showErrorSnackbar(
            context: context,
            message: "Couldn't leave order. Try again some other time");
        return;
      }
      return;
    }

    /// Would return null if nothing was selected but true if to remove buyer;
    final deleteBuyer =
        await LeaveGroupSheet.bottomSheet(context: context, group: group);
    if (deleteBuyer == null) {
      return;
    }

    final yes = await (deleteBuyer ? askRemoveBuyer() : askLeaveGroup());

    if (!yes) {
      return;
    }

    final response =
        await leaveGroup(userId: deleteBuyer ? group.buyerId : group.creator);
    if (response) {
      SnackbarManager.showBasicSnackbar(
          context: context,
          message: deleteBuyer ? "Removed Member from Order" : "Deleted Order");
      if (!deleteBuyer) {
        context.pop();
      }
      return;
    }

    SnackbarManager.showErrorSnackbar(
        context: context,
        message: "Error ${deleteBuyer ? "removing buyer" : "deleting order"}");
    return;
  }

  Future<bool> leaveGroup({required final String userId}) async {
    setState(
      () => deleting = true,
    );
    final leaveResponse =
        await GroupRepo.leaveGroup(userId: userId, group: group);

    // Manually delete a group if the person being removed is you
    if (userId == ClientProvider.readOnlyClient?.userId) {
      if (!leaveResponse.error) {
        final groups = AppStorage.getGroups();
        if (groups.any(
          (element) => element.groupId == group.groupId,
        )) {
          groups.removeWhere(
            (element) => element.groupId == group.groupId,
          );
          AppStorage.saveGroups(groups: groups);
        }
        ref.read(groupsListProvider.notifier).state = ref
            .read(groupsListProvider)
            .where((group) => group.groupId != this.group.groupId)
            .toList();
      }
    }

    setState(
      () => deleting = false,
    );
    return !leaveResponse.error;
  }

  Future<bool> askRemoveBuyer() async {
    final dialogManager = DialogManager(context: context);
    final response = await dialogManager.showDialogContent<bool?>(
          title: "Remove Member?",
          icon: Container(
            decoration: BoxDecoration(
                color: Colors.red.shade100, shape: BoxShape.circle),
            width: 60,
            height: 60,
            child: ProfileIcon(
              url: group.buyer?.profile,
              size: double.maxFinite,
            ),
          ),
          description:
              "Are you sure you want to remove ${group.buyer?.firstName ?? "the buyer"}?\nThis cannot be undone.",
          cancelLabel: "Remove",
          onCancel: () {
            context.pop(result: true);
          },
        ) ??
        false;

    return response;
  }

  Future<bool> askLeaveGroup() async {
    final dialogManager = DialogManager(context: context);
    final response = await dialogManager.showDialogContent<bool?>(
          title: "Leave Order",
          icon: Container(
            decoration: BoxDecoration(
                color: Colors.red.shade100, shape: BoxShape.circle),
            width: 60,
            height: 60,
            child: Transform.scale(
              scale: 0.6,
              child: SvgIcon(
                  flip: true,
                  size: const Size.square(IconSizeManager.regular * 0.2),
                  color: Colors.red,
                  svgRes: AssetManager.svgFile(name: "remove-user")),
            ),
          ),
          description:
              "Are you sure you want to leave this order?\nThis cannot be undone.",
          cancelLabel: "Yes, leave",
          onCancel: () {
            context.pop(result: true);
          },
        ) ??
        false;

    return response;
  }

  Future<void> openTransactionPage() async {
    if (group.transactionIsHampered) {
      if (!isCreator) {
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Waiting for creator to add items",
            mode: ContentType.help);
      }
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message:
              "${group.transaction.transactionCategory == TransactionCategory.Product ? "Product" : "Service"}(s) are missing. Add the required.");
      TransactionDataHolder.assignFrom(transaction: group.transaction);
      ref.read(createTransactionProgressProvider.notifier).state = 2;
      await Navigator.pushNamed(context, Routes.createTransactionRoute,
          arguments: group);
      ref.watch(createTransactionProgressProvider.notifier).state = 0;
      return;
    }
    if (group.hasTransaction) {
      ref.read(currentTransactionProvider.notifier).state = transaction!;
      Navigator.pushNamed(context, Routes.viewTransactionRoute,
          arguments: transaction);
    } else {
      if (isCreator) {
        if (group.members.length >= 2) {
          await Navigator.pushNamed(context, Routes.createTransactionRoute,
              arguments: group);
          ref.watch(createTransactionProgressProvider.notifier).state = 0;
        } else {
          SnackbarManager.showBasicSnackbar(
              context: context,
              message: "Add a buyer",
              mode: ContentType.warning);
        }
      } else {
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Creator hasn't made a transaction yet",
            mode: ContentType.help);
      }
    }
  }

  void addGroupMember() {
    if (group.members.length < 2) {
      SnackbarManager.showBasicSnackbar(
        context: context,
        message: "You already have a buyer",
      );
      return;
    }
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) {
        return AddGroupMemberWidget(group: group);
      },
    );
  }

  void showMaintenanceMessage() {
    SnackbarManager.showBasicSnackbar(
        context: context,
        message: "This part is currently under construction or maintenance");
  }

  Widget? fabWidget() {
    return canUsePixels && chats.isNotEmpty
        ? Visibility(
            visible: !fullScroll ? !isScrolling : false,
            maintainAnimation: true,
            maintainState: true,
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
              backgroundColor: newMessage
                  ? ColorManager.accentColor
                  : ColorManager.background,
              foregroundColor: newMessage
                  ? ColorManager.primaryDark
                  : ColorManager.accentColor,
              child: const Icon(
                CupertinoIcons.chevron_down,
                size: IconSizeManager.small,
              ),
            ),
          )
        : null;
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
    final response = await (attachmentPath == null
        ? ChatRepo.sendChat(groupId: group.groupId, message: chatMessage)
        : ChatRepo.sendAttachment(
            groupId: group.groupId,
            message: chatMessage,
            thumbnail: thumbnail,
            attachment: attachmentPath));
    log(response.body);

    if (!response.error) {
      // To show stopped-loading animation if sent
      // and is still not overwritten by provider.
      if (chats
          .map(
            (e) => e.chatId,
          )
          .contains(chatId)) {
        pendingChatJson["loading"] = false;
        setState(() =>
            chats[chats.indexOf(chat)] = Chat.fromJson(json: pendingChatJson));
      }
      AudioManager.playSource(source: AudioManager.sendSource);
    } else {
      final unsentChats = AppStorage.getUnsentChats(groupId: group.groupId);
      unsentChats.add(chat);
      AppStorage.saveUnsentChats(chats: unsentChats, groupId: group.groupId);
    }
    // else {
    //   if (ref.watch(pendingChatListProvider(group.groupId)).isNotEmpty &&
    //       ref.watch(pendingChatListProvider(group.groupId)).last.chatId ==
    //           chatId) {
    //     /// If the Chat is added Successfully we change the loading value to false.
    //     pendingChatJson["loading"] = false;
    //     final pendingChat = ref
    //         .watch(pendingChatListProvider(group.groupId))
    //         .firstWhere((element) => element.chatId == pendingChatJson["_id"]);
    //     final index = ref
    //         .watch(pendingChatListProvider(group.groupId))
    //         .indexOf(pendingChat);
    //     ref
    //         .watch(pendingChatListProvider(group.groupId).notifier)
    //         .state[index] = Chat.fromJson(json: pendingChatJson);
    //   }
    // }
  }

  Future<void> listenToChatChanges() async {
    ref.watch(groupsStreamProvider);
    ref.listen(chatsStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          final unsentChats = AppStorage.getUnsentChats(groupId: group.groupId);
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

  Future<void> listenToGroupChanges() async {
    ref.listenManual(groupsStreamProvider, (previous, next) {
      next.whenData((value) {
        if (value.map((e) => e.groupId).contains(group.groupId)) {
          final singleGroup =
              value.firstWhere((element) => element.groupId == group.groupId);
          if (group.members.length != singleGroup.members.length) {
            setState(
              () {
                group = singleGroup;
              },
            );
          }
        }
      });
    });
  }

  Future<void> listenToTransactionChanges() async {
    ref.listenManual(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        final index = value.lastIndexWhere(
          (element) => element.transactionId == group.groupId,
        );
        if (index != -1) {
          setState(() {
            transaction = value[index];
          });
        } else {
          setState(() {
            transaction = null;
          });
        }
      });
    });
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
}
