import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/basecomponents/button/presentation/provider/button-provider.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/button/presentation/widget/button.dart';
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
      if (text == "Added") {
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
      leading: client.profile != "null"
          ? ProfileIcon(
              size: IconSizeManager.large,
              profile: DecorationImage(
                  image: NetworkImage(client.profile), fit: BoxFit.cover))
          : Container(
              width: IconSizeManager.large,
              height: IconSizeManager.large,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 223, 218, 218)),
              child: const Icon(
                CupertinoIcons.person_solid,
                color: Colors.white,
                size: (IconSizeManager.medium) * 0.65,
              ),
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
      subtitle: Text(" ${client.accountCategory.name.toLowerCase()}",
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Quicksand',
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.medium)),
      trailing: inviteMode
          ? SizedBox(
              width: IconSizeManager.large * 1.7,
              child: CustomButton.small(
                  onPressed: addMemberToGroup,
                  buttonKey: buttonKey,
                  usesProvider: true,
                  label: text),
            )
          : null,
    );
  }

  Future<void> addMemberToGroup() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    log(widget.group.groupId);
    final response = await GroupRepo.addMember(
        groupId: widget.group.groupId, userId: client.userId);
    if (response.error) {
      log(response.body);
      SnackbarManager.showBasicSnackbar(
          context: context, message: response.messageBody!["message"]);
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    } else {
      setState(() {
        text = "added";
      });
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    }
  }
}
