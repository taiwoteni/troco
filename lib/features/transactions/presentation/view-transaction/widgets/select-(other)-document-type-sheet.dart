import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-method-widget.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class SelectOtherDocumentTypeSheet extends ConsumerStatefulWidget {
  const SelectOtherDocumentTypeSheet({super.key});

  @override
  ConsumerState createState() => _SelectOtherDocumentTypeSheetState();

  /// [bottomSheet] will return true if description (as an option) was selected
  static Future<bool?> bottomSheet({required final BuildContext context}) {
    return showModalBottomSheet(
      backgroundColor: ColorManager.background,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      context: context,
      builder: (context) {
        return const SelectOtherDocumentTypeSheet();
      },
    );
  }
}

class _SelectOtherDocumentTypeSheetState
    extends ConsumerState<SelectOtherDocumentTypeSheet> {
  bool loading = false;
  bool description = false;
  final buttonKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: SingleChildScrollView(
        child: Column(
          children: [
            extraLargeSpacer(),
            const DragHandle(),
            largeSpacer(),
            title(),
            largeSpacer(),
            type(),
            extraLargeSpacer(),
            button(),
            extraLargeSpacer(),
          ],
        ),
      ),
    );
  }

  Widget type() {
    return Row(
      children: [
        SelectPaymentMethodWidget(
          selected: description,
          moveLeft: true,
          onChecked: () => setState(() => description = true),
          label: "Write-up",
          color: ColorManager.accentColor,
          lottie: AssetManager.lottieFile(name: "write"),
        ),
        mediumSpacer(),
        SelectPaymentMethodWidget(
          selected: !description,
          onChecked: () => setState(() => description = false),
          label: "Document",
          lottie: AssetManager.lottieFile(name: "file"),
        ),
      ],
    );
  }

  Widget button() {
    return CustomButton(
        label: "Select",
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: select);
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
            "Select Type",
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
              onPressed: () => Navigator.pop(context),
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

  Future<void> select() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    context.pop(result: description);
  }
}
