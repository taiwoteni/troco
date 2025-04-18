import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/api/data/model/response-model.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/images/pick-profile-widget.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/texts/inputs/dropdown-input-field.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/auth/utils/category-converter.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/app/value-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../auth/domain/entities/client.dart';
import '../../../../auth/presentation/register/widgets/search-place.dart';
import '../../../../transactions/utils/enums.dart';
import '../../../../settings/domain/repository/edit-profile-repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController firstNameController =
      TextEditingController(text: ClientProvider.readOnlyClient?.firstName);
  final TextEditingController lastNameController =
      TextEditingController(text: ClientProvider.readOnlyClient?.lastName);
  final TextEditingController businessNameController =
      TextEditingController(text: ClientProvider.readOnlyClient?.businessName);
  final TextEditingController addressController =
      TextEditingController(text: ClientProvider.readOnlyClient?.address);
  final TextEditingController stateController =
      TextEditingController(text: ClientProvider.readOnlyClient?.state);
  final TextEditingController cityController =
      TextEditingController(text: ClientProvider.readOnlyClient?.city);
  final TextEditingController bustopController =
      TextEditingController(text: ClientProvider.readOnlyClient?.bustop);
  final TextEditingController zipcodeController =
      TextEditingController(text: ClientProvider.readOnlyClient?.zipcode);

  final Map<dynamic, dynamic> clientJson =
      ClientProvider.readOnlyClient!.toJson();

  String? state = ClientProvider.readOnlyClient!.state;
  String? city = ClientProvider.readOnlyClient!.state;
  Category? role = ClientProvider.readOnlyClient!.accountCategory;

  final formKey = GlobalKey<FormState>();
  final UniqueKey buttonKey = UniqueKey();

  final Color infoColor = ColorManager.accentColor;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    businessNameController.dispose();
    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    zipcodeController.dispose();
    bustopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        backgroundColor: ColorManager.background,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Gap(MediaQuery.of(context).viewPadding.top),
              appBar(),
              largeSpacer(),
              profileWidget(),
              extraLargeSpacer(),
              largeSpacer(),
              Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      fullName(),
                      largeSpacer(),
                      mediumSpacer(),
                      businessName(),
                      largeSpacer(),
                      mediumSpacer(),
                      addressWidget(),
                      largeSpacer(),
                      mediumSpacer(),
                      location(),
                      largeSpacer(),
                      mediumSpacer(),
                      others(),
                      extraLargeSpacer(),
                      button(),
                      //
                      largeSpacer(),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget firstName() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: InfoText(
            text: "First Name",
            color: infoColor,
            fontSize: FontSizeManager.regular * 0.9,
            fontWeight: FontWeightManager.semibold,
          ),
        ),
        regularSpacer(),
        InputFormField(
          controller: firstNameController,
          label: '',
          validator: (value) {
            if (value == null) {
              return "* enter name";
            }
            if (value.trim().isEmpty) {
              return "* enter name";
            }
            return null;
          },
          onSaved: (value) {
            clientJson["firstName"] = value;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget lastName() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: InfoText(
            text: "Last Name",
            color: infoColor,
            fontSize: FontSizeManager.regular * 0.9,
            fontWeight: FontWeightManager.semibold,
          ),
        ),
        regularSpacer(),
        InputFormField(
          controller: lastNameController,
          label: '',
          validator: (value) {
            if (value == null) {
              return "* enter name";
            }
            if (value.trim().isEmpty) {
              return "* enter name";
            }
            return null;
          },
          onSaved: (value) {
            clientJson["lastName"] = value;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget fullName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      child: Row(
        children: [
          Expanded(child: firstName()),
          mediumSpacer(),
          Expanded(child: lastName())
        ],
      ),
    );
  }

  Widget businessName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Business Name",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            controller: businessNameController,
            label: '',
            validator: (value) {
              if (value == null) {
                return "* business name";
              }
              if (value.trim().isEmpty) {
                return "* business name";
              }
              return null;
            },
            onSaved: (value) {
              clientJson["businessName"] = value;
            },
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget addressWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Address",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          InputFormField(
            controller: addressController,
            label: '',
            validator: (value) {
              if (value == null) {
                return "* enter address";
              }
              if (value.trim().isEmpty) {
                return "* enter address";
              }
              return null;
            },
            onSaved: (value) {
              clientJson["address"] = value;
            },
            prefixIcon: null,
          ),
        ],
      ),
    );
  }

  Widget categoryWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: InfoText(
              text: "Account Category",
              color: infoColor,
              fontSize: FontSizeManager.regular * 0.9,
              fontWeight: FontWeightManager.semibold,
            ),
          ),
          regularSpacer(),
          DropdownInputFormField(
            value: CategoryConverter.convertToString(
                category: role ?? Category.Personal),
            hint: "",
            prefixIcon: null,
            items: Category.values
                .map((e) => CategoryConverter.convertToString(category: e))
                .toList(),
            onChanged: (value) {
              setState(() {
                role = CategoryConverter.convertToCategory(category: value!);
              });
              clientJson["role"] = value!;
            },
          ),
        ],
      ),
    );
  }

  Widget stateWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: InfoText(
            text: "State",
            color: infoColor,
            fontSize: FontSizeManager.regular * 0.9,
            fontWeight: FontWeightManager.semibold,
          ),
        ),
        regularSpacer(),
        InputFormField(
          controller: stateController,
          label: '',
          inputType: TextInputType.name,
          showtrailingIcon: true,
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
            if (answer != null) {
              setState(() {
                state = answer;
                city = null;
                cityController.text = "";
              });
            }

            return state;
          },
          validator: (value) {
            return state == null ? "* select state" : null;
          },
          onSaved: (value) {
            clientJson["state"] = value!;
          },
          readOnly: true,
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget cityWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: InfoText(
            text: "City",
            color: infoColor,
            fontSize: FontSizeManager.regular * 0.9,
            fontWeight: FontWeightManager.semibold,
          ),
        ),
        regularSpacer(),
        InputFormField(
          controller: cityController,
          label: '',
          inputType: TextInputType.name,
          onRedirect: () async {
            final answer = await showModalBottomSheet<String?>(
              useSafeArea: true,
              enableDrag: true,
              isScrollControlled: true,
              backgroundColor: ColorManager.background,
              context: context,
              builder: (context) {
                return SearchPlaceScreen(
                  places: ValuesManager.allCitiesAndState()[state]!,
                  mode: "City",
                );
              },
            );
            if (answer != null) {
              setState(() {
                city = answer;
              });
            }
            return city;
          },
          validator: (value) {
            return city == null ? "* select city" : null;
          },
          onSaved: (value) {
            clientJson["city"] = value!;
          },
          readOnly: true,
          showtrailingIcon: true,
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget location() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      child: Row(
        children: [
          Expanded(child: stateWidget()),
          mediumSpacer(),
          Expanded(child: cityWidget())
        ],
      ),
    );
  }

  Widget bustopWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: InfoText(
            text: "Nearest Bustop",
            color: infoColor,
            fontSize: FontSizeManager.regular * 0.9,
            fontWeight: FontWeightManager.semibold,
          ),
        ),
        regularSpacer(),
        InputFormField(
          controller: bustopController,
          label: '',
          validator: (value) {
            if (value == null) {
              return "* enter Bus-Stop.";
            }
            return value.trim().isNotEmpty ? null : "* enter Bus-stop";
          },
          onSaved: (value) {
            clientJson["nearestBustop"] = value;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget zipcodeWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
          child: InfoText(
            text: "Zip Code",
            color: infoColor,
            fontSize: FontSizeManager.regular * 0.9,
            fontWeight: FontWeightManager.semibold,
          ),
        ),
        regularSpacer(),
        InputFormField(
          controller: zipcodeController,
          label: '',
          validator: (value) {
            if (value == null) {
              return "* enter ZipCode";
            }
            return value.trim().isNotEmpty ? null : "* enter ZipCode";
          },
          onSaved: (value) {
            clientJson["zipcode"] = value;
          },
          prefixIcon: null,
        ),
      ],
    );
  }

  Widget others() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      child: Row(
        children: [
          Expanded(child: bustopWidget()),
          mediumSpacer(),
          Expanded(child: zipcodeWidget())
        ],
      ),
    );
  }

  Widget profileWidget() {
    final decorImage = DecorationImage(
      image: CachedNetworkImageProvider(
        ClientProvider.readOnlyClient!.profile,
      ),
      fit: BoxFit.cover,
    );
    // GestureDetector(
    //   child: ProfileIcon(
    //     size: IconSizeManager.extralarge * 1.7,
    //     url: ClientProvider.readOnlyClient!.profile,
    //     badge: Positioned(
    //         bottom: 2,
    //         right: -2,
    //         child: BadgeIcon(
    //           stroke: 3,
    //           size: IconSizeManager.medium * 1.1,
    //           iconType: BadgeIconType.icon,
    //           iconData: Icons.edit_rounded,
    //         )),
    //   ),
    // ),
    return PickProfileIcon(
      size: IconSizeManager.extralarge * 1.7,
      previousImage: decorImage,
      canDelete: false,
      onPicked: (path) {
        setState(() {
          clientJson["userImage"] = path;
        });
      },
    );
  }

  Widget button() {
    return CustomButton(
      onPressed: updateUserAccount,
      label: "Save",
      buttonKey: buttonKey,
      usesProvider: true,
      margin: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize:
          Size.fromHeight(72 + MediaQuery.of(context).viewPadding.top),
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
                mediumSpacer(),
                Text(
                  "Edit Profile",
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

  Future<void> updateUserAccount() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // to know if anything was changed;
      bool changed = false;
      bool profileChanged =
          ClientProvider.readOnlyClient!.profile != clientJson["userImage"];
      clientJson.forEach(
        (key, value) {
          if (value !=
              ClientProvider.readOnlyClient!.toJson()[key.toString()]) {
            changed = true;
          }
        },
      );

      //we want to update profile photo first.
      //Naturally, after updating photo, it will still update user cos
      //that means changed is true since the user profile has already changed;
      if (profileChanged) {
        final response = await changePickProfile();
        log(response.body);

        if (!response.error) {
          /// cos we will have to update the userImage to the url
          /// if not, when the userProfile is updated after calling updateUserProfile route
          /// the Client's userImage will be a file path.
          clientJson["userImage"] = response.messageBody!["data"]["userImage"];
        } else {
          /// we revert back since it was unsuccessful.
          clientJson["userImage"] = ClientProvider.readOnlyClient!.profile;
          SnackbarManager.showBasicSnackbar(
              context: context,
              mode: ContentType.failure,
              message: "Unable to upload photo");
        }
      }

      if (changed) {
        final response = await EditProfileRepository.updateUserProfile(
            client: Client.fromJson(json: clientJson));
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        if (!response.error) {
          ClientProvider.saveUserData(ref: ref, json: clientJson);
          SnackbarManager.showBasicSnackbar(
              context: context, message: "Edited Profile");
        } else {
          SnackbarManager.showBasicSnackbar(
              context: context,
              mode: ContentType.failure,
              message: "Unable to edit profile. Check internet.");
        }
      } else {
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      }
    } else {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    }
  }

  Future<HttpResponseModel> changePickProfile() async {
    final response = await EditProfileRepository.uploadProfilePhoto(
        userId: ClientProvider.readOnlyClient!.userId,
        profilePath: clientJson["userImage"]);

    return response;
  }
}
