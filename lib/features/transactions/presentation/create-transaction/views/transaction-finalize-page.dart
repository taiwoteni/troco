// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/basecomponents/button/presentation/provider/button-provider.dart';
import '../../../../../core/basecomponents/button/presentation/widget/button.dart';
import '../../../../groups/domain/entities/group.dart';
import '../widgets/transaction-pin-widget.dart';
import 'create-transaction-progress-screen.dart';

class TransactionFinalizePage extends ConsumerStatefulWidget {
  const TransactionFinalizePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPreviewPageState();
}

class _TransactionPreviewPageState
    extends ConsumerState<TransactionFinalizePage> {
  final textStyle = TextStyle(
      color: ColorManager.primary,
      fontFamily: 'quicksand',
      fontSize: FontSizeManager.medium,
      fontWeight: FontWeightManager.semibold);
  final buttonKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.large, right: SizeManager.large),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              groupProfileIcon(),
              mediumSpacer(),
              groupName(),
              mediumSpacer(),
              detailText(),
              extraLargeSpacer(),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget groupProfileIcon() {
    return const GroupProfileIcon(
      size: IconSizeManager.extralarge * 1.35,
    );
  }

  Widget groupName() {
    final group = (ModalRoute.of(context)!.settings.arguments! as Group);
    return Text(
      group.groupName,
      style: textStyle,
    );
  }

  Widget detailText() {
    final group = (ModalRoute.of(context)!.settings.arguments! as Group);
    return Text(
      "You're about to create a transaction in ${group.groupName}.\nNo fraudulent practices will be tolerated.",
      textAlign: TextAlign.center,
      style: textStyle.copyWith(
        height: 2,
        fontSize: FontSizeManager.regular * 0.85,
        color: ColorManager.secondary,
        fontWeight: FontWeightManager.medium,
      ),
    );
  }

  Widget button() {
    return CustomButton.medium(
      label: "Agree",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        await verifyPin();
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }

  Future<void> verifyPin() async {
    final verifyPin = await showModalBottomSheet<bool?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) {
        return const SingleChildScrollView(child: TransactionPinSheet());
      },
    );

    if (verifyPin ?? false) {
      // createTransaction();
      Navigator.push(
          context,
          MaterialPageRoute(
            settings:
                RouteSettings(arguments: ModalRoute.of(context)!.settings.arguments),
            builder: (context) => const CreateTransactonProgressScreen(),
          ));
    }
  }
}
