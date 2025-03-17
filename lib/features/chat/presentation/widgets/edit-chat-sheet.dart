// ignore_for_file: use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
import 'package:troco/features/chat/domain/repositories/chat-repository.dart';
import '../../../groups/domain/entities/group.dart';
import '../../domain/entities/chat.dart';

class EditChatSheet extends ConsumerStatefulWidget {
  final Chat chat;
  final Group group;
  const EditChatSheet({super.key, required this.chat, required this.group});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<EditChatSheet> {
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  late Chat chat;
  late Group group;
  late TextEditingController controller;
  String editMessage = "";

  @override
  void initState() {
    chat = widget.chat;
    group = widget.group;
    controller = TextEditingController(text: chat.message);
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
              "Edit Chat",
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
                label: "Edit Message",
                controller: controller,
                inputType: TextInputType.name,
                validator: (value) {
                  if (value == null) {
                    return "* Enter new message";
                  }
                  if (value.trim().isEmpty) {
                    return "* Enter new message";
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    editMessage = value!;
                  });
                },
                prefixIcon: Icon(
                  Icons.abc_rounded,
                  color: ColorManager.themeColor,
                  size: IconSizeManager.medium,
                )),
            mediumSpacer(),
            CustomButton(
              onPressed: editOldMessage,
              label: "Edit Message",
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

  Future<void> editOldMessage() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final response = await ChatRepo.editChat(
          oldChat: chat, groupId: group.groupId, newMessage: editMessage);

      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      if (!response.error) {
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Edited Message Successfully",
            mode: ContentType.success);
      } else {
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Unable to edit message",
            mode: ContentType.failure);
        debugPrint(response.body);
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
