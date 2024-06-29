import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/images/profile-icon.dart';
import '../../../../core/components/images/svg.dart';
import '../../../groups/domain/entities/group.dart';
import '../../domain/entities/chat.dart';

class ViewAttachmentScreen extends ConsumerStatefulWidget {
  final Chat chat;
  final Group group;
  const ViewAttachmentScreen(
      {super.key, required this.chat, required this.group});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewAttachmentScreenState();
}

class _ViewAttachmentScreenState extends ConsumerState<ViewAttachmentScreen> {
  late Group group;
  late Chat chat;
  // final MediaDownload download = MediaDownload();
  bool downloading = false;

  @override
  void initState() {
    group = widget.group;
    chat = widget.chat;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.tertiary,
      appBar: appBar(),
      body: Center(
        child: Hero(
          tag: chat.chatId,
          transitionOnUserGestures: true,
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: chat.attachment!.startsWith("https://")
                        ? CachedNetworkImageProvider(chat.attachment!)
                        : FileImage(File(chat.attachment!)))),
          ),
        ),
      ),
    );
  }

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
              subtitle: Text(
                  "Sent by ${chat.senderId == ClientProvider.readOnlyClient!.userId ? "You" : (chat.senderId == group.seller.userId ? "Seller" : (chat.senderId != group.adminId ? "Buyer" : "Admin"))}"),
              subtitleTextStyle: TextStyle(
                  color: ColorManager.accentColor,
                  fontFamily: 'Quicksand',
                  fontSize: FontSizeManager.regular * 0.8,
                  fontWeight: FontWeightManager.medium),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  downloading
                      ? LottieWidget(
                          lottieRes: AssetManager.lottieFile(name: "loading"),
                          color: ColorManager.accentColor,
                          size:
                              const Size.square(IconSizeManager.regular * 1.3))
                      : IconButton(
                          onPressed: downloadFile,
                          highlightColor:
                              ColorManager.accentColor.withOpacity(0.15),
                          style: const ButtonStyle(
                              splashFactory: InkRipple.splashFactory),
                          icon: Icon(
                            CupertinoIcons.arrow_down_to_line,
                            color: ColorManager.accentColor,
                            size: IconSizeManager.regular * 1.3,
                          )),
                ],
              ),
            ),
          )),
    );
  }

  Future<void> downloadFile() async {
    setState(()=> downloading=true);
    // final directory = await getApplicationDocumentsDirectory();
    // await download.downloadMedia(context, chat.attachment!, directory.path,
    //     "Troco-${chat.isImage ? "Image" : "Video"}-${DateFormat.jms().format(DateTime.now())}.${chat.attachment!.substring(chat.attachment!.lastIndexOf(".") + 1)}");
    setState(()=> downloading=false);

  }
}
