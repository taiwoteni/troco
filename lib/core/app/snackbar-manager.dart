import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:troco/core/app/color-manager.dart';

class SnackbarManager {
  static void showBasicSnackbar({
    required final BuildContext context,
    final bool accentMode = true,
    final ContentType? mode,
    final String header = " Troco",
    required final String message,
    int seconds = 2,
  }) async {
    final snackbar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.startToEnd,
      content: AwesomeSnackbarContent(
        inMaterialBanner: true,
        title: header,
        message: message,
        contentType: mode ?? ContentType.success,
        color: (mode ?? ContentType.success) == ContentType.success
            ? ColorManager.accentColor
            : null,
      ),

      // content: Text(
      //   message,
      //   style: TextStyle(
      //     fontFamily: "Lato",
      //     color: accentMode ? ColorManager.primaryDark : ColorManager.primary,
      //     fontSize: FontSizeManager.medium * 0.8,
      //     fontWeight: FontWeightManager.medium,
      //   ),
      // ),
      // dismissDirection: DismissDirection.startToEnd,
      // shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(SizeManager.regular * 1.8)),
      // elevation: 1.5,
      // margin: const EdgeInsets.symmetric(
      //     horizontal: SizeManager.regular, vertical: SizeManager.medium),
      // padding: const EdgeInsets.symmetric(
      //     horizontal: SizeManager.medium * 1.2, vertical: SizeManager.medium),
      // backgroundColor:
      //     accentMode ? ColorManager.accentColor : ColorManager.background,
      duration: Duration(seconds: seconds),
    );
    final s = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (context.mounted) {
      s.showSnackBar(snackbar);
    }
  }

  static void showErrorSnackbar({
    required final BuildContext context,
    final String header = " Troco",
    required final String message,
    int seconds = 2,
  }) async {
    final snackbar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      dismissDirection: DismissDirection.startToEnd,
      content: AwesomeSnackbarContent(
        inMaterialBanner: true,
        title: header,
        message: message,
        contentType: ContentType.failure,
        color: null,
      ),
      duration: Duration(seconds: seconds),
    );
    final s = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (context.mounted) {
      s.showSnackBar(snackbar);
    }
  }
}
