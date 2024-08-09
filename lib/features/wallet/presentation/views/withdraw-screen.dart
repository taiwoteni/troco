import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-profile-widget.dart';
import 'package:troco/features/wallet/domain/repository/wallet-repository.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/images/svg.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../auth/presentation/providers/client-provider.dart';
import '../../../payments/domain/entity/account-method.dart';
import '../../../payments/presentation/widgets/select-payment-profile-sheet.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  AccountMethod? selectedAccount;
  final buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorManager.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: SizeManager.large * 1.2,
          ),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  extraLargeSpacer(),
                  back(),
                  mediumSpacer(),
                  title(),
                  largeSpacer(),
                  walletWidget(),
                  largeSpacer(),
                  mediumSpacer(),
                  selectedAccount == null
                      ? noAccountSelected()
                      : SelectPaymentProfileWidget(
                          selected: true,
                          onChecked: () async {
                            final selectedAccount = await selectBankAccount();
                            setState(
                                () => this.selectedAccount = selectedAccount);
                          },
                          method: selectedAccount!),
                  mediumSpacer(),
                  withdrawInput(),
                  largeSpacer(),
                  button(),
                  extraLargeSpacer(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget title() {
    return Text(
      "Withdraw",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget back() {
    return Align(
      alignment: Alignment.centerRight,
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
    );
  }

  Widget walletWidget() {
    final NumberFormat formatter = NumberFormat.currency(
        locale: 'en_NG',
        // symbol: '₦',
        symbol: '',
        decimalDigits: 0);
    final double boxWidth =
        MediaQuery.of(context).size.width - SizeManager.medium * 2;
    TextStyle defaultStyle = const TextStyle(
        fontFamily: "Quicksand",
        color: Colors.white,
        fontSize: FontSizeManager.extralarge * 1.1,
        fontWeight: FontWeightManager.extrabold);
    return Container(
        padding: const EdgeInsets.only(
            bottom: SizeManager.medium, left: SizeManager.medium * 1.5),
        height: 200,
        width: double.maxFinite,
        decoration: BoxDecoration(
            color: ColorManager.accentColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(SizeManager.large)),
        child: Stack(children: [
          Positioned(
              top: -boxWidth / 2.5 / 3.5,
              right: -boxWidth / 2.5 / 3.5,
              child: Container(
                  width: boxWidth / 2.5,
                  height: boxWidth / 2.5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2)))),
          Positioned(
              top: 0,
              bottom: 0,
              right: -boxWidth / 2.5 / 2,
              child: Container(
                  width: boxWidth / 2.5,
                  height: boxWidth / 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.4)))),
          SizedBox(
              height: double.maxFinite,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    mediumSpacer(),
                    const Text("My Wallet",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato',
                            fontSize: FontSizeManager.medium * 0.9,
                            fontWeight: FontWeightManager.medium)),
                    const Spacer(),
                    AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) {
                          return RichText(
                              text: TextSpan(style: defaultStyle, children: [
                            TextSpan(
                                text: formatter.format(controller.value *
                                    ref.watch(clientProvider)!.walletBalance)),
                            TextSpan(
                                text: ".00",
                                style: defaultStyle.copyWith(
                                    fontSize: FontSizeManager.large,
                                    color: Colors.white.withOpacity(0.4))),
                            const TextSpan(text: " NGN")
                          ]));
                        }),
                    regularSpacer(),
                    const Text("+15% 0 NGN",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'Lato',
                            fontSize: FontSizeManager.medium * 0.9,
                            fontWeight: FontWeightManager.semibold)),
                    const Spacer(),
                    Text("#${ClientProvider.readOnlyClient!.referralCode}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Quicksand',
                            fontSize: FontSizeManager.medium * 0.8,
                            fontWeight: FontWeightManager.regular))
                  ]))
        ]));
  }

  Widget noAccountSelected() {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () async {
        final selectedAccount = await selectBankAccount();
        setState(() => this.selectedAccount = selectedAccount);
      },
      child: Container(
        width: double.maxFinite,
        height: 95,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: ColorManager.background,
            border: Border.all(
                color: ColorManager.secondary.withOpacity(0.09), width: 2),
            borderRadius: BorderRadius.circular(SizeManager.regular)),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Text(
                "Select a bank account",
                style: TextStyle(
                    color: ColorManager.secondary,
                    fontSize: FontSizeManager.regular,
                    fontWeight: FontWeightManager.medium),
              ),
            ),
            Positioned(
                right: 0,
                child: IconButton(
                    onPressed: null,
                    iconSize: IconSizeManager.small,
                    icon: Icon(
                      Icons.expand_circle_down,
                      color: ColorManager.secondary,
                      size: IconSizeManager.small,
                    )))
          ],
        ),
      ),
    );
  }

  Widget withdrawInput() {
    return InputFormField(
      controller: amountController,
      inputType: TextInputType.number,
      isPassword: false,
      label: "amount",
      validator: (value) {
        if (value == null) {
          return "* enter an amount.";
        }

        if (!isNumber(text: value) || double.tryParse(value) == null) {
          return "* enter a valid amount";
        }

        return value.isNotEmpty
            ? double.parse(value) == 0
                ? "* enter an amount"
                : null
            : "* enter an amount.";
      },
      onSaved: (value) {},
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "naira"),
          size: const Size.square(IconSizeManager.regular),
          color: ColorManager.themeColor,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<AccountMethod?> selectBankAccount() async {
    final account = await showModalBottomSheet<AccountMethod?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: false,
      isDismissible: false,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) => const SelectPaymentProfileSheet(
        onlyAccount: true,
      ),
    );

    return account;
  }

  bool isNumber({required final String text}) {
    RegExp regex = RegExp(r'^\d+$');

    return regex.hasMatch(text);
  }

  Widget button() {
    return CustomButton(
      label: "Withdraw",
      usesProvider: true,
      buttonKey: buttonKey,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        if (selectedAccount == null || !formKey.currentState!.validate()) {
          if (selectedAccount == null) {
            SnackbarManager.showBasicSnackbar(
                context: context,
                mode: ContentType.failure,
                message: "Select account to receive the withdrawal");
          }
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

          return;
        }

        final response = await WalletRepository.requestWithdrawal(
            amount: double.parse(amountController.text),
            account: selectedAccount!);
        log(response.body, name: "Withdraw");
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

        if (response.error) {
          SnackbarManager.showBasicSnackbar(
              context: context,
              mode: ContentType.failure,
              message: "Failed to withdraw amount.");
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        } else {
          SnackbarManager.showBasicSnackbar(
              context: context,
              message:
                  "Successfully requested admin for withdrawal. You will be notified soon.");
          Navigator.pop(context);
        }
      },
    );
  }
}
