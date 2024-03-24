import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/size-manager.dart';

class ProfileIcon extends ConsumerStatefulWidget {
  final DecorationImage profile;
  final bool showOnline;
  final bool online;
  final double? size;
  const ProfileIcon(
      {super.key,
      required this.profile,
      this.showOnline = false,
      this.online = false,
      this.size});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileIconState();
}

class _ProfileIconState extends ConsumerState<ProfileIcon> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size ?? IconSizeManager.medium,
      height: widget.size ?? IconSizeManager.medium,
      child: Stack(
        children: [
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration:
                BoxDecoration(shape: BoxShape.circle, image: widget.profile),
          ),
        ],
      ),
    );
  }
}
