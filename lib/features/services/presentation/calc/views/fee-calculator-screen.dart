import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/services/presentation/calc/provider/fee-provider.dart';
import 'package:troco/features/services/presentation/calc/widgets/fee-calculation-page.dart';
import 'package:troco/features/services/presentation/calc/widgets/select-category-page.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';

class FeeCalculatorScreen extends ConsumerStatefulWidget {
  const FeeCalculatorScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeeCalculatorState();
}

class _FeeCalculatorState extends ConsumerState<FeeCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            extraLargeSpacer(),
            back(),
            mediumSpacer(),
            title(),
            largeSpacer(),
            pageView(),
          ],
        ),
      ),
    );
  }

  Widget pageView() {
    return Container(
      constraints: BoxConstraints.loose(const Size.fromHeight(607)),
      child: PageView(
        controller: ref.watch(feePageViewProvider),
        physics: const NeverScrollableScrollPhysics(),
        children: const [SelectCategoryPage(), FeeCalculationPage()],
      ),
    );
  }

  Widget title() {
    return Text(
      "Fee Calculator",
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
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
}
