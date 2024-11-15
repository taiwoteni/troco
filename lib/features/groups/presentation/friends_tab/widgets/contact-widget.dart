import 'dart:async';
import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/auth/utils/phone-number-converter.dart';
import 'package:troco/features/wallet/domain/repository/wallet-repository.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/profile-icon.dart';
import '../../../../auth/domain/entities/client.dart';
import '../../../domain/repositories/friend-repository.dart';

class ContactWidget extends ConsumerStatefulWidget {
  final Contact contact;
  const ContactWidget({super.key, required this.contact});

  @override
  ConsumerState<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends ConsumerState<ContactWidget> {
  late Contact contact;
  late Client client;
  bool trocoUser = false;
  bool isFriend = false;
  final buttonKey = UniqueKey();

  @override
  void initState() {
    contact = widget.contact;

    final phoneNumbers = (contact.phones ?? [])
        .map(
          (e) => PhoneNumberConverter.convertToFull(
              (e.value?.replaceAll(" ", "") ?? "00000000000")),
        )
        .toList();
    trocoUser = AppStorage.getAllUsersPhone().any((element) => phoneNumbers
        .contains(PhoneNumberConverter.convertToFull(element.phoneNumber)));
    isFriend = trocoUser &&
        AppStorage.getFriends().any((e) => phoneNumbers
            .contains(PhoneNumberConverter.convertToFull(e.phoneNumber)));
    if (trocoUser) {
      client = AppStorage.getAllUsersPhone().firstWhere((element) =>
          phoneNumbers.contains(
              PhoneNumberConverter.convertToFull(element.phoneNumber)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () {
        if (trocoUser) {
          context.pushNamed(
              routeName: Routes.viewProfileRoute, arguments: client);
        }
      },
      tileColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      leading: contactImage(),
      horizontalTitleGap: SizeManager.medium * 0.8,
      title: Row(
        children: [
          Text(
            // trocoUser ? client.fullName :
            (contact.displayName ?? "Unknown"),
            overflow: TextOverflow.ellipsis,
          ),
          if (trocoUser && client.verified) ...[
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
      subtitle: (contact.phones ?? []).isNotEmpty
          ? Text(PhoneNumberConverter.convertToFull(
              contact.phones!.first.value!.replaceAll(" ", "")))
          : null,
      trailing: button(),
      subtitleTextStyle: TextStyle(
          overflow: TextOverflow.ellipsis,
          color: ColorManager.secondary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.regular * 1.1,
          fontWeight: FontWeightManager.medium),
    );
  }

  Widget contactImage() {
    if (trocoUser) {
      return SizedBox.square(
        dimension: 53,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ProfileIcon(
              size: 53,
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
    return FutureBuilder(
      future: ContactsService.getAvatar(contact),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover, image: MemoryImage(contact.avatar!))),
          );
        }
        return Transform.scale(
            scale: 1.25, child: const ProfileIcon(size: 53, url: null));
      },
    );
  }

  Future<void> addFriend() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final response = await FriendRepository.addFriend(client: client);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    SnackbarManager.showBasicSnackbar(
        context: context,
        mode: response.error ? ContentType.failure : null,
        message: response.error
            ? "Unable to add Friend"
            : "Added friend successfully");
    if (!response.error) {
      setState(() => isFriend = true);
    }
    debugPrint(response.body);
  }

  Future<void> removeFriend() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final response = await FriendRepository.removeFriend(client: client);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    SnackbarManager.showBasicSnackbar(
        context: context,
        mode: response.error ? ContentType.failure : ContentType.help,
        message: response.error
            ? "Unable to remove Friend"
            : "Removed friend successfully");
    if (!response.error) {
      setState(() => isFriend = false);
    }

    debugPrint(response.body);
  }

  Future<void> refer() async {
    try {
      ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
      await Future.delayed(const Duration(seconds: 2));
      final response = await WalletRepository.referPhoneNumber(
          phoneNumber: PhoneNumberConverter.convertToFull(
              contact.phones!.first.value!.replaceAll(" ", "")));
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: response.error ? ContentType.failure : null,
          message: response.error
              ? "Unable to refer contact"
              : "Referred contact successfully");
      debugPrint(response.body);
    } catch (e) {
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Unable to refer use");
    }
  }

  Widget button() {
    return SizedBox(
      width: SizeManager.large * 3.35,
      height: SizeManager.large * 1.73,
      child: CustomButton.small(
          label: trocoUser ? (isFriend ? "Remove" : "Add") : "Refer",
          buttonKey: buttonKey,
          usesProvider: true,
          color: trocoUser
              ? (isFriend ? Colors.redAccent : ColorManager.accentColor)
                  .withOpacity(0.27)
              : null,
          textColor: trocoUser
              ? (isFriend ? Colors.red : ColorManager.themeColor)
              : null,
          onPressed: trocoUser ? (isFriend ? removeFriend : addFriend) : refer),
    );
    // return Container(
    //   padding: const EdgeInsets.symmetric(
    //       horizontal: SizeManager.medium, vertical: SizeManager.regular),
    //   decoration: BoxDecoration(
    //       color: ColorManager.accentColor,
    //       borderRadius: BorderRadius.circular(SizeManager.regular)),
    //   child: Text(
    //     trocoUser ? "Add" : "Refer",
    //     textAlign: TextAlign.center,
    //     style: const TextStyle(
    //         color: Colors.white,
    //         fontFamily: 'lato',
    //         fontSize: FontSizeManager.regular * 0.9,
    //         fontWeight: FontWeightManager.semibold),
    //   ),
    // );
  }
}
