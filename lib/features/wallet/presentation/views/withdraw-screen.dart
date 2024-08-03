import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../auth/presentation/providers/client-provider.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              extraLargeSpacer(),
              back(),
              mediumSpacer(),
              title(),
              largeSpacer(),
              walletWidget(),
            ],
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
                    Text(
                        "${ref.watch(ClientProvider.userProvider)!.fullName} -",
                        style: const TextStyle(
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
}
