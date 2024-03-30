import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/custom-views/onboarding-indicator.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/models/onboarding-item-model.dart';
import 'package:troco/providers/onboarding-provider.dart';

import '../../app/asset-manager.dart';
import '../../custom-views/svg.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController controller = PageController();
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getOnboardingUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: PageView(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (value) =>
                    ref.read(onboardingProvider.notifier).state = value,
                children: onboardingItemModels().map((onboardingItem) {
                  return Column(
                    children: [
                      // RATIO: 5:2
                      extraLargeSpacer(),
                      extraLargeSpacer(),
                      Expanded(
                          flex: 5,
                          child: Center(
                            child: Image.asset(
                              onboardingItem.imgRes,
                              width: IconSizeManager.extralarge * 4.5,
                              height: IconSizeManager.extralarge * 4.5,
                              fit: BoxFit.cover,
                            ),
                          )),
                      Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Text(
                                onboardingItem.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColorManager.themeColor,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeightManager.extrabold,
                                    fontSize:
                                        FontSizeManager.extralarge * 0.95),
                              ),
                              regularSpacer(),
                              Text(
                                onboardingItem.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    fontSize: FontSizeManager.medium * 0.96,
                                    color: ColorManager.secondary,
                                    fontWeight: FontWeightManager.medium),
                              )
                            ],
                          ))
                    ],
                  );
                }).toList(),
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: SizeManager.medium * 1.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                        onboardingItemModels().length,
                        (index) => OnboardingIndicator(
                            checked: ref.watch(onboardingProvider) == index)),
                  ],
                )),
            Positioned(
              bottom: SizeManager.medium,
              right: SizeManager.medium,
              child: IconButton(
                onPressed: () {
                  if (ref.watch(onboardingProvider) <
                      onboardingItemModels().length - 1) {
                    controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.ease);
                  } else {
                    Navigator.pushNamed(context, Routes.authRoute);
                  }
                },
                iconSize: 40,
                icon: SvgIcon(
                  angle: 135,
                  svgRes: AssetManager.svgFile(name: 'back'),
                  fit: BoxFit.cover,
                  color: ColorManager.themeColor,
                  size: const Size.square(40),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
