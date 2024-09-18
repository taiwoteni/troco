import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../app/color-manager.dart';
import '../animations/lottie.dart';

/// If [badge] is given, [showOnline] and [online] will be overriden
class ProfileIcon extends ConsumerStatefulWidget {
  final String? url;
  final double? size;

  const ProfileIcon({super.key, required this.url, this.size});

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
    return Container(
      width: widget.size ?? IconSizeManager.medium,
      height: widget.size ?? IconSizeManager.medium,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: widget.url == null
          ? ClipOval(
              child: Image.asset(
                AssetManager.imageFile(name: "profile_img"),
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            )
          : ClipOval(
              child: CachedNetworkImage(
                width: double.maxFinite,
                imageUrl: widget.url!,
                fit: BoxFit.cover,
                height: double.maxFinite,
                fadeInCurve: Curves.ease,
                fadeOutCurve: Curves.ease,
                placeholder: (context, url) {
                  return Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    color: ColorManager.lottieLoading,
                    child: LottieWidget(
                        lottieRes:
                            AssetManager.lottieFile(name: "loading-image"),
                        size: Size.square(
                            widget.size ?? IconSizeManager.medium * 0.8)),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    color: ColorManager.lottieLoading,
                    child: LottieWidget(
                        lottieRes:
                            AssetManager.lottieFile(name: "loading-image"),
                        size: Size.square(
                            widget.size ?? IconSizeManager.medium * 0.8)),
                  );
                },
              ),
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
    return Container(
      width: widget.size ?? IconSizeManager.medium,
      height: widget.size ?? IconSizeManager.medium,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ref.watch(ClientProvider.userProvider)!.profile != "null" &&
              !widget.showOnlyDefault
          ? ProfileIcon(
              size: double.maxFinite,
              url: ref.watch(clientProvider)!.profile,
            )
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

class CustomerCareProfileIcon extends ConsumerStatefulWidget {
  final double? size;
  const CustomerCareProfileIcon({super.key, this.size});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomerCareProfileIconState();
}

class _CustomerCareProfileIconState
    extends ConsumerState<CustomerCareProfileIcon> {
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
            svgRes: AssetManager.svgFile(name: 'customer-service'),
            color: Colors.white,
            size: Size.square(widget.size != null
                ? widget.size! >= 50
                    ? widget.size! * 0.42
                    : widget.size! * 0.5
                : (IconSizeManager.medium) * 0.65),
          ),
        ));
  }
}
