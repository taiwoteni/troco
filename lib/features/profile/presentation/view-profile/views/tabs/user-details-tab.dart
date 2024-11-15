import 'dart:developer';

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
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/core/extensions/navigator-extension.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/client-provider.dart';
import 'package:troco/features/report/presentation/widgets/report-user-sheet.dart';

import '../../../../../../core/app/dialog-manager.dart';
import '../../../../../block/domain/repository/block-repository.dart';

class UserDetailsTab extends ConsumerStatefulWidget {
  const UserDetailsTab({super.key});

  @override
  ConsumerState createState() => _UserDetailsTabState();
}

class _UserDetailsTabState extends ConsumerState<UserDetailsTab> {
  bool blocked = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(userProfileProvider)!;
    final isSelf = client == ClientProvider.readOnlyClient!;

    blocked = ref.watch(userProfileProvider)!.blockedByUser;
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
                onPressed: reportUser,
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
                onPressed: blockUser,
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
                label: loading
                    ? (blocked ? 'Unblocking...' : 'Blocking...')
                    : "Block ${client.firstName}"),
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

  Future<void> blockUser() async {
    if (loading) {
      return;
    }

    final dialogManager = DialogManager(context: context);
    final block = await dialogManager.showDialogContent<bool?>(
        title: "${blocked ? "Unblock" : "Block"} User",
        description:
            "Are you sure you want to ${blocked ? "unblock" : "block"} ${ref.read(userProfileProvider)!.fullName.trim()}?",
        icon: ProfileIcon(
          size: 60,
          url: ref.read(userProfileProvider)!.profile,
        ),
        okLabel: blocked ? 'Unblock' : null,
        cancelLabel: blocked ? null : 'Block',
        onCancel: () => context.pop(result: true),
        onOk: () => context.pop(result: false));

    if (block == null) {
      return;
    }

    setState(() => loading = true);

    final blockedIds = AppStorage.getUser()!.blockedUsers;

    final response = await (!blocked
        ? BlockRepository.blockUser(
            userId: ref.read(userProfileProvider)!.userId,
            reason: "Blocked this user")
        : BlockRepository.unblockUser(
            userId: ref.read(userProfileProvider)!.userId, reason: ""));
    log(response.body);

    if (response.error) {
      SnackbarManager.showErrorSnackbar(
          context: context, message: "Unable to block user");
      setState(() {
        loading = false;
      });
      return;
    }
    SnackbarManager.showBasicSnackbar(
        context: context, message: "Blocked user successfully");
    if (block) {
      blockedIds.remove(ref.read(userProfileProvider)!.userId);
    } else {
      blockedIds.add(ref.read(userProfileProvider)!.userId);
    }

    final clientJson = AppStorage.getUser()!.toJson();
    clientJson["blockedUsers"] = blockedIds;
    await AppStorage.saveClient(client: Client.fromJson(json: clientJson));

    if (!block) {
      context.pop();
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> reportUser() {
    return ReportUserSheet.bottomSheet(
        context: context, client: ref.read(userProfileProvider)!);
  }

  Widget action(
      {required final Widget leading,
      void Function()? onPressed,
      required final String label}) {
    return InkWell(
      onTap: onPressed,
      child: Row(
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
      ),
    );
  }
}
