import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/data/datasources/create-transaction-stages.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/create-transaction-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/basecomponents/images/svg.dart';


class CreateTransactionScreen extends ConsumerStatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends ConsumerState<CreateTransactionScreen> {
  int get currentStage => ref.watch(createTransactionProgressProvider);

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getTransactionScreenUiOverlayStyle());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Scaffold(
        backgroundColor: ColorManager.background,
        resizeToAvoidBottomInset: false,
        appBar: appBar(),
        body: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Column(
              children: [
                stages2(),
                Divider(
                  height: 1,
                  color: ColorManager.secondary.withOpacity(0.09),
                ),
                Expanded(
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: ref.watch(createTransactionPageController),
                    physics: const NeverScrollableScrollPhysics(),
                    children: ref.watch(createTransactionStagesProvider),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget stages2() {
    return Padding(
      padding: const EdgeInsets.only(top: SizeManager.medium * 1.5),
      child: SizedBox(
          width: double.maxFinite,

          /// DO NOT TOUCH THIS VALUE,
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...createTransactionStages(ref: ref)
                  .map((e) => Expanded(child: e))
                  .toList()
            ],
          )),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Create Transaction",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
