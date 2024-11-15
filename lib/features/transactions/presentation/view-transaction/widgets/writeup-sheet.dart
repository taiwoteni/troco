// ignore_for_file: use_build_context_synchronously

import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/texts/inputs/dropdown-input-field.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
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

class WriteUpSheet extends ConsumerStatefulWidget {
  const WriteUpSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WriteUpSheetState();

  static Future<File?> bottomSheet({required BuildContext context}) async {
    return await showModalBottomSheet<File?>(
        isScrollControlled: true,
        useSafeArea: false,
        backgroundColor: ColorManager.background,
        context: context,
        builder: (context) {
          return const WriteUpSheet();
        });
  }
}

class _WriteUpSheetState extends ConsumerState<WriteUpSheet> {
  WriteUpDocumentType? selectedWriteUpDocumentType;

  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String description = "";

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
                writeUpType(),
                mediumSpacer(),
                regularSpacer(),
                writeUp(),
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
            "WriteUp Document",
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

  Widget writeUp() {
    return Column(
      children: [
        InfoText(
          text: "Write-Up (Information)",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        InputFormField(
          inputType: TextInputType.text,
          label:
              'i.e the information/credentials you want to convey to the buyer',
          lines: 5,
          validator: (value) {
            if (value == null) {
              return "* enter write-up";
            }
            if (value.trim().isEmpty) {
              return "* enter write-up";
            }
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

  Widget writeUpType() {
    return Column(
      children: [
        InfoText(
          text: "Write-Up Type",
          color: ColorManager.primary,
          fontWeight: FontWeightManager.medium,
        ),
        regularSpacer(),
        DropdownInputFormField(
          items: WriteUpDocumentType.values.map((e) => e.name).toList(),
          value: selectedWriteUpDocumentType == null
              ? ""
              : selectedWriteUpDocumentType!.name,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedWriteUpDocumentType =
                    WriteUpDocumentTypeConverter.fromString(
                        documentType: value);
              });
            }
          },
          hint: 'e.g "Credentials"',
          onValidate: (value) {
            if (value == null) {
              return "* select write-up type";
            }
            if (value.trim().isEmpty) {
              return "* select write-up type";
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
      label: "Generate",
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

          final directory = await getApplicationCacheDirectory();

          final fileName =
              "${directory.path}${Path.separator}${selectedWriteUpDocumentType!.name}-Doc.txt";

          final file = await File(fileName).writeAsString(description);
          debugPrint(Path.extension(file.path));

          context.pop(result: file);
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
