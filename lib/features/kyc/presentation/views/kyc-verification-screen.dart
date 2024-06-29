import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/kyc/domain/repository/kyc-repository.dart';
import 'package:troco/features/kyc/presentation/widgets/verification-requirement-widget.dart';
import 'package:troco/features/kyc/utils/kyc-converter.dart';
import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../core/components/button/presentation/widget/button.dart';
import '../../../../core/components/images/svg.dart';
import '../../../auth/presentation/providers/client-provider.dart';
import '../../utils/enums.dart';

class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen>
    with TickerProviderStateMixin {
  late final TabController tabController;
  final buttonKey = UniqueKey();
  bool verified = false;
  int index = 0;
  String? path;
  late VerificationTier tier;
  VerificationTier? addedTier, uploadingTier, verifyingTier;
  double minPerfectScreenWidth = 346.0;

  @override
  void initState() {
    tier = ClientProvider.readOnlyClient!.kycTier;
    tabController = TabController(length: 3, vsync: this);
    final currentVerifyTier = AppStorage.getkycVerificationStatus();
    if (currentVerifyTier != VerificationTier.None) {
      verifyingTier = currentVerifyTier;
    }
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: PopScope(
        canPop: uploadingTier == null,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
          width: double.maxFinite,
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                extraLargeSpacer(),
                back(),
                mediumSpacer(),
                title(),
                mediumSpacer(),
                label(),
                extraLargeSpacer(),
                chooseVerificationTier(),
                largeSpacer(),
                tiers(),
                largeSpacer(),
                regularSpacer(),
                column(),
                largeSpacer(),
                button(),
                extraLargeSpacer(),
              ],
            ),
          ),
        ),
      ),
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

  Widget tiers() {
    return TabBar(
      controller: tabController,
      tabs: const [
        Tab(
          text: "Tier 1",
        ),
        Tab(
          text: "Tier 2",
        ),
        Tab(
          text: "Tier 3",
        )
      ],
      onTap: (value) => setState(() => index = value),
      dividerHeight: 0,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicatorColor: ColorManager.accentColor,
      indicatorWeight: SizeManager.small * 1.4,
      indicatorPadding: const EdgeInsets.symmetric(vertical: SizeManager.small),
      labelStyle: TextStyle(
          color: ColorManager.primary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium * 0.9,
          fontWeight: FontWeightManager.semibold),
      unselectedLabelStyle: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium * 0.9,
          fontWeight: FontWeightManager.medium),
    );
  }

  Widget title() {
    return Text(
      "Proof Of Identity",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget label() {
    return Text(
      "Inorder to verify your proof of identity,\nPlease choose any of the verification tiers below.\n" +
          "And attached the required document",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'lato',
          fontSize: FontSizeManager.small * 1.1,
          fontWeight: FontWeightManager.regular),
    );
  }

  Widget chooseVerificationTier() {
    return Text(
      "Choose your verification tier",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'lato',
          fontSize: FontSizeManager.small * 1.1,
          fontWeight: FontWeightManager.regular),
    );
  }

  List<VerificationRequirementWidget> requirements() {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth >= minPerfectScreenWidth
        ? 1
        : screenWidth / minPerfectScreenWidth * 0.9);
    return [
      VerificationRequirementWidget(
        title: "Upload Formal Picture",
        met: tier != VerificationTier.None,
        process: getProcessValue(tier: VerificationTier.Tier1),
        onTap: () => pickDocument(tier: VerificationTier.Tier1),
        description:
            "Informal, Illicit or\nAI-generated images are NOT accepted.",
        icon: Transform.scale(
          scale: scale.toDouble(),
          child: SvgIcon(
            svgRes: AssetManager.svgFile(name: "upload-photo"),
            size: Size.square(IconSizeManager.extralarge * (scale.toDouble())),
          ),
        ),
      ),
      VerificationRequirementWidget(
        title: "Identity Document",
        process: getProcessValue(tier: VerificationTier.Tier2),
        onTap: () => pickDocument(tier: VerificationTier.Tier2),
        met: [VerificationTier.Tier2, VerificationTier.Tier3].contains(tier),
        description:
            "ONLY National ID Card,\nDriver's Licence,\nVoter's card or Passport IS accepted.",
        size: IconSizeManager.large,
        icon: Transform.scale(
          scale: scale.toDouble(),
          child: SvgIcon(
            svgRes: AssetManager.svgFile(name: "identity-document"),
            size: Size.square(IconSizeManager.large * scale.toDouble()),
          ),
        ),
      ),
      VerificationRequirementWidget(
        title: "Verify Residential Address",
        process: getProcessValue(tier: VerificationTier.Tier3),
        onTap: () => pickDocument(tier: VerificationTier.Tier3),
        met: tier == VerificationTier.Tier3,
        description:
            "Submit your CURRENT NEPA Bill\nfor residential verification.",
        icon: Transform.scale(
          scale: scale.toDouble(),
          child: SvgIcon(
            svgRes: AssetManager.svgFile(name: "residential-address"),
            size: Size.square(IconSizeManager.extralarge * scale.toDouble()),
          ),
        ),
      ),
    ];
  }

  VerificationProcess? getProcessValue({required VerificationTier tier}) {
    return (addedTier ?? VerificationTier.None) == tier
        ? ((uploadingTier ?? VerificationTier.None) == tier
            ? VerificationProcess.Uploading
            : VerificationProcess.Added)
        : (uploadingTier ?? VerificationTier.None) == tier
            ? VerificationProcess.Uploading
            : (verifyingTier ?? VerificationTier.None) == tier
                ? VerificationProcess.Processing
                : null;
  }

  Widget column() {
    return Column(
      children: [
        ...requirements().map(
          (requirementWidget) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [requirementWidget, largeSpacer()],
            );
          },
        ).take(index + 1)
      ],
    );
  }

  Widget button() {
    return CustomButton(
      usesProvider: true,
      buttonKey: buttonKey,
      onPressed: verify,
      label: "Verify",
    );
  }

  Future<void> pickDocument({required final VerificationTier tier}) async {
    final currentTierLevel =
        int.parse(KycConverter.convertToStringApi(tier: this.tier));
    final selectedTierLevel =
        int.parse(KycConverter.convertToStringApi(tier: tier));

    // If user is trying to verify with a lower or same tier
    if (selectedTierLevel <= currentTierLevel) {
      return;
    }
    // If the user is trying to select a tier when a tier is still being
    // verified by admin or select a tier when uploading a tier
    if (verifyingTier != null || uploadingTier != null) {
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "A tier is currently being uploaded or verified");
      return;
    }

    // If the user is trying to skip an immediate tier
    if (selectedTierLevel >= currentTierLevel + 2) {
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Verify an immediate tier. Do not skip");
      return;
    }

    if (addedTier != null) {
      SnackbarManager.showBasicSnackbar(
          context: context,
          mode: ContentType.failure,
          message: "Can only be verified one stage at a time");
      return;
    }
    final file = await FileManager.pickImage(imageSource: ImageSource.gallery);

    if (file != null) {
      setState(() {
        path = file.path;
        addedTier = tier;
      });
      ButtonProvider.enable(buttonKey: buttonKey, ref: ref);
    }
  }

  Future<void> verify() async {
    final selectedTier = addedTier!;
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));

    setState(() => uploadingTier = selectedTier);
    final response = await KycRepository.verifyKyc(
      tier: selectedTier,
      bill: selectedTier == VerificationTier.Tier3 ? path! : null,
      photo: selectedTier == VerificationTier.Tier1 ? path! : null,
      document: selectedTier == VerificationTier.Tier2 ? path! : null,
    );
    log(response.body);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    setState(() => uploadingTier = null);

    if (!response.error) {
      setState(() {
        addedTier == null;
        verifyingTier = selectedTier;
      });
      SnackbarManager.showBasicSnackbar(
          context: context, message: "Submission Successful.");
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
      AppStorage.savekycVerificationStatus(tier: selectedTier);
    }
  }
}
