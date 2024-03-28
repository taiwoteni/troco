// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/value-manager.dart';
import 'package:troco/custom-views/button.dart';
import 'package:troco/custom-views/dropdown-input-field.dart';
import 'package:troco/custom-views/info-text.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/custom-views/svg.dart';
import 'package:troco/data/converters.dart';
import 'package:troco/data/enums.dart';
import 'package:troco/data/login-data.dart';
import 'package:troco/providers/button-provider.dart';
import 'package:troco/view/register-screen/search-place.dart';

import '../../app/font-manager.dart';
import '../../custom-views/text-form-field.dart';

class SetupAccountScreen extends ConsumerStatefulWidget {
  const SetupAccountScreen({super.key});

  @override
  ConsumerState<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends ConsumerState<SetupAccountScreen> {
  final formKey = GlobalKey<FormState>();
  final UniqueKey buttonKey = UniqueKey();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String? state, city;
  Category? role;

  @override
  Widget build(BuildContext context) {
    stateController.text = state ?? "";
    cityController.text = city ?? "";
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
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    descriptionWidget(),
                    firstNameWidget(),
                    lastNameWidget(),
                    categoryWidget(),
                    bussinessNameWidget(),
                    addressWidget(),
                    Row(
                      children: [
                        Expanded(child: stateWidget()),
                        Expanded(child: cityWidget()),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: bustopWidget()),
                        Expanded(child: zipCodeWidget()),
                      ],
                    ),
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

  Widget categoryWidget() {
    return DropdownInputFormField(
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.regular),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        Category role =
            CatgoryConverter.convertToCategory(category: value.toString());
        setState(() {
          this.role = role;
        });
        LoginData.category = role;
      },
      value:
          role == null ? "" : CatgoryConverter.convertToString(category: role!),
      hint: "account category",
      items: Category.values.map((role) => role.name).toList(),
      onValidate: (value) {
        if (value == null) {
          return '* select your account category.';
        }
        return null;
      },
      prefixIcon: IconButton(
        onPressed: null,
        iconSize: IconSizeManager.regular,
        icon: SvgIcon(
          svgRes: AssetManager.svgFile(name: "work-fill"),
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
        validator: (value) {
          if (value == null) {
            return "* enter business name.";
          }
          return value.trim().isNotEmpty ? null : "* enter valid business name";
        },
        onSaved: (value) {
          LoginData.businessName = value;
        },
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            Icons.business_rounded,
            color: ColorManager.themeColor,
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
        validator: (value) {
          if (value == null) {
            return "* enter your first name";
          }
          return value.trim().isNotEmpty ? null : "* enter a valid name";
        },
        onSaved: (value) {
          LoginData.firstName = value;
        },
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
        validator: (value) {
          if (value == null) {
            return "* enter your last name";
          }
          return value.trim().isNotEmpty ? null : "* enter a valid name";
        },
        onSaved: (value) {
          LoginData.lastName = value;
        },
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
        inputType: TextInputType.streetAddress,
        label: "address",
        validator: (value) {
          if (value == null) {
            return "* enter address";
          }
          return value.trim().isNotEmpty ? null : "* enter valid address.";
        },
        onSaved: (value) {
          LoginData.address = value;
        },
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

  Widget stateWidget() {
    return Padding(
      padding: const EdgeInsets.only(
          left: SizeManager.medium,
          right: SizeManager.regular,
          top: SizeManager.regular,
          bottom: SizeManager.regular),
      child: InputFormField(
        controller: stateController,
        inputType: TextInputType.name,
        label: "select state",
        onRedirect: () async {
          final answer = await showModalBottomSheet<String?>(
            useSafeArea: true,
            enableDrag: true,
            isScrollControlled: true,
            backgroundColor: ColorManager.background,
            context: context,
            builder: (context) {
              return SearchPlaceScreen(
                places: ValuesManager.allCitiesAndState().keys.toList(),
                mode: "State",
              );
            },
          );
          setState(() {
            state = answer;
            city = null;
          });
          return answer;
        },
        validator: (value) {
          return state == null ? "* select a state" : null;
        },
        onSaved: (value) {
          LoginData.state = state;
        },
        showLeadingIcon: true,
        readOnly: true,
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            Icons.location_city_rounded,
            color: ColorManager.themeColor,
          ),
        ),
      ),
    );
  }

  Widget cityWidget() {
    return Padding(
      padding: const EdgeInsets.only(
          right: SizeManager.medium,
          left: SizeManager.regular,
          top: SizeManager.regular,
          bottom: SizeManager.regular),
      child: InputFormField(
        controller: cityController,
        inputType: TextInputType.name,
        label: "select city",
        onRedirect: () async {
          if (state == null) {
            return null;
          }
          final answer = await showModalBottomSheet<String?>(
            isScrollControlled: true,
            enableDrag: true,
            useSafeArea: true,
            backgroundColor: ColorManager.background,
            context: context,
            builder: (context) {
              return SearchPlaceScreen(
                places: ValuesManager.allCitiesAndState()[state]!,
                mode: "city",
              );
            },
          );
          setState(() {
            city = answer;
          });
          return answer;
        },
        validator: (value) {
          return city == null ? "* select a city" : null;
        },
        onSaved: (value) {
          LoginData.city = city;
        },
        readOnly: true,
        showLeadingIcon: true,
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            Icons.location_city_rounded,
            color: ColorManager.themeColor,
          ),
        ),
      ),
    );
  }

  Widget bustopWidget() {
    return Padding(
      padding: const EdgeInsets.only(
          left: SizeManager.medium,
          right: SizeManager.regular,
          top: SizeManager.regular,
          bottom: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.name,
        label: "nearest stop",
        validator: (value) {
          if (value == null) {
            return "* enter Bus-Stop.";
          }
          return value.trim().isNotEmpty ? null : "* enter valid Bus-stop";
        },
        onSaved: (value) {
          LoginData.nearestBustop = value;
        },
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            Icons.bus_alert_rounded,
            color: ColorManager.themeColor,
          ),
        ),
      ),
    );
  }

  Widget zipCodeWidget() {
    return Padding(
      padding: const EdgeInsets.only(
          right: SizeManager.medium,
          left: SizeManager.regular,
          top: SizeManager.regular,
          bottom: SizeManager.regular),
      child: InputFormField(
        inputType: TextInputType.phone,
        label: "zip code",
        validator: (value) {
          if (value == null) {
            return "* enter zip code.";
          }
          return value.trim().isNotEmpty ? null : "* enter valid zip code.";
        },
        onSaved: (value) {
          LoginData.zipCode = value;
        },
        prefixIcon: IconButton(
          onPressed: null,
          iconSize: IconSizeManager.regular,
          icon: Icon(
            Icons.location_pin,
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
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          await Future.delayed(const Duration(seconds: 2));
          //..Logic to get location details.
          Navigator.pushNamed(context, Routes.addProfileRoute);
        }
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
      usesProvider: true,
      label: "NEXT",
      margin: const EdgeInsets.symmetric(
          horizontal: SizeManager.large, vertical: SizeManager.medium),
    );
  }
}
