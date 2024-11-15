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
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';

import '../../../domain/entities/service.dart';
import '../../../domain/entities/transaction.dart';

class EnterLinkSheet extends ConsumerStatefulWidget {
  final Transaction transaction;
  final Service task;
  const EnterLinkSheet(
      {super.key, required this.task, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EnterLinkSheetState();
}

class _EnterLinkSheetState extends ConsumerState<EnterLinkSheet> {
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool forceAdd = false;
  String workLink = "";

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
              "Enter Link",
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
                label: "(e.g https://my-work.com)",
                inputType: TextInputType.url,
                onChanged: (value) => setState(() => forceAdd = false),
                validator: (value) {
                  if (value == null) {
                    return "* enter link";
                  }
                  if (value.trim().isEmpty) {
                    return "* enter link";
                  }
                  if (value.trim().endsWith(".")) {
                    return "* enter valid link";
                  }
                  if (value.trim().endsWith("?")) {
                    return "* enter valid link";
                  }
                  if (!value.trim().startsWith("http://")) {
                    if (!value.trim().startsWith("https://")) {
                      return "* should start with 'http://' or 'https://'";
                    }
                  }
                  if (!isValidUrl(value.trim()) || forceAdd) {
                    return "* enter valid link";
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    workLink = value!.trim();
                  });
                },
                prefixIcon: Icon(
                  Icons.abc_rounded,
                  color: ColorManager.themeColor,
                  size: IconSizeManager.medium,
                )),
            mediumSpacer(),
            CustomButton(
              onPressed: sendLink,
              label: forceAdd ? "Enforce Link" : "Send",
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

  bool isValidUrl(String url) {
    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
      multiLine: false,
    );

    return urlRegex.hasMatch(url);
  }

  Future<void> sendLink() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));

    final valid = formKey.currentState!.validate();
    if (!valid) {
      setState(() => forceAdd = true);
    }
    if (valid) {
      formKey.currentState!.save();

      final response = await TransactionRepo.uploadProofOfWork(
          transaction: widget.transaction,
          taskId: widget.task.id,
          link: true,
          fileOrLink: workLink);

      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      if (!response.error) {
        SnackbarManager.showBasicSnackbar(
            context: context, message: "Sent Link", mode: ContentType.success);
      } else {
        SnackbarManager.showBasicSnackbar(
            context: context,
            message: "Failed to send link",
            mode: ContentType.failure);
        debugPrint(response.body);
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }
}
