import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/core/extensions/string-extension.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/download-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../domain/entities/sales-item.dart';

class ProofOfWorkWidget extends StatefulWidget {
  final SalesItem salesItem;
  const ProofOfWorkWidget({super.key, required this.salesItem});

  @override
  State<ProofOfWorkWidget> createState() => _ProofOfWorkWidgetState();
}

class _ProofOfWorkWidgetState extends State<ProofOfWorkWidget> {
  late SalesItem item;

  @override
  void initState() {
    item = widget.salesItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isVirtual = item is VirtualService;
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () async {
        final link = isVirtual
            ? (item as VirtualService).proofOfTask
            : (item as Service).proofOfTask;

        context.pushNamed(routeName: Routes.cardPaymentScreen, arguments: link);
      },
      child: Container(
        width: double.maxFinite,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
        decoration: BoxDecoration(
            color: ColorManager.background,
            border: Border.all(color: ColorManager.accentColor, width: 2),
            borderRadius: BorderRadius.circular(SizeManager.regular)),
        child: Row(
          children: [
            productImage(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.ellipsize(20),
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.primary,
                      fontSize: FontSizeManager.regular * .8,
                      fontWeight: FontWeightManager.semibold),
                ),
                smallSpacer(),
                Text(
                  "View ${isVirtual ? "document" : "work"} uploaded by ${isVirtual ? "seller" : "developer"}.",
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.secondary,
                      fontSize: FontSizeManager.small * 0.8,
                      fontWeight: FontWeightManager.semibold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget productImage() {
    return LottieWidget(
        lottieRes: AssetManager.lottieFile(name: "document"),
        size: const Size.square(58));
  }
}
