import 'dart:io';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/font-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/custom-views/profile-icon.dart';
import 'package:troco/custom-views/spacer.dart';
import 'package:troco/models/transaction.dart';
import 'package:troco/providers/client-provider.dart';

class ChatContactWidget extends StatelessWidget {
  final Transaction transaction;
  const ChatContactWidget({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    Color color = ColorManager.accentColor;

    final messageStyle = TextStyle(
        color: color,
        fontFamily: 'Quicksand',
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.regular);

    return ClipRRect(
      borderRadius: BorderRadius.circular(SizeManager.medium),
      child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeManager.medium),
            // gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       color.withOpacity(0.8),
            //       color.withOpacity(0.9),
            //     ]),
          ),
          child: ListTile(
              dense: true,
              tileColor: Colors.transparent,
              contentPadding: const EdgeInsets.only(
                left: SizeManager.medium,
                right: SizeManager.medium,
                top: SizeManager.small,
                bottom: SizeManager.small,
              ),
              horizontalTitleGap: SizeManager.medium * 0.8,
              title: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        transaction.transactionDetail,
                        overflow: TextOverflow.ellipsis,
                      ),
                      regularSpacer(),
                      Text(
                        '•',
                        style: TextStyle(
                            color: ColorManager.secondary,
                            fontSize: FontSizeManager.small * 0.5),
                      ),
                      regularSpacer(),
                      Text(
                        'pending',
                        style: TextStyle(
                            color: ColorManager.secondary,
                            fontFamily: 'Quicksand',
                            fontSize: FontSizeManager.small,
                            fontWeight: FontWeightManager.regular),
                      )
                    ],
                  ),
                  const Gap(SizeManager.regular * 1.1),
                ],
              ),
              titleTextStyle: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: ColorManager.primary,
                  fontFamily: 'Lato',
                  fontSize: FontSizeManager.medium * 1.1,
                  fontWeight: FontWeightManager.semibold),
              subtitle: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(style: messageStyle, children: [
                    TextSpan(
                        text: "Buyer: ",
                        style: messageStyle.copyWith(
                            fontWeight: FontWeightManager.semibold)),
                    const TextSpan(text: "So we agree to drop of at Maruwa?"),
                  ])),
              leading: Consumer(builder: (context, ref, child) {
                return ProfileIcon(
                    size: 50,
                    profile: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(
                            ref.read(ClientProvider.userProvider)!.profile))));
              }),
              // leading: Container(
              //   width: 70,
              //   height: 70,
              //   alignment: Alignment.center,
              //   decoration: BoxDecoration(
              //       shape: BoxShape.circle, color: color.withOpacity(0.2)),
              //   child: SvgIcon(
              //     svgRes: AssetManager.svgFile(name: "group"),
              //     color: color,
              //     size: const Size.square(IconSizeManager.regular),
              //   ),
              // ),
              trailing: Container(
                height: 25,
                width: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  "5",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato',
                      fontSize: FontSizeManager.medium * 0.7,
                      fontWeight: FontWeightManager.extrabold),
                ),
              ))),
    );
  }
}
