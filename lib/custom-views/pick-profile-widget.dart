// ignore_for_file: sized_box_for_whitespace
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/custom-views/svg.dart';

import '../app/file-manager.dart';

class PickProfileIcon extends StatefulWidget {
  final DecorationImage? previousImage;
  final void Function(String? path)? onPicked;
  final double size;
  const PickProfileIcon(
      {super.key, required this.size, this.previousImage, this.onPicked});

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
    return Container(
      width: widget.size,
      height: widget.size,
      child: InkWell(
        onTap: pickProfile,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: profileImage != null ? null : ColorManager.accentColor,
            shape: BoxShape.circle,
            image: profileImage,
          ),
          child:  SvgIcon(
            svgRes: AssetManager.svgFile(name: 'profile-add'),
            size: Size.square(widget.size * 0.5),
            color: Colors.white,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  Future<void> pickProfile()async{
    final file = await FileManager.pickImage();
    if(file != null){
      setState(() {
        profilePath = file.path;
        profileImage = DecorationImage(
          fit: BoxFit.cover,
          image: FileImage(File(file.path))
        );

      });
    }

  }
}
