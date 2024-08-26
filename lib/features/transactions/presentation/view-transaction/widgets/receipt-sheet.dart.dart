import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/presentation/provider/payment-methods-provider.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-profile-widget.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/receipt-widget.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/app/snackbar-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class ReceiptSheet extends ConsumerStatefulWidget {
  final bool onlyAccount;
  const ReceiptSheet({super.key, this.onlyAccount = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectPaymentMethodSheetState();
}

class _SelectPaymentMethodSheetState extends ConsumerState<ReceiptSheet> {
  bool loading = false;
  int selectedProfileIndex = 0;
  final buttonKey = UniqueKey();

  final screenshot = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
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
          Expanded(child: Transform.scale(scale: 0.75, child: receipt())),
          extraLargeSpacer(),
          button(),
          extraLargeSpacer()
        ],
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
            "Select ${widget.onlyAccount ? "Bank Account" : "Payment Profile"}",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "lato",
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

  Widget receipt() {
    return Screenshot(
        controller: screenshot,
        child:
            ReceiptWidget(transaction: ref.watch(currentTransactionProvider)));
  }

  Widget button() {
    return CustomButton(
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: generateScreenshot,
        label: "Select Profile");
  }

  Future<void> saveReceipt() async {
    Uint8List capturedImage = (await screenshot.capture())!;
    final pdf = pw.Document();

    final image = pw.MemoryImage(capturedImage);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    // Save or share the PDF
    final output = await getApplicationDocumentsDirectory();
    final name = ref
        .watch(currentTransactionProvider)
        .transactionName
        .replaceAll(" ", "_")
        .toLowerCase();
    final file = File("${output.path}/$name.pdf");
    await file.writeAsBytes(await pdf.save());

    SnackbarManager.showBasicSnackbar(
        context: context, message: "Saved Receipt");
    Navigator.pushNamed(context, Routes.cardPaymentScreen,
        arguments: 'file://${file.absolute.path}');
  }

  Future<void> generateScreenshot() async {
    setState(() => loading = true);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    await saveReceipt();
    setState(() => loading = false);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    Navigator.pop(context);
  }
}
