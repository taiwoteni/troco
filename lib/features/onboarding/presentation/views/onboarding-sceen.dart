import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/components/others/onboarding-indicator.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/onboarding/presentation/providers/onboarding-provider.dart';
import 'package:troco/features/onboarding/presentation/widgets/onboarding-item-widget.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/components/images/svg.dart';
import '../../data/datasources/onboarding-items-list.dart';

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
    // deleteUser();
    AppStorage.clear();
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getOnboardingUiOverlayStyle());
    });
  }

  Future<void> deleteUser() async {
    final result =
        await AuthenticationRepo.deleteUser(userId: "66151e93e4d870dc1782e4b2");
    print(result.body);
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
                  return OnboardingItemWidget(onboardingItem: onboardingItem);
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
