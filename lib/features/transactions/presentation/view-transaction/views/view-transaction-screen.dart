import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/core/basecomponents/others/drag-handle.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transaction-tab-index.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/rounded-tab-indicator.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/tab-item.dart';

class ViewTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;
  const ViewTransactionScreen({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewTransactionScreenState();
}

class _ViewTransactionScreenState extends ConsumerState<ViewTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Column(
        children: [
          appBar(),
          body(),
        ],
      ),
      extendBody: true,
    );
  }

  Widget appBar() {
    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.sizeOf(context).height * 0.35 +
          MediaQuery.viewPaddingOf(context).top,
      child: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              AssetManager.imageFile(
                  name: "product-image-demo", ext: Extension.jpg),
              width: double.maxFinite,
              height: double.maxFinite,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.1),
              Colors.transparent,
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.3),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
          Positioned(
              top: MediaQuery.viewPaddingOf(context).top / 2 +
                  SizeManager.regular,
              right: SizeManager.medium,
              left: SizeManager.medium,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: SvgIcon(
                        svgRes: AssetManager.svgFile(name: 'back'),
                        color: Colors.white,
                        size: const Size.square(IconSizeManager.medium * 1.1),
                      )),
                ],
              )),
          Positioned(
              left: SizeManager.medium,
              bottom: SizeManager.medium,
              child: productName())
        ],
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: FontSizeManager.medium, vertical: SizeManager.regular),
      child: Column(
        children: [
          regularSpacer(),
          const DragHandle(scale: 0.8),
          regularSpacer(),
          const Row(
            children: [
              CustomTabWidget(
                  isTransation: true,
                  isFirst: true,
                  description: "Overview..."),
              CustomTabWidget(
                  isTransation: false, description: "Delivering..."),
            ],
          ),
          smallSpacer(),
          RoundedTabIndicator(firstSelected: ref.watch(tabIndexProvider) == 0),
        ],
      ),
    );
  }

  Widget productName() {
    return const Text(
      "Mahanem UI/UX",
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.white,
          fontSize: FontSizeManager.medium,
          fontWeight: FontWeightManager.extrabold,
          fontFamily: 'quicksand'),
    );
  }
}
