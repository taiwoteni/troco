import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/transactions/utils/service-role.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import 'select-transaction-type-widget.dart';

class SelectRolesSheet extends ConsumerStatefulWidget {
  const SelectRolesSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectPaymentMethodSheetState();
}

class _SelectPaymentMethodSheetState extends ConsumerState<SelectRolesSheet> {
  bool loading = false;
  final buttonKey = UniqueKey();
  ServiceRole role = ServiceRole.Developer;

  @override
  void initState() {
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
            mediumSpacer(),
            Divider(
              thickness: 1,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
            mediumSpacer(),
            SelectTransactionTypeWidget(
              label: 'Developer',
              description: "If you're the developer of this transaction",
              selected: role == ServiceRole.Developer,
              onChecked: () {
                setState(() {
                  role = ServiceRole.Developer;
                });
              },
            ),
            mediumSpacer(),
            SelectTransactionTypeWidget(
              label: 'Client',
              description: "If you're the client of this transaction",
              selected: role == ServiceRole.Client,
              onChecked: () {
                setState(() {
                  role = ServiceRole.Client;
                });
              },
            ),
            extraLargeSpacer(),
            button(),
            extraLargeSpacer()
          ],
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
            "Select Role",
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

  Widget button() {
    return CustomButton(
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: selectProfile,
        label: "Select");
  }

  Future<void> selectProfile() async {
    setState(() => loading = true);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => loading = false);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    Navigator.pop(context, role);
  }
}
