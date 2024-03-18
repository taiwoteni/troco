// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/custom-views/button.dart';
import 'package:troco/custom-views/dropdown-input-field.dart';
import 'package:troco/custom-views/info-text.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/data/converters.dart';
import 'package:troco/data/enums.dart';
import 'package:troco/providers/button-provider.dart';

import '../../app/font-manager.dart';
import '../../custom-views/text-form-field.dart';

class SetupAccountScreen extends ConsumerStatefulWidget {
  const SetupAccountScreen({super.key});

  @override
  ConsumerState<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends ConsumerState<SetupAccountScreen> {
  final UniqueKey buttonKey = UniqueKey();
  Role? role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewPadding.top,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar(),
        backgroundColor: ColorManager.background,
        body: SingleChildScrollView(
          child: Center(
            child: Form(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                descriptionWidget(),
                firstNameWidget(),
                lastNameWidget(),
                roleWidget(),
                bussinessNameWidget(),
                bussinessCategoryWidget(),
                addressWidget(),
                regularSpacer(),
                legitAddressWidget(),
                regularSpacer(),
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
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                const Gap(16),
                Text(
                  "Setup account",
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

  Widget descriptionWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: SizeManager.medium,
        vertical: SizeManager.regular,
      ),
      child: Text(
        "Complete the following to setup\nyour account.",
        textAlign: TextAlign.left,
        style: TextStyle(
            fontFamily: 'Lato',
            height: 1.36,
            wordSpacing: 1.2,
            color: ColorManager.secondary,
            fontSize: FontSizeManager.medium,
            fontWeight: FontWeightManager.semibold),
      ),
    );
  }

  Widget roleWidget() {
    return DropdownInputFormField(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        Role role = RoleConverter.convertToRole(role: value.toString());
        setState(() {
          this.role = role;
        });
      },
      value: role == null ? "" : RoleConverter.convertToString(role: role!),
      hint: "Role",
      items: Role.values.map((role) => role.name).toList(),
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "work"),
          color: ColorManager.themeColor,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget bussinessNameWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.emailAddress,
        label: "business name",
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: SvgIcon(
            svgRes: AssetManager.svgFile(name: "work-fill"),
            color: ColorManager.themeColor,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget bussinessCategoryWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.emailAddress,
        label: "category",
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: SvgIcon(
            svgRes: AssetManager.svgFile(name: "work"),
            color: ColorManager.themeColor,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget firstNameWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.name,
        label: "first name",
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            CupertinoIcons.person_fill,
            color: ColorManager.themeColor,
          ),
        ),
      ),
    );
  }

  Widget lastNameWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.name,
        label: "last name",
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            CupertinoIcons.person_fill,
            color: ColorManager.themeColor,
          ),
        ),
      ),
    );
  }

  Widget addressWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.name,
        label: "address",
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            CupertinoIcons.location_solid,
            color: ColorManager.themeColor,
          ),
        ),
      ),
    );
  }

  Widget legitAddressWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SizeManager.small,
              horizontal: SizeManager.medium * 1.5),
          child: InfoText(
            text: "* address should be legit and legal.",
            color: ColorManager.secondary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: SizeManager.small,
              horizontal: SizeManager.medium * 1.5),
          child: InfoText(
            text: "* Info such as City and State will be collected.",
            color: ColorManager.secondary,
          ),
        ),
      ],
    );
  }

  Widget nextButton() {
    return CustomButton(
      buttonKey: buttonKey,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        //..Logic to get location details.
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        Navigator.pushNamed(context, Routes.addTransactionPinRoute);
      },
      usesProvider: true,
      label: "NEXT",
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManager.large, vertical: SizeManager.medium),
    );
  }
}
