import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/size-manager.dart';

/// The [smallSpacer] is the smallest spacer.
/// It often gives spacing of 4.0 pixels
Widget smallSpacer(){
  return const Gap(SizeManager.small);
} 

/// The [regularSpacer] is the second to the smallest spacer.
/// It often gives spacing of 8.0 pixels
Widget regularSpacer(){
  return const Gap(SizeManager.regular);
}

/// The [mediumSpacer] is the medium spacer.
/// It often gives spacing of 16.0 pixels
Widget mediumSpacer(){
  return const Gap(SizeManager.medium);
}

/// The [largeSpacer] is the second to the largest spacer.
/// It often gives spacing of 20.0 pixels
Widget largeSpacer(){
  return const Gap(SizeManager.large);
}

/// The [extraLargeSpacer] is the largest spacer.
/// It often gives spacing of 32.0 pixels
Widget extraLargeSpacer(){
  return const Gap(SizeManager.extralarge);
}