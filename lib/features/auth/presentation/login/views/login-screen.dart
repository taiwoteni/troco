// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:developer';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/features/auth/data/models/otp-data.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/groups/domain/repositories/friend-repository.dart';
import 'package:troco/features/groups/domain/repositories/group-repository.dart';
import 'package:troco/features/groups/presentation/friends_tab/providers/friends-provider.dart';
import 'package:troco/features/groups/presentation/group_tab/providers/groups-provider.dart';
import 'package:troco/features/home/presentation/providers/home-pages-provider.dart';
import 'package:troco/features/kyc/utils/enums.dart';
import 'package:troco/features/kyc/utils/kyc-converter.dart';
import 'package:troco/features/settings/utils/enums.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';
import 'package:troco/features/transactions/presentation/create-transaction/widgets/transaction-pin-widget.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transactions-provider.dart';
import 'package:troco/features/wallet/domain/repository/wallet-repository.dart';
import 'package:troco/features/wallet/presentation/providers/referrals-provider.dart';

import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/app/theme-manager.dart';
import '../../../../../core/components/texts/outputs/info-text.dart';
import '../../../../../core/components/texts/inputs/text-form-field.dart';
import '../../../../customer care/domain/repositories/customer-care-repository.dart';
import '../../../../settings/domain/entity/settings.dart';
import '../../../utils/phone-number-converter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController detailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UniqueKey buttonKey = UniqueKey();
  final formKey = GlobalKey<FormState>();
  String? errorText;
  bool isNumber = false;
  List<String> emails = [];
  List<String> phoneNumbers = [];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        SystemChrome.setSystemUIOverlayStyle(
            ThemeManager.getOnboardingUiOverlayStyle());
      },
    );
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
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SizeManager.medium,
                      vertical: SizeManager.regular,
                    ),
                    child: Text(
                      "Keep Connected",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          color: ColorManager.primary,
                          fontSize: FontSizeManager.extralarge,
                          fontWeight: FontWeightManager.extrabold),
                    ),
                  ),
                  mediumSpacer(),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SizeManager.medium,
                      vertical: SizeManager.regular,
                    ),
                    child: Text(
                      "Log in with your email or phone number.\nKeep the details of your account private.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: 'Lato',
                          height: 1.36,
                          wordSpacing: 1.2,
                          color: ColorManager.secondary,
                          fontSize: FontSizeManager.medium,
                          fontWeight: FontWeightManager.medium),
                    ),
                  ),
                  mediumSpacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      controller: detailController,
                      inputType: TextInputType.emailAddress,
                      label: "email or phone number",
                      errorText: errorText,
                      validator: validate,
                      onChanged: (value) {
                        setState(() {
                          isNumber = isPhoneNumberOrPlus(value.trim());
                        });
                      },
                      onSaved: (emailOrNumber) {
                        if (emailOrNumber == null) {
                          return;
                        }
                        // if it is a phone number
                        if (isPhoneNumberOrPlus(emailOrNumber.trim())) {
                          /// Since onSaved means that there was no
                          /// error when validating then it can only be either
                          /// 11 digits or 14 digits.

                          LoginData.phoneNumber =
                              PhoneNumberConverter.convertToFull(emailOrNumber);
                        } else {
                          LoginData.email = emailOrNumber.trim();
                        }
                      },
                      prefixIcon: isNumber ? phoneIcon() : emailIcon(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SizeManager.medium,
                        vertical: SizeManager.regular),
                    child: InputFormField(
                      controller: passwordController,
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      errorText: errorText,
                      label: "password",
                      validator: (value) {
                        if (value == null) {
                          return "* enter your password.";
                        }
                        return value.isNotEmpty
                            ? null
                            : "* enter a valid password.";
                      },
                      onSaved: (value) {
                        LoginData.password = value!;
                      },
                      prefixIcon: IconButton(
                        onPressed: null,
                        iconSize: IconSizeManager.regular,
                        icon: Image.asset(
                          AssetManager.iconFile(name: "padlock"),
                          color: ColorManager.themeColor,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  regularSpacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: SizeManager.small,
                        horizontal: SizeManager.medium * 1.5),
                    child: InfoText(
                      onPressed: navigateForgetPassword,
                      text: "Forgot Password?",
                      color: ColorManager.themeColor,
                      alignment: Alignment.centerRight,
                      fontWeight: FontWeightManager.extrabold,
                    ),
                  ),
                  regularSpacer(),
                  CustomButton(
                    buttonKey: buttonKey,
                    onPressed: next,
                    label: "LOGIN",
                    usesProvider: true,
                    margin: const EdgeInsets.symmetric(
                        horizontal: SizeManager.large,
                        vertical: SizeManager.medium),
                  ),
                  extraLargeSpacer(),
                  dontHaveAccount()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void navigateForgetPassword() {
    Navigator.pushNamed(context, Routes.forgotPasswordRoute);
    // SnackbarManager.showBasicSnackbar(
    //     context: context,
    //     seconds: 4,
    //     message: "This is still under construction");
  }

  String? validate(String? value) {
    if (value == null) {
      return "* enter your email or phone number.";
    }
    if (value.trim().isEmpty) {
      return "* enter your email or phone number.";
    }
    bool isPhone = isPhoneNumberOrPlus(value);
    bool validated =
        isPhone ? validatePhoneNumber(value) : EmailValidator.validate(value);
    // bool exists = !isPhone
    //     ? emails.contains(value.trim())
    //     : phoneNumbers
    //         .contains(PhoneNumberConverter.convertToFull(value.trim()));

    return validated
        ? null
        : isPhone
            ? "* enter a valid phone number."
            : "* enter a valid email";
  }

  Widget phoneIcon() {
    return IconButton(
      onPressed: null,
      iconSize: IconSizeManager.regular,
      icon: Icon(
        CupertinoIcons.phone_solid,
        color: ColorManager.themeColor,
      ),
    );
  }

  Widget emailIcon() {
    return IconButton(
      onPressed: null,
      iconSize: IconSizeManager.regular,
      icon: SvgIcon(
        svgRes: AssetManager.svgFile(name: "email"),
        color: ColorManager.themeColor,
        fit: BoxFit.cover,
      ),
    );
  }

  bool isPhoneNumberOrPlus(String input) {
    final RegExp phoneRegExp = RegExp(r'^\+?\d+$');
    return phoneRegExp.hasMatch(input);
  }

  bool validatePhoneNumber(String phoneNumber) {
    final String number = phoneNumber.trim();
    // Define the regex pattern for a phone number
    RegExp regExp = RegExp(r'^\d{11,14}$');
    // Check if the input matches the regex pattern
    bool is11 = number.length == 11 && !number.contains("+");
    bool is14 = number.length == 14 && number.startsWith("+234");
    bool is13 = number.length == 13 && number.startsWith("234");
    bool is12 = number.length == 12;
    return (regExp.hasMatch(number) || is11 || is14) && !is13 && !is12;
  }

  Future<void> next() async {
    LoginData.clear();
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await AppStorage.clear();
    ref.read(clientProvider.notifier).state = null;

    if (!formKey.currentState!.validate()) {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      return;
    }

    formKey.currentState!.save();
    final response = await (LoginData.email != null
        ? AuthenticationRepo.loginUserEmail(
            email: LoginData.email!, password: LoginData.password!)
        : AuthenticationRepo.loginUserPhone(
            phoneNumber: LoginData.phoneNumber!,
            password: LoginData.password!));
    log("Logged In");
    debugPrint("login:${response.body}");

    if (response.error) {
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      setState(() => errorText = "*${response.messageBody!["message"]}");
    } else {
      /// ok now we logged in.
      /// But there's still a slight problem :(
      /// in some cases, users may have registered accounts
      /// but may not have created it completely & successfully
      /// so as an anointed developer, i should check that and then
      /// redirect to the other data page if possible
      setState(() => errorText = null);
      Map<dynamic, dynamic> map = response.messageBody!["data"];

      if ((map["firstName"]?.toString().trim().isEmpty ?? true) ||
          map["userImage"] == null ||
          map["transactionPin"] == null) {
        /// then user did not complete registration

        /// email and password were already collected at the beginning when validating :)
        LoginData.id = map["_id"];
        LoginData.email = map["email"];
        LoginData.phoneNumber = map["phoneNumber"];
        LoginData.transactionPin = map["transactionPin"];
        // if (map["userImage"] != null) {
        //   LoginData.profile = map["userImage"];
        // }
        if (map["firstName"] == null ||
            map["firstName"].toString().trim().isEmpty) {
          // If secondary details like firstName were not setup when logging in.
          // Clients will be asked to verify OTP first.

          final response =
              await AuthenticationRepo.resendOTP(userId: LoginData.id!);
          log(response.body);
          if (response.error) {
            ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
            SnackbarManager.showErrorSnackbar(
                context: context,
                message: "Error logging in. Try again later.");
            return;
          }

          OtpData.id = map["_id"];
          OtpData.email = LoginData.email;
          OtpData.phoneNumber = map["phoneNumber"];
          LoginData.otp = response.messageBody?["otp"];
          final verified =
              (await Navigator.pushNamed(context, Routes.otpRoute) as bool? ??
                  false);
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
          if (verified) {
            OtpData.clear();
            Navigator.pushReplacementNamed(context, Routes.setupAccountRoute);
            return;
          }
          return;
        }
        // if (map["userImage"] == null) {
        //
        //   LoginData.initializeFromClient(client: Client.fromJson(json: map));
        //   Navigator.pushNamed(context, Routes.addProfileRoute);
        //   return;
        // }
        if (map["transactionPin"] == null) {
          LoginData.initializeFromClient(client: Client.fromJson(json: map));
          Navigator.pushNamed(context, Routes.addTransactionPinRoute);
          return;
        }
        LoginData.initializeFromClient(client: Client.fromJson(json: map));

        Navigator.pushNamed(context, Routes.setupAccountRoute);

        return;
      }

      map["id"] = map["_id"];
      map["password"] = LoginData.password;
      // We have to remove the "_v" key. Although not compulsory.
      map.remove("__v");
      // map.remove("password");
      map.remove("groups");
      await AppStorage.clear();

      AppStorage.saveSettings(
          settings: Settings.fromJson(map: {
        "two-factor-enabled": map["two_factor_auth"],
        "two-factor-method": map["two_fctor_type"] == "None"
            ? "otp"
            : map["two_fctor_type"].toString().toLowerCase().contains("pin")
                ? "pin"
                : "otp",
        "app-entry-method": "pin",
        "auto-logout": true,
      }));
      final settings = AppStorage.getSettings();

      if (!settings.twoFactorEnabled) {
        save(map: map);
        return;
      }

      // If Two-Factor is OTP
      if (settings.twoFactorMethod == TwoFactorMethod.Otp) {
        /// The otp screen only returns true after verifying.
        OtpData.id = map["_id"];
        OtpData.email = LoginData.email;
        OtpData.phoneNumber = map["phoneNumber"];
        LoginData.otp = map["verificationPin"];

        final verified =
            (await Navigator.pushNamed(context, Routes.otpRoute) as bool?) ??
                false;

        if (!verified) {
          AppStorage.clear();
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
          return;
        }
      }

      if (settings.twoFactorMethod == TwoFactorMethod.Pin) {
        final correctPin =
            (await TransactionPinSheet.bottomSheet(context: context)) ?? false;

        if (!correctPin) {
          AppStorage.clear();
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
          return;
        }
      }

      save(map: map);
    }
  }

  Future<void> saveFriends() async {
    final friends = await FriendRepository().getFriends();
    AppStorage.saveFriends(friends: friends);
  }

  Future<void> saveCustomerCare() async {
    if (AppStorage.getCustomerCareSessionId() == null) {
      AppStorage.saveCustomerCareChats(chats: []);
      final response = await CustomerCareRepository.createChatSession(
          id: ClientProvider.readOnlyClient!.userId);
      log(response.body);
      if (!response.error) {
        final id = response.messageBody!["chatSession"]["_id"].toString();
        log(id);

        AppStorage.saveCustomerCareSessionId(sessionId: id);
        // We are saving a preset customer care chat for the intro.
        final result = await CustomerCareRepository.sendIntroCustomerCareChat(
            customerCareId: response.messageBody!["chatSession"]
                ["customerCare"],
            sessionId: id);

        log(result.body);
        return;
      }

      throw Exception(response.messageBody?["message"] ??
          "Error when saving customer care");
    }
  }

  Future<void> saveGroups({required final String userId}) async {
    final newResponse = await GroupRepo.getGroupsOneTime();

    if (newResponse.error) {
      // We have to clear all progress done in saving any data to cache.
      await AppStorage.clear();
      debugPrint(newResponse.body.toString());
      throw Exception(newResponse.messageBody?["message"] ?? "");
    }

    final List? data = newResponse.messageBody!["data"];
    debugPrint(data.toString());
    AppStorage.saveGroups(
        groups: ((data ?? [])).map((e) => Group.fromJson(json: e)).toList());
    List groups = data ?? [];

    for (final group in groups) {
      AppStorage.saveChats(
          chats: ((group["messages"] ?? []) as List)
              .map((e) => Chat.fromJson(json: e))
              .toList(),
          groupId: group["_id"]);
    }
  }

  /// User data must have been saved in Cache
  Future<void> saveTransactions() async {
    ref.read(transacionRepoProvider.notifier).state = TransactionRepo();
    final transactions = await TransactionRepo().getTransactions();
    AppStorage.saveTransactions(transactions: transactions);
  }

  Future<void> saveReferrals() async {
    ref.read(walletProvider.notifier).state = WalletRepository();
    final referrals = await WalletRepository().getReferrals();
    AppStorage.saveReferrals(referrals: referrals);
  }

  Future<void> saveWalletHistory() async {
    final walletHistory = await WalletRepository().getWalletHistory();
    AppStorage.saveWalletTransactions(walletTransactions: walletHistory);
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
                  "Login to account",
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

  Widget dontHaveAccount() {
    final defaultStyle = TextStyle(
        color: ColorManager.primary,
        fontSize: FontSizeManager.medium * 1.05,
        fontFamily: 'Lato',
        fontWeight: FontWeightManager.semibold);
    final highlightStyle = defaultStyle.copyWith(
      color: ColorManager.themeColor,
    );
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(style: defaultStyle, children: [
          const TextSpan(text: "Don't Have Account? "),
          TextSpan(
              text: "Register",
              style: highlightStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.pushReplacementNamed(
                    context, Routes.registerRoute))
        ]));
  }

  Future<void> navigate() async {
    final friendsProviderRefresh = ref.refresh(friendsProvider);
    final groupsProviderRefresh = ref.refresh(groupRepoProvider);
    final transactionsProviderRefresh = ref.refresh(transacionRepoProvider);
    final friendListRefresh = ref.refresh(friendsListProvider);
    final transactionsRefresh = ref.refresh(transactionsStreamProvider);
    final groupsRefresh = ref.refresh(groupsStreamProvider);

    ref.watch(homeProvider.notifier).state = 0;
    Navigator.pushNamedAndRemoveUntil(
        context, Routes.homeRoute, (route) => false);
  }

  Future<void> save({required final Map<dynamic, dynamic> map}) async {
    // We have to save user data first

    AppStorage.saveClient(client: Client.fromJson(json: map));
    ClientProvider.saveUserData(ref: ref, json: map);
    ref.watch(clientProvider.notifier).state = ClientProvider.readOnlyClient;

    if (map["kycTier"] < map["kyccurrentTier"]) {
      //To save kyc status, if currently verifying or not.
      AppStorage.savekycVerificationStatus(
          tier: KycConverter.convertToEnum(
              tier: map["kyccurrentTier"].toString()));
    } else {
      AppStorage.savekycVerificationStatus(tier: VerificationTier.None);
    }

    // To simultaneously save data. A way of preventing cummilated latency.
    await Future.wait([
      saveTransactions(),
      saveGroups(userId: map["_id"]),
      saveFriends(),
      saveCustomerCare(),
      saveWalletHistory(),
      saveReferrals()
    ], eagerError: true)
        .onError<Exception>(
      (error, stackTrace) {
        SnackbarManager.showErrorSnackbar(
            context: context, message: "Error occurred when logging in.");
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
        return [];
      },
    ).then(
      (value) {
        navigate();
      },
    );
  }
}
