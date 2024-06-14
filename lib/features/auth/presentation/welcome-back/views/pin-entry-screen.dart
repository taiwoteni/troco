import 'package:flutter/material.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/auth/presentation/welcome-back/widgets/pin-keypad-widget.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: ColorManager.themeColor,
      child: Column(
        children: [
          keyPad(),
        ],
      ),
    );
  }

  Widget keyPad(){
    return GridView(
      gridDelegate: keyPadDelegate(),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: false,
      children: List.generate(
        10,
        (index) => PinKeypadWidget(text: index.toString()),),
      );
  }

  SliverGridDelegateWithFixedCrossAxisCount keyPadDelegate(){
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: SizeManager.medium,
      mainAxisSpacing: SizeManager.medium,
      );
  }
}