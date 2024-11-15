import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/core/extensions/string-extension.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../data/models/virtual-document.dart';
import '../../../domain/entities/sales-item.dart';

class ProofOfWorkVirtualWidget extends StatefulWidget {
  final VirtualDocument document;
  const ProofOfWorkVirtualWidget({super.key, required this.document});

  @override
  State<ProofOfWorkVirtualWidget> createState() => _ProofOfWorkWidgetState();
}

class _ProofOfWorkWidgetState extends State<ProofOfWorkVirtualWidget> {
  late VirtualDocument document;

  @override
  void initState() {
    document = widget.document;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () {
        final link = document.source;
        FlutterClipboard.copy(link);
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
                  document.taskName.ellipsize(20),
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.primary,
                      fontSize: FontSizeManager.regular * .8,
                      fontWeight: FontWeightManager.semibold),
                ),
                smallSpacer(),
                Text(
                  "View ${document.type == VirtualDocumentType.File ? "file" : "link"} uploaded by seller.",
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
