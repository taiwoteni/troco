import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/settings/data/sources/preset-settings.dart';
import 'package:troco/features/settings/presentation/settings-page/widget/settings-header-clipper.dart';
import 'package:troco/features/settings/presentation/settings-page/widget/settings-tile-widget.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
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
            appBar(),
            smallSpacer(),
            settingsList(),
            const Gap(SizeManager.bottomBarHeight)
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return ClipPath(
      clipper: SettingsHeaderClipper(),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height / 3.5 +
            MediaQuery.of(context).viewPadding.top +
            SizeManager.large,
        color: ColorManager.tertiary,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: MediaQuery.of(context).viewPadding.top +
                  SizeManager.regular * 1.3,
              child: settingsText(),
            ),
            Positioned(
                child: ProfileIcon(
              url: ClientProvider.readOnlyClient!.profile,
              size: IconSizeManager.extralarge * 1.2,
            )),
            Positioned(
              bottom:
                  MediaQuery.of(context).viewPadding.top + SizeManager.large,
              child: showDetailsText(),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsText() {
    return Text(
      "Settings",
      style: TextStyle(
          color: ColorManager.primary,
          fontFamily: "quicksand",
          fontSize: FontSizeManager.medium * 1.1,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget showDetailsText() {
    return Text(
      "Show Details",
      style: TextStyle(
          color: ColorManager.themeColor,
          fontFamily: "quicksand",
          fontSize: FontSizeManager.regular,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget settingsList() {
    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            SettingsTileWidget(setting: settings()[index]),
        separatorBuilder: (context, index) => Divider(
              indent: SizeManager.large,
              endIndent: SizeManager.large,
              thickness: 0.9,
              color: ColorManager.secondary.withOpacity(0.09),
            ),
        itemCount: settings().length);
  }
}
