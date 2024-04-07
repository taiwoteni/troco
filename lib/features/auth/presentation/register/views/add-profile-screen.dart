import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/basecomponents/button/presentation/widget/button.dart';
import 'package:troco/core/basecomponents/images/pick-profile-widget.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/core/basecomponents/button/presentation/provider/button-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/basecomponents/images/svg.dart';

class AddProfileScreen extends ConsumerStatefulWidget {
  const AddProfileScreen({super.key});

  @override
  ConsumerState<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends ConsumerState<AddProfileScreen> {
  final UniqueKey buttonKey = UniqueKey();
  String? profilePath;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorManager.background,
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Center(
            child: Form(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                titleWidget(),
                mediumSpacer(),
                descriptionWidget(),
                largeSpacer(),
                pickProfileWidget(),
                largeSpacer(),
                nextButton(),
              ],
            )),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                FocusScope(
                  canRequestFocus: false,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    iconSize: 40,
                    icon: SvgIcon(
                      svgRes: AssetManager.svgFile(name: 'back'),
                      fit: BoxFit.cover,
                      color: ColorManager.themeColor,
                      size: const Size.square(40),
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  "Add Profile",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: Text(
        "Profile Photo",
        textAlign: TextAlign.start,
        style: TextStyle(
            fontFamily: 'Lato',
            color: ColorManager.primary,
            fontSize: FontSizeManager.extralarge,
            fontWeight: FontWeightManager.extrabold),
      ),
    );
  }

  Widget descriptionWidget() {
    final TextStyle defaultStyle = TextStyle(
        fontFamily: 'Lato',
        height: 2,
        wordSpacing: 1.2,
        color: ColorManager.secondary,
        fontSize: FontSizeManager.medium,
        fontWeight: FontWeightManager.semibold);
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: RichText(
        text: TextSpan(style: defaultStyle, children: [
          const TextSpan(text: "Pick a profile photo for your "),
          TextSpan(
              text: "trade business.\n",
              style: defaultStyle.copyWith(color: ColorManager.primary)),
          TextSpan(text: "It is required under our ", style: defaultStyle),
          TextSpan(
              text: "KYC verification regulations.",
              style: defaultStyle.copyWith(
                  color: ColorManager.themeColor,
                  decoration: TextDecoration.underline)),
        ]),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget pickProfileWidget() {
    return Container(
      width: double.maxFinite,
      alignment: Alignment.center,
      child: PickProfileIcon(
          onPicked: (path) {
            setState(() => profilePath = path);
            if (path == null) {
              ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
            } else {
              ButtonProvider.enable(buttonKey: buttonKey, ref: ref);
            }
          },
          size: IconSizeManager.extralarge * 1.8),
    );
  }

  Widget nextButton() {
    return CustomButton(
      buttonKey: buttonKey,
      onPressed: () {
        LoginData.profile = profilePath;
        Navigator.pushNamed(context, Routes.addTransactionPinRoute);
      },
      label: profilePath == null ? "SKIP" : "NEXT",
      usesProvider: true,
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManager.large, vertical: SizeManager.medium),
    );
  }
}
