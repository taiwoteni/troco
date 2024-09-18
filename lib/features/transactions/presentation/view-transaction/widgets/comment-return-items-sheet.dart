// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

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

class CommentReturnItemsSheet extends ConsumerStatefulWidget {
  const CommentReturnItemsSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommentReturnItemsSheetState();
}

class _CommentReturnItemsSheetState
    extends ConsumerState<CommentReturnItemsSheet> {
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: "");
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
              "Comment",
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
                label: "What don't you like",
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
                onSaved: (value) {},
                prefixIcon: Icon(
                  Icons.abc_rounded,
                  color: ColorManager.themeColor,
                  size: IconSizeManager.medium,
                )),
            mediumSpacer(),
            CustomButton(
              onPressed: comment,
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

  Future<void> comment() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      if (mounted) {
        Navigator.pop(context, controller.text);
      }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
