import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/features/about%20us/presentation/widgets/fade-slide-in-widget.dart';
import 'package:troco/features/about%20us/utils/enums.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
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
                          "Troco Technology values personal data and takes privacy very seriously. 'Personal information' refers to facts or viewpoints regarding a specific person or someone who may be easily identified. The personal data that Troco Technology collects and/or retains is covered by the Troco Privacy Policy. Additionally, our Privacy Policy describes how we handle 'personal data' concerning individuals in the EU as mandated by the General Data Protection Regulation (GDPR). This policy will be reviewed frequently, and it may be updated sometimes.")),
              largeSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 5),
                  child: header(
                      text: "Personal data that we collect and retain:")),
              smallSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 6),
                  child: content(
                      text:
                          "We gather user personal data so that we can offer our services, goods, and customer support. We offer our goods, services, and customer assistance via a variety of channels, such as websites, mobile applications, email, and phone calls, among others. The particular platform and product, service, or support you use may have an impact on the personal information we receive.")),
              smallSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 7),
                  direction: SlideDirection.left,
                  mustBeVisible: true,
                  child: content(
                      text:
                          'Not all of the information we request, acquire, and process is "Personal Information" because it does not identify you as a distinct natural person. This will include the bulk of "User Generated Content" that you supply to us with the goal of sharing with other users during the transaction. This privacy policy does not cover such "Non-Personal Information". However, because non-personal information can be aggregated or connected with existing personal information, it is classified as personal information. As a result, in order to ensure transparency, this privacy policy will list both types of information.')),
              largeSpacer(),
              FadeSlideWidget(
                  direction: SlideDirection.left,
                  delay: const Duration(seconds: 8),
                  mustBeVisible: true,
                  child:
                      header(text: "Our methods for gathering personal data")),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 9),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          "While using our products and services, you may be required to give certain types of personal information. This could occur through our platform, applications, online chat platforms, phone calls, paper forms, or in-person encounters. We will provide you with a Collection Notice at the time to clarify how we intend to use the personal information we are requesting. The notice can be written or given verbally. We may seek, gather, or handle the following information:")),
              smallSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 10),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      content(
                          text:
                              "1) Password for account details Contact Details: phone number and email address"),
                      smallSpacer(),
                      content(
                          text:
                              "2) Identification Details: full name, evidence of identity (such as a passport or driver's license)"),
                      smallSpacer(),
                      content(
                          text:
                              "3) Proof of residence (such as a utility bill), and location details (such as the physical address and billing address)"),
                      smallSpacer(),
                    ],
                  )),

              //...
              largeSpacer(),
              FadeSlideWidget(
                  direction: SlideDirection.left,
                  delay: const Duration(seconds: 13),
                  mustBeVisible: true,
                  child: header(text: "How we utilize personal data")),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 14),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          "Providing users with the requested product or service is the main purpose of the information we seek, gather, and handle. In particular, we might utilize your personal data for the following reasons.")),
              smallSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 14),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      content(
                          text:
                              "A) To fulfill legal and regulatory requirements"),
                      smallSpacer(),
                      content(
                          text:
                              "B) To act out research, data analysis, and other platform development and enhancements"),
                      smallSpacer(),
                      content(
                          text:
                              "C) To enable testing, debugging, and other platform operations."),
                      smallSpacer(),
                      content(
                          text:
                              "D) To advertise any additional programs, goods, or services that could be of interest to you (unless you have chosen not to receive such messages)"),
                      smallSpacer(),
                      content(
                          text:
                              "E) To address a complaint or provide information regarding our services;"),
                      smallSpacer(),
                      content(
                          text:
                              "F) To offer you technical assistance or other support"),
                      smallSpacer(),
                      content(
                          text:
                              "G) support the formation of Troco technology agreements"),
                      smallSpacer(),
                      content(
                          text:
                              "H) To fulfill your request for a service or product"),
                      smallSpacer(),
                    ],
                  )),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 15),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          'We shall utilize user personal information for the following "lawful processing" purposes, among others:\n\nwhen a user has granted consent; when processing is required to fulfill a contract to which the user is a party; when processing is required to protect our users or another natural persons vital interests; when processing is required to comply with our legal obligations; and when processing is carried out to further our legitimate interests, provided that these interests do not conflict with our users rights.')),

              largeSpacer(),
              FadeSlideWidget(
                  direction: SlideDirection.left,
                  delay: const Duration(seconds: 16),
                  mustBeVisible: true,
                  child: header(
                      text: "The third-party service providers that we use")),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 16),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          "Additionally, we might give third parties access to your personal data for the following reasons:")),
              smallSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 10),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      content(
                          text:
                              "A) Law enforcement sends us subpoenas, court orders, and other information requests."),
                      smallSpacer(),
                      content(
                          text:
                              "B) unless otherwise allowed or mandated by law; or for other uses with your permission."),
                      smallSpacer(),
                      content(
                          text:
                              "C) if required to deliver the goods or service you have ordered;"),
                      smallSpacer(),
                    ],
                  )),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 16),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          "Your personal information may be processed by employees in any of our locations because we are a multinational corporation with offices throughout Nigeria. Currently, Escrow maintains offices in Lagos, Aba, IMO, Enugu, Asaba, and Amambra.")),

              largeSpacer(),
              FadeSlideWidget(
                  direction: SlideDirection.left,
                  delay: const Duration(seconds: 17),
                  mustBeVisible: true,
                  child: header(
                      text: "Retrieving or updating your personal data")),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 17),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          "You are entitled to seek access to the personal data that Troco has on file about you. We must give you access to the personal information we have about you, unless an exemption applies, in a timely manner, at no cost to you, and without undue expense. You may access the most of your personal data by signing into your account. Contact our Privacy Officer if you would like to obtain information that is not available on the platform or if you would like to obtain a portable data format of all the personal date we have on file for you.\nAdditionally, you have the right to ask for the personal data we have on file about you to be corrected. You can update all of your personal data via the user settings pages. If you need help, please get in touch with our customer service.")),

              largeSpacer(),
              FadeSlideWidget(
                  direction: SlideDirection.left,
                  delay: const Duration(seconds: 18),
                  mustBeVisible: true,
                  child:
                      header(text: "Utilizing your additional legal rights")),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 18),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          "Regarding the personal information that Troco has on you, you have a variety of other rights, but there can be limitations on how you can use them. This is mostly because of the type of goods and services we offer. We collect a lot of data to fulfill our legal duties, facilitate user contracts, facilitate payments, and safeguard genuine users. These data uses are protected by the rights listed below.\n\nA) Elimination: \nRemoval the majority of personal data cannot be removed since it is necessary to maintain user contracts, record financial transactions, and safeguard platform users. Non-personal information that can be connected to personal information will either be removed or anonymized in some other way.\n\nB) temporary processing limitation. In some situations, you may exercise this right, especially if you think that the personal information we have on you is inaccurate or that we don't have a good reason to process it. You can contact our privacy officer to exercise this right in either scenario. Users can exercise any of the aforementioned rights by getting in touch with our Privacy Officer, unless otherwise specified.")),

              largeSpacer(),
              FadeSlideWidget(
                  direction: SlideDirection.left,
                  delay: const Duration(seconds: 19),
                  mustBeVisible: true,
                  child: header(
                      text: "Get in touch with our privacy customer care.")),
              mediumSpacer(),
              FadeSlideWidget(
                  delay: const Duration(seconds: 19),
                  direction: SlideDirection.right,
                  mustBeVisible: true,
                  child: content(
                      text:
                          "To exercise your right to privacy regarding the personal information we have on file about you, or to inquire or complain about how we handle it, please get in touch with our Privacy customer care  using the details below:\n\nemail. privacycustomercare@troco.ng\nOffice : Ibusa junction by Nebisi road, asaba, Delta.\n\nWhile we make every effort to address complaints promptly and amicably, if you would want to move further with a formal privacy complaint, please submit your grievance in writing to our Privacy Officer using the above postal or email address. Your formal complaint will be acknowledged within a day.")),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Text(
      "Privacy Policy",
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
}
