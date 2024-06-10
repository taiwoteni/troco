import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/services/data/sources/preset-services.dart';
import 'package:troco/features/services/utils/clipper.dart';

import '../../../core/app/font-manager.dart';
import '../../../core/app/size-manager.dart';
import '../../settings/data/models/settings-model.dart';
import '../../settings/presentation/settings-page/widget/settings-tile-widget.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSettingsUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            header(),
            extraLargeSpacer(),
            servicesList(),
            const Gap(SizeManager.bottomBarHeight),
          ],
        ),
      ),
    );
  }

  Widget header() {
    final height = MediaQuery.sizeOf(context).height / 4 +
        MediaQuery.of(context).viewPadding.top;
    return SizedBox(
      width: double.maxFinite,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
              child: ClipPath(
            clipper: EscrowClipper(),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.purple.withOpacity(0.1),
                  Colors.purple.withOpacity(0.3),
                  Colors.purple.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
            ),
          )),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top +
                SizeManager.regular * 1.3,
            child: settingsText(),
          ),
          Positioned(
            bottom: SizeManager.regular,
            child: ProfileIcon(
              url: ClientProvider.readOnlyClient!.profile,
              size: IconSizeManager.extralarge * 1.55,
            ),
          )
        ],
      ),
    );
  }

  Widget settingsText() {
    return Text(
      "Escrow Services",
      style: TextStyle(
          color: ColorManager.primary,
          fontFamily: "quicksand",
          fontSize: FontSizeManager.medium * 1.1,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget servicesList() {
    final List<SettingsModel> settings = presetServices(context: context);
    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            SettingsTileWidget(setting: settings[index]),
        separatorBuilder: (context, index) => Divider(
              indent: SizeManager.large,
              endIndent: SizeManager.large,
              thickness: 0.9,
              color: ColorManager.secondary.withOpacity(0.09),
            ),
        itemCount: settings.length);
  }
}
