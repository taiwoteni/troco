import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:troco/core/app/legal-file-extractor.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/features/about%20us/presentation/widgets/fade-slide-in-widget.dart';

import '../../features/about us/utils/enums.dart';
import '../components/others/spacer.dart';
import 'color-manager.dart';
import 'font-manager.dart';

enum Extension { png, jpeg, jpg, webp }

class AssetManager {
  /// [iconFile] is used for getting the a particular icon from the asset directory.
  static String iconFile({required String name}) {
    return "assets/icons/$name.png";
  }

  /// [svgFile] is used for getting the a particular image from the asset directory.
  static String svgFile({required String name}) {
    return "assets/icons/$name.svg";
  }

  /// [imageFile] is used for getting the a particular image from the asset directory.
  static String imageFile(
      {required final String name, final Extension ext = Extension.png}) {
    return "assets/images/$name.${ext.name}";
  }

  /// [lottieFile] is used for getting the a particular lottie from the asset directory.
  static String lottieFile({required String name}) {
    return "assets/lottie/$name.json";
  }

  /// [audioFile] is used for getting the a particular audio from the asset directory.
  static String audioFile({required String name}) {
    return "assets/audio/$name.mp3";
  }

  static Future<List<Widget>> getLegalDisplay(
      {required String type, required final BuildContext context}) async {
    final path = 'assets/legal/$type.troco-legal';

    final readFile = await rootBundle.loadString(path);

    final parts = readFile.split(RegExp(r'(\r?\n){5}'));
    debugPrint("Parts are: ${parts.length}");

    final results = parts.map((part) {
      final index = parts.indexOf(part);
      final titlePart = index == 0;
      final subParts = part.split(RegExp(r'(\r?\n){3}'));
      debugPrint("Sub-Parts are: ${subParts.length}");

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (titlePart) ...[
            extraLargeSpacer(),
            _back(context: context),
            mediumSpacer(),
          ],
          ...subParts.map(
            (e) => FadeSlideWidget(
                delay: const Duration(seconds: 3),
                mustBeVisible: true,
                direction: getDirection(index),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: SizeManager.large),
                  child: subParts.indexOf(e) == 0
                      ? _title(text: e, type: titlePart ? type : null)
                      : _content(text: e),
                )),
          )
        ],
      );
    });

    return results.toList();
  }

  static SlideDirection getDirection(int no) {
    final dir = no % 4;

    switch (dir) {
      case 0:
        return SlideDirection.up;
      case 1:
        return SlideDirection.left;
      case 2:
        return SlideDirection.right;
      default:
        return SlideDirection.down;
    }
  }

  static Widget _title({required final String text, final String? type}) {
    if (type != null) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              text,
              textAlign: TextAlign.left,
              softWrap: true,
              style: TextStyle(
                  color: ColorManager.accentColor,
                  fontFamily: 'lato',
                  fontSize: FontSizeManager.large * 1.2,
                  fontWeight: FontWeightManager.extrabold),
            ),
            mediumSpacer(),
            SvgIcon(
              svgRes: AssetManager.svgFile(name: '$type-icon'),
              size: const Size.square(IconSizeManager.medium),
              color: ColorManager.accentColor,
            )
          ],
        ),
      );
    }
    return Text(
      text,
      textAlign: TextAlign.left,
      softWrap: true,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  static Widget _back({required BuildContext context}) {
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

  static Widget _content({required final String text}) {
    final style = TextStyle(
        color: ColorManager.primary,
        fontFamily: 'lato',
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.regular);
    final decodedWidget =
        LegalFileExtractor.decodeString(source: text, style: style);
    return RichText(text: decodedWidget);
  }
}
