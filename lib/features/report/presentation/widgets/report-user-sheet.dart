// ignore_for_file: use_build_context_synchronously

import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/texts/inputs/dropdown-input-field.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/settings/domain/repository/settings-repository.dart';
import 'package:troco/features/transactions/utils/write-up-document-type.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../auth/domain/entities/client.dart';

class ReportUserSheet extends ConsumerStatefulWidget {
  final Client client;
  const ReportUserSheet({super.key, required this.client});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReportUserSheetState();

  static Future<bool?> bottomSheet(
      {required BuildContext context, required Client client}) async {
    return await showModalBottomSheet<bool?>(
        isScrollControlled: true,
        useSafeArea: false,
        backgroundColor: ColorManager.background,
        context: context,
        builder: (context) {
          return ReportUserSheet(
            client: client,
          );
        });
  }
}

class _ReportUserSheetState extends ConsumerState<ReportUserSheet> {
  String? selectedReason;

  final reasons = [
    "Inappropriate Name",
    "Inappropriate profile photo",
    "Poor Service/Attitude",
    "Other"
  ];

  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String? description;

  late Client client;
  @override
  void initState() {
    client = widget.client;
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
        decoration: BoxDecoration(
            color: ColorManager.background,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(SizeManager.extralarge))),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                extraLargeSpacer(),
                const DragHandle(),
                largeSpacer(),
                title(),
                mediumSpacer(),
                Divider(
                  thickness: 1,
                  color: ColorManager.secondary.withOpacity(0.08),
                ),
                mediumSpacer(),
                reportReason(),
                mediumSpacer(),
                regularSpacer(),
                reportDescription(),
                extraLargeSpacer(),
                button(),
                extraLargeSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            "Report ${client.firstName}",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "Lato",
                fontSize: FontSizeManager.large * 0.9),
          ),
        ),
        Positioned(
          width: SizeManager.extralarge * 1.1,
          height: SizeManager.extralarge * 1.1,
          right: SizeManager.regular,
          child: IconButton(
              onPressed: () => loading ? null : Navigator.pop(context),
              style: ButtonStyle(
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorManager.accentColor.withOpacity(0.2))),
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.accentColor,
                size: IconSizeManager.small,
              )),
        )
      ],
    );
  }

  Widget reportDescription() {
    return Column(
      children: [
        InfoText(
          text: "Description",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          inputType: TextInputType.text,
          label: 'Can you tell us what he/she did wrong?',
          lines: 5,
          validator: (value) {
            // if (value == null) {
            //   return "* enter write-up";
            // }
            // if (value.trim().isEmpty) {
            //   return "* enter write-up";
            // }
            return null;
          },
          onSaved: (value) {
            setState(() => description = value?.toString() ?? "");
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget reportReason() {
    return Column(
      children: [
        InfoText(
          text: "Reason",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        DropdownInputFormField(
          items: reasons,
          value: selectedReason ?? "",
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedReason = value;
              });
            }
          },
          hint: "Reason for reporting ${client.firstName}",
          onValidate: (value) {
            if (value == null) {
              return "* select reason";
            }
            if (value.trim().isEmpty) {
              return "* select reason";
            }
            return null;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget button() {
    return CustomButton(
      label: "Submit",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        setState(() {
          loading = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          final response = await AuthenticationRepo.reportUser(
              reportedUserId: client.userId,
              reason: "$selectedReason: ${description ?? ""}".trim());
          if (response.error) {
            SnackbarManager.showErrorSnackbar(
                context: context,
                message: "Error occurred when reporting user");
            context.pop(result: false);
          }
          SnackbarManager.showBasicSnackbar(
              context: context, message: "Reported user successfully");
          context.pop(result: true);
        } else {
          setState(() {
            loading = false;
          });
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }
}
