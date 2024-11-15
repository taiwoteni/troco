import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/wallet/domain/entities/referral.dart';
import 'package:troco/features/wallet/presentation/providers/referrals-provider.dart';
import 'package:troco/features/wallet/presentation/widgets/referral-widget.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../../core/components/texts/outputs/info-text.dart';
import '../../../auth/domain/entities/client.dart';
import '../../../groups/presentation/collections_page/widgets/empty-screen.dart';

class ReferredScreen extends ConsumerStatefulWidget {
  const ReferredScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReferredScreenState();
}

class _ReferredScreenState extends ConsumerState<ReferredScreen> {
  late TextEditingController textController;
  List<Referral> referrals = AppStorage.getReferrals();

  @override
  void initState() {
    textController = TextEditingController();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listenToReferralsChanges();
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: ColorManager.background,
        padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.large * 1.2,
        ),
        child: referralSearch(),
      ),
    );
  }

  Widget title() {
    return Text(
      "Referred",
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

  Widget referralSearch() {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        extraLargeSpacer(),
        back(),
        mediumSpacer(),
        title(),
        largeSpacer(),
        regularSpacer(),
        searchBar(),
        regularSpacer(),
        referrals.isEmpty
            ? Flexible(
                child: EmptyScreen(
                  expanded: false,
                  lottie: AssetManager.lottieFile(name: "plane-cloud"),
                  label: textController.text.trim().isEmpty
                      ? "You don't have any referrals"
                      : "No search results for '${textController.text.toString().trim()}'",
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                key: const Key("referrals-list"),
                itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                          bottom: index == referrals.length - 1
                              ? SizeManager.large * 1.5
                              : 0),
                      child: ReferralWidget(
                        key: ObjectKey(referrals[index]),
                        referral: referrals[index],
                      ),
                    ),
                separatorBuilder: (context, index) => Divider(
                      thickness: 0.8,
                      color: ColorManager.secondary.withOpacity(0.09),
                    ),
                itemCount: referrals.length),
        // if (referrals.isNotEmpty)
        //   Container(
        //       padding: const EdgeInsets.symmetric(
        //           horizontal: SizeManager.extralarge),
        //       alignment: Alignment.center,
        //       child: InfoText(
        //           underline: true,
        //           color: ColorManager.accentColor,
        //           alignment: Alignment.center,
        //           text: "How does referral work?"))
      ],
    );
    return referrals.isEmpty
        ? child
        : SingleChildScrollView(
            child: child,
          );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeManager.medium),
      child: TextFormField(
        controller: textController,
        maxLines: 1,
        onChanged: (text) {
          final value = text.trim().toLowerCase();
          final queriedReferrals = AppStorage.getReferrals().where((element) {
            bool hasfullName =
                element.fullName.toLowerCase().trim().contains(value);
            return hasfullName;
          }).toList();
          if (value.trim().isEmpty) {
            setState(() {
              referrals = AppStorage.getReferrals();
            });
          } else {
            setState(() {
              referrals = queriedReferrals;
            });
          }
        },
        cursorColor: ColorManager.themeColor,
        cursorRadius: const Radius.circular(SizeManager.medium),
        style: defaultStyle(),
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                vertical: SizeManager.medium,
                horizontal: SizeManager.medium * 1.3),
            isDense: true,
            hintText: "Search user you referred",
            floatingLabelBehavior: FloatingLabelBehavior.never,
            hintStyle: defaultStyle().copyWith(color: ColorManager.secondary),
            fillColor: ColorManager.tertiary,
            filled: true,
            border: defaultBorder(),
            enabledBorder: defaultBorder(),
            errorBorder: defaultBorder(),
            focusedBorder: defaultBorder(),
            disabledBorder: defaultBorder(),
            focusedErrorBorder: defaultBorder()),
      ),
    );
  }

  TextStyle defaultStyle() {
    return TextStyle(
        color: ColorManager.primary,
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.medium,
        fontFamily: 'Lato');
  }

  InputBorder defaultBorder() {
    return OutlineInputBorder(
        borderSide:
            BorderSide(color: ColorManager.themeColor, style: BorderStyle.none),
        borderRadius: BorderRadius.circular(SizeManager.large));
  }

  Future<void> listenToReferralsChanges() async {
    ref.listen(referralsStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          setState(
            () => referrals = data,
          );
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      );
    });
  }
}
