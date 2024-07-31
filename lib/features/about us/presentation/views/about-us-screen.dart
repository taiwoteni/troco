import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/features/about%20us/presentation/widgets/fade-slide-in-widget.dart';
import 'package:troco/features/about%20us/utils/enums.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';

class AboutUsScreen extends ConsumerStatefulWidget {
  const AboutUsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends ConsumerState<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SizedBox.expand(
        child: SingleChildScrollView(
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
              FadeSlideWidget(
                  delay: const Duration(seconds: 1),
                  direction: SlideDirection.up,
                  child: content(
                      text:
                          "We are the top mobile escrow app in Nigeria and the most trusted online escrow service.\nWithin the past several months, we have been the top firm in Nigeria to establish online escrow services. We are currently at the forefront of secure, dependable, and trustworthy escrow services, and we plan to expand into other African nations shortly.")),
              largeSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 3), child: trocoLimitied()),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 5),
                  child: content(
                      text:
                          "In Troco, We are :\n• Easy-to-use and secure online escrow for both buyers and sellers.\n• In accordance with the applicable state laws.\n• Equipped with a thorough understanding of the escrow procedure.\n• The most secure service to entrust your money.")),
              smallSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 6),
                  child: content(
                      text:
                          "Troco Limited, via its head office located opposite near Ibuzo Junction asaba, and its operating subsidiaries offer online escrow services that speed up and ease e-commerce by guaranteeing a safe settlement.\n\nThe act of providing online escrow services was invented as Troco Limited. Although it was not yet providing services online, the company was launched in 2018 and is now regarded as one of the top suppliers of secure online business and consumer transaction management, according to Trust National Finance. A team individuals who have been active in Nigeria interstate business scene over a couple of years ownership Troco Limited.\n\nInternet Escrow Services (Social Media) (IES Technologies), one of Troco Limitedited's operating business enterprises, is the exclusive provider of escrow services available on this platform. IES devices complies with all applicable trust legislation and is fully licensed and recognized as an escrow firm.")),
              largeSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 7),
                  direction: SlideDirection.left,
                  mustBeVisible: true,
                  child: header(text: "The Executives")),
              mediumSpacer(),
              FadeSlideWidget(
                  direction: SlideDirection.left,
                  delay: const Duration(seconds: 8),
                  mustBeVisible: true,
                  child: content(
                      text:
                          "The executive leadership team of Troco Limited is made up of seasoned experts that have led their companies in their fields and have a wealth of knowledge. Our leadership team is committed to carrying out the business's goal, upholding Troco Limited's distinctive and effective work environment, and making sure we provide our marketplaces and clients with excellent support.")),
              FadeSlideWidget(
                  delay: const Duration(seconds: 9),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mediumSpacer(),
                      subHeader(text: "Mr. Bonaventure Ibeh"),
                      regularSpacer(),
                      author(),
                      regularSpacer(),
                      content(
                          text:
                              "Business technology entrepreneur Bonaventure Ibeh studied Seo Marketing and information engineering and was an adjunct associate at the University of England Huddersfield's Department of ICT Institutions Afriserver. He spent five years teaching secure communication and then moved on to teach technology venture creation. More than three NG. patent applications are authored by him. In the past, he established a corporation as a director and Executive for writers.")
                    ],
                  )),
              FadeSlideWidget(
                  delay: const Duration(seconds: 10),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mediumSpacer(),
                      subHeader(text: "Mr. Nwoye Somto"),
                      regularSpacer(),
                      author(),
                      regularSpacer(),
                      content(
                          text:
                              "Nwoye Somto is a remarkable individual whose innovation and leadership has brought a significant revolution in the tech industry. He is one of the founding members of the esteemed Troco Technology Escrow Company. His adept skills in technology and his penchant for making a difference served as the building blocks towards the inception of this company. Troco Technology Escrow Company is well known for its function as a neutral third party, securing patents, technological software, and other intellectual property. Our team act as trusted partners, holding these critical assets under legal agreement, ensuring none of them are improperly used or infringed thereby ensuring we create a safe environment where technological contracts can be stored and protected professionally.")
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      "About Us",
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

  Widget header({required final String text}) {
    return Text(
      text,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          fontSize: FontSizeManager.large * 1.2,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget subHeader({required final String text}) {
    return Text(
      text,
      style: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'lato',
          decoration: TextDecoration.underline,
          decorationColor: ColorManager.accentColor,
          fontSize: FontSizeManager.large * 0.9,
          fontWeight: FontWeightManager.bold),
    );
  }

  Widget content({required final String text}) {
    return Text(text,
        style: TextStyle(
            color: ColorManager.primary,
            fontFamily: 'lato',
            fontSize: FontSizeManager.regular,
            fontWeight: FontWeightManager.regular));
  }

  Widget trocoLimitied() {
    return Row(
      children: [
        Transform.scale(
          scaleX: 1.1,
          scaleY: 1.1,
          child: ColorFiltered(
            colorFilter:
                ColorFilter.mode(ColorManager.accentColor, BlendMode.srcIn),
            child: Image.asset(
              AssetManager.imageFile(name: "troco"),
              width: 100,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        header(text: "Limited")
      ],
    );
  }

  Widget author() {
    return Container(
      width: IconSizeManager.extralarge * 2.5,
      height: IconSizeManager.extralarge * 4,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge * 2.5),
              bottom: Radius.circular(SizeManager.extralarge * 2.5)),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(AssetManager.imageFile(
                  name: "nike-shoe-sample", ext: Extension.jpeg)))),
    );
  }
}
