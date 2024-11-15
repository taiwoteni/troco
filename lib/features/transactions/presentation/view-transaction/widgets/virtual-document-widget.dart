import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/extensions/string-extension.dart';
import 'package:troco/features/transactions/data/models/virtual-document.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';

class VirtualDocumentWidget extends StatefulWidget {
  final VirtualDocument document;

  /// [uploaded] specifies whether the document is currently being uploaded
  /// if [true], it shows an uploading animation,
  /// if false, show a pending animation
  /// if [null], it doesn't show the animation
  bool? uploaded;
  VirtualDocumentWidget({super.key, required this.document, this.uploaded});

  @override
  State<VirtualDocumentWidget> createState() => _VirtualDocumentWidgetState();
}

class _VirtualDocumentWidgetState extends State<VirtualDocumentWidget> {
  late VirtualDocument virtualDocument;

  @override
  void initState() {
    virtualDocument = widget.document;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(SizeManager.regular),
      splashColor: ColorManager.accentColor.withOpacity(0.1),
      onTap: () {},
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
                  virtualDocument.type == VirtualDocumentType.File
                      ? Path.basename(virtualDocument.source).ellipsize(30)
                      : "Link",
                  maxLines: 1,
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.primary,
                      overflow: TextOverflow.ellipsis,
                      fontSize: FontSizeManager.regular * .8,
                      fontWeight: FontWeightManager.semibold),
                ),
                smallSpacer(),
                Text(
                  virtualDocument.type == VirtualDocumentType.File
                      ? getFileDescriptionText()
                      : "Already uploaded link",
                  style: TextStyle(
                      fontFamily: "quicksand",
                      color: ColorManager.secondary,
                      fontSize: FontSizeManager.small * 0.8,
                      fontWeight: FontWeightManager.semibold),
                ),
              ],
            ),
            const Spacer(),
            Visibility(
              visible: widget.uploaded != null,
              child: Transform.scale(
                scale: widget.uploaded == true ? 1.1 : 1.25,
                child: LottieWidget(
                    lottieRes: AssetManager.lottieFile(
                        name: widget.uploaded == true
                            ? "verified"
                            : "kyc-uploading"),
                    size: const Size.square(IconSizeManager.large)),
              ),
            )
          ],
        ),
      ),
    );
  }

  String getFileDescriptionText() {
    final target = Path.basename(virtualDocument.source);
    if (target.toLowerCase().contains("credential")) {
      return "Access-Credentials Document";
    }
    if (target.toLowerCase().contains("information")) {
      return "Description Document";
    }
    return "File Document";
  }

  Widget productImage() {
    return LottieWidget(
        lottieRes: AssetManager.lottieFile(name: "document"),
        size: const Size.square(58));
  }
}
