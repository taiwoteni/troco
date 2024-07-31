import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';
import 'package:troco/features/groups/presentation/group_tab/providers/groups-provider.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/routes-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/button/presentation/widget/button.dart';
import '../../../auth/domain/entities/client.dart';
import '../../../groups/domain/entities/group.dart';

class ClientWidget extends ConsumerStatefulWidget {
  final Client client;
  final Group group;
  final bool inviteMode;
  const ClientWidget(
      {super.key,
      required this.client,
      required this.inviteMode,
      required this.group});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClientWidgetState();
}

class _ClientWidgetState extends ConsumerState<ClientWidget> {
  final buttonKey = UniqueKey();
  late Client client;
  bool inviteMode = false;
  String text = "add";

  @override
  void initState() {
    client = widget.client;
    inviteMode = widget.inviteMode;
    text = widget.group.members.contains(client.userId) ? "Added" : "Add";
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      if (text == "Added" || widget.group.members.length >= 3) {
        ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.only(
        left: SizeManager.medium,
        right: SizeManager.medium,
        top: SizeManager.small,
        bottom: SizeManager.small,
      ),
      horizontalTitleGap: SizeManager.medium * 0.8,
      leading: GestureDetector(
        onTap: () => Navigator.pushNamed(context, Routes.viewProfileRoute,
            arguments: client),
        child: profileIcon(),
      ),
      title: Text(
        client.fullName,
        style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: ColorManager.primary,
            fontFamily: 'quicksand',
            fontSize: FontSizeManager.medium * 0.95,
            fontWeight: FontWeightManager.semibold),
      ),
      subtitle: Text(" ${client.accountCategory.name} User",
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Quicksand',
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.medium)),
      trailing: inviteMode
          ? SizedBox(
              width: IconSizeManager.large * 1.7,
              height: IconSizeManager.regular * 2,
              child: CustomButton.small(
                  onPressed: addMemberToGroup,
                  buttonKey: buttonKey,
                  usesProvider: true,
                  label: text),
            )
          : null,
    );
  }

  Widget profileIcon() {
    return SizedBox.square(
      dimension: IconSizeManager.large,
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

  Future<void> addMemberToGroup() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    log(widget.group.groupId);
    final response = await GroupRepo.addMember(
        groupId: widget.group.groupId, userId: client.userId);
    log(response.body);
    if (response.error) {
      log(response.body);
      SnackbarManager.showBasicSnackbar(
          context: context, message: response.messageBody!["message"]);
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    } else {
      ref.watch(groupsStreamProvider);
      setState(() {
        text = "added";
      });
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    }
  }
}
