import 'dart:async';
import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/utils/phone-number-converter.dart';
import 'package:troco/features/block/domain/repository/block-repository.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/profile-icon.dart';
import '../../../auth/domain/entities/client.dart';

class BlockedUserWidget extends ConsumerStatefulWidget {
  final Client client;
  const BlockedUserWidget({super.key, required this.client});

  @override
  ConsumerState<BlockedUserWidget> createState() => _BlockedUserWidgetState();
}

class _BlockedUserWidgetState extends ConsumerState<BlockedUserWidget> {
  late Client client;
  final buttonKey = UniqueKey();

  @override
  void initState() {
    client = widget.client;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      leading: profileImage(),
      horizontalTitleGap: SizeManager.medium * 0.8,
      title: Row(
        children: [
          Text(
            client.fullName,
            overflow: TextOverflow.ellipsis,
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
      subtitle: Text("${client.accountCategory.name} User"),
      trailing: button(),
      subtitleTextStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: ColorManager.secondary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.regular * 1.1,
          fontWeight: FontWeightManager.medium),
    );
  }

  Widget profileImage() {
    return ProfileIcon(
      size: 53,
      url: client.profile,
    );
  }

  Future<void> unblock() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final response =
        await BlockRepository.unblockUser(userId: client.userId, reason: "");
    if (response.error) {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
    SnackbarManager.showBasicSnackbar(
        context: context,
        mode: response.error ? ContentType.failure : null,
        message: response.error
            ? "Unable to unblock friend"
            : "unblocked friend successfully");
    debugPrint(response.body);
  }

  Widget button() {
    return SizedBox(
        width: SizeManager.large * 3.35,
        height: SizeManager.large * 1.73,
        child: CustomButton.small(
          label: ButtonProvider.loadingValue(buttonKey: buttonKey, ref: ref)
              ? "Unblocking.."
              : "Unblock",
          buttonKey: buttonKey,
          disabled: ButtonProvider.loadingValue(buttonKey: buttonKey, ref: ref),
          usesProvider: true,
          color: ColorManager.accentColor.withOpacity(0.27),
          textColor: ColorManager.themeColor,
          onPressed: unblock,
        ));
  }
}
