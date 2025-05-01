import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';

class ViewReceiptScreen extends ConsumerStatefulWidget {
  final Uint8List receiptBytes;
  const ViewReceiptScreen({super.key, required this.receiptBytes});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewReceiptScreenState();
}

class _ViewReceiptScreenState extends ConsumerState<ViewReceiptScreen> {
  final buttonKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ThemeManager.getSettingsUiOverlayStyle(),
      child: Scaffold(
        backgroundColor: ColorManager.tertiary,
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: Column(
            spacing: SizeManager.large,
            children: [
              Gap(MediaQuery.of(context).viewPadding.top),
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Text(
                  "Go back",
                  style: TextStyle(
                      color: ColorManager.secondary,
                      fontFamily: 'lato',
                      fontSize: FontSizeManager.medium,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorManager.secondary,
                      fontWeight: FontWeightManager.medium),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(SizeManager.large),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    width: double.maxFinite * .8,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: MemoryImage(widget.receiptBytes),
                            alignment: Alignment.topCenter,
                            fit: BoxFit.fitWidth)),
                  ),
                ),
              ),
              CustomButton(
                label: "Save to device",
                usesProvider: true,
                buttonKey: buttonKey,
                onPressed: saveFileToDevice,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveFileToDevice() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);

    final output = (await (Platform.isAndroid
        ? getExternalStorageDirectory()
        : getApplicationDocumentsDirectory()))!;
    final name = ref
        .read(currentTransactionProvider)
        .transactionName
        .replaceAll(" ", "_")
        .toLowerCase();
    final file = File("${output.path}/$name.jpg");
    await file.writeAsBytes(widget.receiptBytes);

    await Future.delayed(const Duration(seconds: 2));

    if (Platform.isAndroid) {
      // final permissionGranted = (await Permission.storage.request()).isGranted;
      // if (!permissionGranted) {
      //   SnackbarManager.showErrorSnackbar(
      //       context: context, message: "Enable Troco File permission to save");
      //   ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      //   return;
      // }

      final copy = await file.copy("/storage/emulated/0/Download/$name.jpg");
      log(copy.path);

      if (!(await copy.exists())) {
        SnackbarManager.showErrorSnackbar(
            context: context, message: "Error saving receipt");
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        return;
      }
    }

    SnackbarManager.showBasicSnackbar(
        context: context, message: "Receipt Saved To Device");
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
  }
}
