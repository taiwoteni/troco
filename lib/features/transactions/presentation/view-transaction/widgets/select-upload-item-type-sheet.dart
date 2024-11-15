import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-method-widget.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/enter-link-sheet.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class SelectUploadItemTypeSheet extends ConsumerStatefulWidget {
  const SelectUploadItemTypeSheet({super.key});

  @override
  ConsumerState createState() => _SelectUploadItemTypeSheetState();

  /// [bottomSheet] will return true if link (as an option) is selected
  static Future<bool?> bottomSheet({required final BuildContext context}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) {
        return const SelectUploadItemTypeSheet();
      },
    );
  }
}

class _SelectUploadItemTypeSheetState
    extends ConsumerState<SelectUploadItemTypeSheet> {
  bool loading = false;
  bool link = false;
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
          selected: link,
          moveLeft: true,
          onChecked: () => setState(() => link = true),
          label: "Link",
          lottie: AssetManager.lottieFile(name: "link"),
        ),
        mediumSpacer(),
        SelectPaymentMethodWidget(
          selected: !link,
          onChecked: () => setState(() => link = false),
          label: "Other",
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
        onPressed: uploadWork);
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
            "Upload Item",
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

  Future<void> uploadWork() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    context.pop(result: link);
  }
}
