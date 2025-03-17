import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/dialog-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/transactions/data/datasources/create-transaction-stages.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/create-transaction-provider.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/transaction-controller-provider.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/ction-screen-provider.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/images/svg.dart';
import '../../../data/models/draft.dart';

class CreateTransactionScreen extends ConsumerStatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState
    extends ConsumerState<CreateTransactionScreen> {
  int get currentStage => ref.watch(createTransactionProgressProvider);

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ref.read(popTransactionScreen.notifier).state = false;
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getTransactionScreenUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: (TransactionDataHolder.isEditing ?? false) ||
          ref.watch(popTransactionScreen),
      onPopInvoked: (didPop) {
        if (!didPop) {
          handlePop();
        }
      },
      child: Padding(
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
                      controller: ref.watch(transactionPageController),
                      physics: const NeverScrollableScrollPhysics(),
                      children: ref.watch(createTransactionStagesProvider),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Future<void> handlePop() async {
    if (ref.watch(transactionPageController).page != 0) {
      ref.read(transactionPageController.notifier).moveBack();
      return;
    }

    await showDraftDialog();
    return;
  }

  Future<void> showDraftDialog() async {
    final dialogManager = DialogManager(context: context);
    final shouldSave = await dialogManager.showDialogContent<bool?>(
      title: "Save Draft",
      icon: Transform.scale(
        scale: 1.5,
        child: LottieWidget(
            lottieRes: AssetManager.lottieFile(name: "empty"),
            size: const Size.square(60)),
      ),
      description: "Do you want to save these details as temporary draft?",
      okLabel: "Save",
      cancelLabel: "Don't Save",
      onCancel: () => context.pop(result: false),
      onOk: () => context.pop(result: true),
    );

    if (shouldSave == null) {
      AppStorage.addDraft(
          draft: Draft.fromJson(json: TransactionDataHolder.toJson()));
      return;
    }

    ref.watch(popTransactionScreen.notifier).state = true;
    if (!shouldSave) {
      TransactionDataHolder.clear(ref: ref);
    }
    context.pop();
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
                  onPressed: () => handlePop(),
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
                  TransactionDataHolder.isEditing == true
                      ? "Edit Transaction"
                      : "Create Transaction",
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
