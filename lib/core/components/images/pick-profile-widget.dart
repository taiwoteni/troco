// ignore_for_file: sized_box_for_whitespace
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:croppy/croppy.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/badge-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';

import '../../app/file-manager.dart';

class PickProfileIcon extends StatefulWidget {
  final DecorationImage? previousImage;
  final void Function(String? path) onPicked;
  final double size;
  final bool? canDelete;
  const PickProfileIcon(
      {super.key,
      required this.size,
      this.previousImage,
      this.canDelete,
      required this.onPicked});

  @override
  State<PickProfileIcon> createState() => _PickProfileIconState();
}

class _PickProfileIconState extends State<PickProfileIcon> {
  DecorationImage? profileImage;
  String? profilePath;

  @override
  void initState() {
    profileImage = widget.previousImage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "profile-photo",
      child: Container(
        width: widget.size,
        height: widget.size,
        child: GestureDetector(
          onTap: pickProfile,
          child: Stack(
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: profileImage != null ? null : ColorManager.accentColor,
                  shape: BoxShape.circle,
                  image: profileImage,
                ),
                child: profileImage != null
                    ? null
                    : SvgIcon(
                        svgRes: AssetManager.svgFile(name: 'profile-add'),
                        size: Size.square(widget.size * 0.5),
                        color: Colors.white,
                        fit: BoxFit.cover,
                      ),
              ),
              if (profileImage != null)
                Positioned(
                    bottom: 1,
                    right: 4,
                    child: BadgeIcon(
                      iconType: BadgeIconType.icon,
                      iconData: Icons.edit,
                    ))
            ],
          ),
        ),
      ),
    );
  }

  List<DialogMenuItem> menuItems() {
    return [
      DialogMenuItem(
        icon: Icons.replay_rounded,
        color: ColorManager.accentColor,
        label: "Rechoose profile photo",
        onPressed: () {
          Navigator.pop(context);
          deleteProfile(trueDelete: false);
          pickProfile(truePick: false);
        },
      ),
      DialogMenuItem(
        icon: Icons.crop_rounded,
        color: Colors.orange,
        label: "Crop profile photo",
        onPressed: () {
          cropProfile();
          Navigator.pop(context);
        },
      ),
      if(widget.canDelete ?? true)
      DialogMenuItem(
        icon: Icons.delete_rounded,
        color: Colors.red,
        label: "Remove profile photo",
        onPressed: () {
          deleteProfile(trueDelete: true);
          Navigator.pop(context);
        },
      ),
    ];
  }

  void deleteProfile({required bool trueDelete}) {
    if (trueDelete) {
      setState(() {
        profileImage = null;
        profilePath = null;
      });
      widget.onPicked(null);
    }
  }

  Future<void> profileMenu() async {
    showModalBottomSheet(
      enableDrag: true,
      backgroundColor: ColorManager.background,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(SizeManager.large))),
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: SizeManager.large),
            decoration: BoxDecoration(
                color: ColorManager.background,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(SizeManager.large))),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                      color: ColorManager.secondary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(SizeManager.large)),
                ),
                largeSpacer(),
                Text(
                  "Profile Photo",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.bold,
                      fontSize: FontSizeManager.large),
                ),
                largeSpacer(),
                ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return menuItems()[index];
                    },
                    separatorBuilder: (context, index) => Divider(
                          color: ColorManager.secondary.withOpacity(0.08),
                        ),
                    itemCount: menuItems().length),
                largeSpacer()
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickProfile({bool truePick = true}) async {
    if (profileImage != null && truePick) {
      profileMenu();
      return;
    }
    final file = await FileManager.pickImage();
    if (file != null) {
      setState(() {
        profilePath = file.path;
        log(profilePath!);
        profileImage = DecorationImage(
            fit: BoxFit.cover, image: FileImage(File(file.path)));
      });
      widget.onPicked(profilePath);
    }
  }

  Future<void> cropProfile() async {
    final croppedProfile = await showCupertinoImageCropper(context,
        heroTag: "profile-photo", imageProvider: profileImage!.image);

    // final croppedProfile = await CropScreen.showCustomCropper(
    //   context,
    //   FileImage(File(profilePath!)),
    //   heroTag: "profile-photo",
    // );

    if (croppedProfile != null) {
      final basename = Path.dirname(profilePath!);
      final bytes = await convertImageToBytes(image: croppedProfile.uiImage);
      String path = "$basename${Path.separator}troco-profile.jpg";
      if (bytes != null) {
        final imageFile = await convertBytesToFile(bytes: bytes, path: path);
        setState(() {
          profileImage =
              DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover);
          profilePath = imageFile.path;
        });
        widget.onPicked(profilePath);
      }
    }
  }
}

Future<Uint8List?> convertImageToBytes({required ui.Image image}) async {
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<File> convertBytesToFile(
    {required final Uint8List bytes, required final String path}) async {
  File file = File(path);
  await file.writeAsBytes(bytes);
  return file;
}

class DialogMenuItem extends StatelessWidget {
  const DialogMenuItem(
      {super.key,
      required this.icon,
      required this.color,
      required this.label,
      this.onPressed});
  final Color color;
  final IconData icon;
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.small),
      leading: Container(
        width: IconSizeManager.large * 0.95,
        height: IconSizeManager.large * 0.95,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManager.regular),
            color: color.withOpacity(0.1)),
        child: Icon(
          icon,
          size: IconSizeManager.regular,
          color: color,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
            fontFamily: 'Lato',
            color: ColorManager.primary,
            fontSize: FontSizeManager.medium,
            fontWeight: FontWeightManager.medium),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: ColorManager.secondary,
        size: IconSizeManager.regular,
      ),
    );
  }
}
