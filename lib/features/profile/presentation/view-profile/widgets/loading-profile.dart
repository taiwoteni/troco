import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/features/groups/presentation/collections_page/widgets/empty-screen.dart';

class LoadingProfile extends StatelessWidget {
  final String firstName;
  const LoadingProfile({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return EmptyScreen(
      lottie: AssetManager.lottieFile(name: "loading"),
      lottieColor: ColorManager.accentColor,
      label: "Loading $firstName's Profile",
      xIndex: 0,
      expanded: false,
      forward: true,
    );
  }
}
