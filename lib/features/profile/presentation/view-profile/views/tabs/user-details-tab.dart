import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/client-provider.dart';

class UserDetailsTab extends ConsumerStatefulWidget {
  const UserDetailsTab({super.key});

  @override
  ConsumerState createState() => _UserDetailsTabState();
}

class _UserDetailsTabState extends ConsumerState<UserDetailsTab> {
  bool blocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        setState(() {
          blocked = ClientProvider.readOnlyClient!.blockedUsers
              .contains(ref.read(userProfileProvider)!.userId);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(userProfileProvider)!;
    final isSelf = client == ClientProvider.readOnlyClient!;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large),
      sliver: SliverList.list(
        children: [
          largeSpacer(),
          detail(title: "full name", value: client.fullName),
          divider(),
          detail(title: "email", value: client.email),
          divider(),
          detail(
            title: "phone number",
            value: client.phoneNumber,
            trailing: isSelf
                ? null
                : GestureDetector(
                    onTap: () async {
                      final success =
                          (await FlutterPhoneDirectCaller.callNumber(
                                  client.phoneNumber) ??
                              false);

                      if (!success) {
                        SnackbarManager.showBasicSnackbar(
                            context: context,
                            mode: ContentType.failure,
                            message: "Unable to call ${client.firstName}");
                      }
                    },
                    child: Transform.scale(
                      scale: 1.3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SizeManager.regular,
                            vertical: SizeManager.small),
                        child: Icon(
                          CupertinoIcons.phone_fill,
                          color: ColorManager.accentColor,
                          size: IconSizeManager.regular * 1.05,
                        ),
                      ),
                    ),
                  ),
          ),
          divider(),
          detail(title: "business name", value: client.businessName),
          divider(),
          detail(
              title: "account type",
              value: "${client.accountCategory.name} Account"),
          divider(),
          detail(title: "verification", value: client.kycTier.name),
          divider(),
          detail(title: "referral code", value: client.referralCode),
          divider(),
          detail(title: "location", value: client.address),

          if (!isSelf) ...[
            divider(),
            regularSpacer(),
            action(
                leading: Container(
                  padding: const EdgeInsets.all(SizeManager.regular * 0.95),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: SvgIcon(
                    svgRes: AssetManager.svgFile(name: "report"),
                    color: Colors.white,
                    size: const Size.square(IconSizeManager.small * 0.85),
                  ),
                ),
                label: "Report ${client.firstName}"),
            smallSpacer(),
            divider(),
            regularSpacer(),
            action(
                leading: Container(
                  padding: const EdgeInsets.all(SizeManager.regular * 0.95),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: SvgIcon(
                    svgRes: AssetManager.svgFile(name: "block"),
                    color: Colors.white,
                    size: const Size.square(IconSizeManager.small * 0.85),
                  ),
                ),
                label: "Block ${client.firstName}"),
          ],

          extraLargeSpacer(),
          // divider(),
          // detail(title: "city", value: client.city),
          // divider(),
          // detail(title: "state", value: client.state),
        ],
      ),
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
      child: Divider(
          thickness: 1, color: ColorManager.secondary.withOpacity(0.08)),
    );
  }

  Widget detail(
      {required final String title,
      required final String value,
      Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
              color: ColorManager.secondary,
              fontSize: FontSizeManager.regular * 0.69,
              fontFamily: 'quicksand',
              fontWeight: FontWeightManager.semibold),
        ),
        smallSpacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              value,
              textAlign: TextAlign.start,
              softWrap: true,
              style: TextStyle(
                  color: ColorManager.primary,
                  fontWeight: FontWeightManager.bold,
                  fontFamily: 'quicksand',
                  fontSize: FontSizeManager.medium * 0.85),
            ),
            const Spacer(),
            if (trailing != null) ...[
              Container(
                width: 2.5,
                height: 20,
                decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(SizeManager.large)),
              ),
              mediumSpacer(),
              trailing,
              regularSpacer(),
            ]
          ],
        )
      ],
    );
  }

  Widget action({required final Widget leading, required final String label}) {
    return Row(
      children: [
        leading,
        mediumSpacer(),
        Text(
          label.titleCase,
          style: TextStyle(
              color: ColorManager.primary,
              fontSize: FontSizeManager.medium * 0.95,
              fontFamily: 'quicksand',
              fontWeight: FontWeightManager.bold),
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: ColorManager.secondary.withOpacity(0.4),
        ),
        mediumSpacer(),
      ],
    );
  }
}
