import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/payments/domain/entity/account-method.dart';
import 'package:troco/features/payments/presentation/provider/payment-methods-provider.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-profile-widget.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/routes-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/drag-handle.dart';
import '../../../../core/components/others/spacer.dart';
import '../../domain/entity/payment-method.dart';

class SelectPaymentProfileSheet extends ConsumerStatefulWidget {
  final bool onlyAccount;
  const SelectPaymentProfileSheet({super.key, this.onlyAccount = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectPaymentMethodSheetState();
}

class _SelectPaymentMethodSheetState
    extends ConsumerState<SelectPaymentProfileSheet> {
  bool loading = false;
  int selectedProfileIndex = 0;
  List<PaymentMethod> methods = [];
  final buttonKey = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    methods = ref.watch(paymentMethodProvider).where((element) => widget.onlyAccount? element is AccountMethod:false,).toList();
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
            methodsList(),
            extraLargeSpacer(),
            if (methods.isNotEmpty) button(),
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
            "Select Payment Profile",
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

  Widget methodsList() {
    final style = TextStyle(
      color: ColorManager.secondary,
      fontFamily: 'lato',
      height: 1.6,
      fontSize: FontSizeManager.regular,
      fontWeight: FontWeightManager.regular,
    );

    return methods.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: style, children: [
                  const TextSpan(
                      text: "You do not have any payment profile.\n"),
                  TextSpan(
                      text: "Create One",
                      style: style.copyWith(
                        fontWeight: FontWeightManager.semibold,
                        color: ColorManager.accentColor,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(
                              context, Routes.paymentMethodRoute);
                        })
                ])),
          )
        : ListView.builder(
            itemCount: methods.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: SizeManager.regular),
                child: SelectPaymentProfileWidget(
                    selected: selectedProfileIndex == index,
                    onChecked: () =>
                        setState(() => selectedProfileIndex = index),
                    method: methods[index]),
              );
            },
            shrinkWrap: true,
          );
  }

  Widget button() {
    return CustomButton(
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: selectProfile,
        label: "Select Profile");
  }

  Future<void> selectProfile() async {
    setState(() => loading = true);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => loading = false);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    Navigator.pop(context, methods[selectedProfileIndex]);
  }
}
