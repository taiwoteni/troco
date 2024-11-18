import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../auth/domain/entities/client.dart';

class FriendWidget extends ConsumerStatefulWidget {
  final Client client;
  final bool enabled;
  final bool applyHorizontalPadding, pushReplace;
  const FriendWidget(
      {super.key,
      required this.client,
      this.enabled = true,
      this.applyHorizontalPadding = true,
      this.pushReplace = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClientWidgetState();
}

class _ClientWidgetState extends ConsumerState<FriendWidget> {
  late Client client;

  @override
  void initState() {
    client = widget.client;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String lastSeenText = "yesterday";
    final now = DateTime.now();
    final lastSeen = client.lastSeen;
    if (now.year == lastSeen.year) {
      if (now.month == lastSeen.month) {
        if (now.day == lastSeen.day) {
          lastSeenText = "today at ${DateFormat('hh:mm a').format(lastSeen)}";
        } else if (now.day == lastSeen.day - 1) {
          lastSeenText = "yesterday";
        }
      } else {
        lastSeenText = DateFormat('EEE, MMM d').format(lastSeen);
      }
    } else {
      lastSeenText = DateFormat('EEE, MMM d yyyy').format(lastSeen);
    }

    final applyHorizontalPadding = widget.applyHorizontalPadding;
    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      onTap: () {
        if (!widget.enabled) {
          return;
        }
        if (widget.pushReplace) {
          Navigator.pushReplacementNamed(context, Routes.viewProfileRoute,
              arguments: client);
          return;
        }
        Navigator.pushNamed(context, Routes.viewProfileRoute,
            arguments: client);
      },
      contentPadding: EdgeInsets.only(
        left: applyHorizontalPadding ? SizeManager.medium : 0,
        right: applyHorizontalPadding ? SizeManager.medium : 0,
        top: SizeManager.small,
        bottom: SizeManager.small,
      ),
      horizontalTitleGap: SizeManager.medium * 0.8,
      leading: profileIcon(),
      title: Row(
        children: [
          Text(
            client.phoneNumber == ClientProvider.readOnlyClient!.phoneNumber
                ? "You"
                : client.fullName,
          ),
          if (client.verified) ...[
            smallSpacer(),
            SvgIcon(
              svgRes: AssetManager.svgFile(name: "verification"),
              color: ColorManager.accentColor,
              size: const Size.square(IconSizeManager.small),
            )
          ]
        ],
      ),
      titleTextStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: ColorManager.primary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium * 1.1,
          fontWeight: FontWeightManager.semibold),
      subtitle: Text(client.online ? "Online" : "Last seen $lastSeenText"),
      subtitleTextStyle: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'Quicksand',
          fontSize: FontSizeManager.regular * 0.9,
          fontWeight: FontWeightManager.medium),
    );
  }

  Widget profileIcon() {
    return Container(
      width: 53,
      height: 53,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        children: [
          ProfileIcon(
            size: double.maxFinite,
            url: client.profile,
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: SizeManager.medium - 2,
                height: SizeManager.medium - 2,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: client.online
                        ? ColorManager.accentColor
                        : Colors.redAccent,
                    border: Border.all(
                        color: ColorManager.background,
                        width: SizeManager.small * 0.5,
                        strokeAlign: BorderSide.strokeAlignOutside)),
              ))
        ],
      ),
    );
  }
}
