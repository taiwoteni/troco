// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/drag-handle.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/texts/inputs/text-form-field.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';

import '../../../../../core/components/texts/outputs/info-text.dart';

class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final buttonKey = UniqueKey();
  final TextEditingController deliveryController =
      TextEditingController(text: "Delivery");
  final formKey = GlobalKey<FormState>();

  bool groupNameError = false;
  bool useDelivery = true;

  final Map<dynamic, dynamic> groupJson = {};

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
              "Create Collection",
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
                label: "Collection name",
                inputType: TextInputType.name,
                validator: (value) {
                  if (value == null) {
                    setState(() => groupNameError = true);
                    return null;
                  }
                  if (value.trim().length < 5) {
                    setState(() => groupNameError = true);
                    return null;
                  } else {
                    setState(() => groupNameError = false);
                  }
                  return null;
                },
                onSaved: (value) {
                  groupJson["groupName"] = value!;
                },
                prefixIcon: Icon(
                  Icons.abc_rounded,
                  color: ColorManager.themeColor,
                  size: IconSizeManager.medium,
                )),
            regularSpacer(),
            InfoText(
              text: " * At least 4 digits in length",
              color: groupNameError ? Colors.red : ColorManager.secondary,
            ),
            smallSpacer(),
            InfoText(
              text: " * should be a unique name",
              color: groupNameError ? Colors.red : ColorManager.secondary,
            ),
            mediumSpacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(right: SizeManager.regular),
                  child: InputFormField(
                      label: "delivery",
                      readOnly: true,
                      controller: deliveryController,
                      inputType: TextInputType.none,
                      onSaved: (value) {
                        groupJson["useDelivery"] = useDelivery;
                      },
                      prefixIcon: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: useDelivery,
                        tristate: false,
                        checkColor: Colors.white,
                        activeColor: ColorManager.accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                            side: BorderSide(
                                color: ColorManager.accentColor, width: 1.3)),
                        overlayColor: null,
                        fillColor: null,
                        onChanged: (value) {
                          setState(() => useDelivery = value!);
                        },
                      )),
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: SizeManager.regular),
                  child: InputFormField(
                    label: "days",
                    inputType: TextInputType.number,
                    prefixIcon: Icon(
                      CupertinoIcons.time_solid,
                      color: ColorManager.accentColor,
                      size: IconSizeManager.regular,
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "* enter duration";
                      }
                      if (value.trim().isEmpty) {
                        return "* enter duration";
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return "* valid number";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      groupJson["deadlineTime"] = DateTime.now()
                          .copyWith(
                              day:
                                  DateTime.now().day + int.parse(value!.trim()))
                          .toIso8601String();
                    },
                  ),
                ))
              ],
            ),
            mediumSpacer(),
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
      formKey.currentState!.save();
      log(ref.read(ClientProvider.userProvider)!.userId);
      final result = await GroupRepo.createGroup(
          groupName: groupJson["groupName"],
          deadlineTime: groupJson["deadlineTime"],
          useDelivery: groupJson["useDelivery"],
          userId: ref.read(ClientProvider.userProvider)!.userId);
      log(result.code.toString());
      log(result.body);
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      if (!result.error) {
        // final groups = AppStorage.getGroups();
        // final group = Group.fromJson(json: result.messageBody!["group"]);

        /// remove the last group. Inorder to surely, make sure that the
        /// groups returned from Cache and API listening service are not the same
        /// Hence, Causing a rebuild.
        // final json = await GroupRepo().getGroupsJson();
        // List jsonList = json["groups"];
        // log("List of groups checked immediately after commiting a new group : ${jsonList.map((e) => e["name"]).toList()}");
        // await AppStorage.saveGroups(groups: groups);

        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Created group successfully",
            mode: ContentType.success);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Unable to create group",
            mode: ContentType.failure);
        log(result.body);
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
