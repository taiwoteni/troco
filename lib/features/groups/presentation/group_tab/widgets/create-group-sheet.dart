import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/button/presentation/widget/button.dart';
import 'package:troco/core/basecomponents/others/drag-handle.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/core/basecomponents/texts/inputs/text-form-field.dart';
import 'package:troco/features/groups/data/models/group-model.dart';
import 'package:troco/core/basecomponents/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/groups/presentation/group_tab/providers/groups-provider.dart';

import '../../../../../core/basecomponents/texts/outputs/info-text.dart';

class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final buttonKey = UniqueKey();
  bool groupNameError = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      // ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(
          left: SizeManager.medium,
          right: SizeManager.medium,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.large))),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            extraLargeSpacer(),
            const DragHandle(),
            largeSpacer(),
            Text(
              "Create Group",
              style: TextStyle(
                  color: ColorManager.primary,
                  fontWeight: FontWeightManager.bold,
                  fontFamily: "Lato",
                  fontSize: FontSizeManager.large * 0.9),
            ),
            mediumSpacer(),
            Divider(
              thickness: 1,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
            mediumSpacer(),
            InputFormField(
                label: "Group name",
                controller: groupNameController,
                inputType: TextInputType.name,
                validator: (value) {
                  if (value == null) {
                    setState(() => groupNameError = true);
                    return null;
                  }
                  if (value.trim().length < 8) {
                    setState(() => groupNameError = true);
                    return null;
                  } else {
                    setState(() => groupNameError = false);
                  }
                },
                prefixIcon: Icon(
                  Icons.abc_rounded,
                  color: ColorManager.themeColor,
                  size: IconSizeManager.medium,
                )),
            regularSpacer(),
            InfoText(
              text: " * More than 8 digits in length",
              color: groupNameError ? Colors.red : ColorManager.secondary,
            ),
            smallSpacer(),
            InfoText(
              text: " * should be a unique name",
              color: groupNameError ? Colors.red : ColorManager.secondary,
            ),
            largeSpacer(),
            CustomButton(
              onPressed: createGroup,
              label: "Create",
              usesProvider: true,
              buttonKey: buttonKey,
              margin: const EdgeInsets.symmetric(vertical: SizeManager.regular),
            ),
            largeSpacer(),
          ],
        ),
      ),
    );
  }

  Future<void> createGroup() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    if (formKey.currentState!.validate() && !groupNameError) {
      log(ref.read(ClientProvider.userProvider)!.userId);
      try {
        GroupModel groupModel = GroupModel.fromJson(
            json: {"group name": groupNameController.text.trim()});
        final abby = await ref.watch(groupsProvider.future);
        abby.add(groupModel);
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      } on Exception catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Process Exited")));
        log(e.toString());
      }

      // TODO: UnComment once The API works.
      // final result = await ApiInterface.createGroup(
      //     groupName: groupNameController.text.trim(),
      //     userId: ref.read(ClientProvider.userProvider)!.userId);
      // log(result.body);
      // ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

      // if (result.error) {
      //   log(result.messageBody!.toString());
      // }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
