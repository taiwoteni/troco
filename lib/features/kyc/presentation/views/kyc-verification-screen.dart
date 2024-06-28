import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/kyc/presentation/widgets/verification-requirement-widget.dart';
import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../core/components/button/presentation/widget/button.dart';
import '../../../../core/components/images/svg.dart';
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
  VerificationTier? tier;
  double minPerfectScreenWidth = 346.0;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Container(
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
        met: tier != null,
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
        met: tier == null
            ? false
            : [VerificationTier.Tier2, VerificationTier.Tier3].contains(tier!),
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
        met: tier == VerificationTier.Tier3,
        description:
            "Enter a VALID residential address\nfor proof of verification.",
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

  Future<void> verify() async {
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
  }
}
