import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

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
  void initState() {
    super.initState();
  }

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

class UserProfileIcon extends ConsumerStatefulWidget {
  final bool showOnline;
  final bool online;
  final bool showOnlyDefault;
  final double? size;
  const UserProfileIcon(
      {super.key,
      this.showOnline = false,
      this.showOnlyDefault = false,
      this.online = false,
      this.size});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserProfileIconState();
}

class _UserProfileIconState extends ConsumerState<UserProfileIcon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size ?? IconSizeManager.medium,
      height: widget.size ?? IconSizeManager.medium,
      child: ref.watch(ClientProvider.userProvider)!.profile != "null" &&
              !widget.showOnlyDefault
          ? ProfileIcon(
              size: double.maxFinite,
              profile: DecorationImage(
                  image: NetworkImage(
                      ref.read(ClientProvider.userProvider)!.profile),
                  fit: BoxFit.cover))
          : Container(
              width: double.maxFinite,
              height: double.maxFinite,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 223, 218, 218)),
              child: Icon(
                CupertinoIcons.person_solid,
                color: Colors.white,
                size: widget.size != null
                    ? widget.size! >= 50
                        ? widget.size! * 0.5
                        : widget.size! * 0.65
                    : (IconSizeManager.medium) * 0.65,
              ),
            ),
    );
  }
}

class GroupProfileIcon extends ConsumerStatefulWidget {
  final double? size;
  const GroupProfileIcon({super.key, this.size});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupProfileIconState();
}

class _GroupProfileIconState extends ConsumerState<GroupProfileIcon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.size ?? IconSizeManager.medium,
        height: widget.size ?? IconSizeManager.medium,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 223, 218, 218)),
          child: SvgIcon(
            svgRes: AssetManager.svgFile(name: 'group'),
            color: Colors.white,
            size: Size.square(widget.size != null
                ? widget.size! >= 50
                    ? widget.size! * 0.47
                    : widget.size! * 0.55
                : (IconSizeManager.medium) * 0.65),
          ),
        ));
  }
}
