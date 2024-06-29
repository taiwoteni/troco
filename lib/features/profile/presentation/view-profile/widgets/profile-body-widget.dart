import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/groups-in-common-widget.dart';

class ProfileBody extends ConsumerStatefulWidget {
  final Client client;
  const ProfileBody({super.key, required this.client});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileBodyWidgetState();
}

class _ProfileBodyWidgetState extends ConsumerState<ProfileBody> {
  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extraLargeSpacer(),
          title(titleText: "Business Information"),
          largeSpacer(),
          regularSpacer(),
          subtTitle(name: "name", value: client.businessName),
          mediumSpacer(),
          subtTitle(name: "email", value: client.email),
          mediumSpacer(),
          subtTitle(name: "phone number", value: client.phoneNumber),
          mediumSpacer(),
          subtTitle(name: "address", value: client.address),
          mediumSpacer(),
          subtTitle(name: "city", value: client.city),
          mediumSpacer(),
          subtTitle(name: "state", value: client.state),
          mediumSpacer(),
          extraLargeSpacer(),
          title(
              titleText: widget.client == ClientProvider.readOnlyClient!
                  ? "Business Groups"
                  : "Groups in common"),
          regularSpacer(),
          if (client == ClientProvider.readOnlyClient!)
            ...AppStorage.getGroups().map(
                (group) => GroupsInCommonWidget(group: group, client: client))
          else
            ...AppStorage.getGroups()
                .where(
                  (group) => group.members.contains(client.userId),
                )
                .map(
                  (group) => GroupsInCommonWidget(group: group, client: client),
                ),
          extraLargeSpacer(),
        ],
      ),
    );
  }

  Widget title({required final String titleText}) {
    return Text(
      titleText.toUpperCase(),
      style: TextStyle(
          fontFamily: "Lato",
          color: ColorManager.themeColor,
          fontSize: FontSizeManager.regular,
          fontWeight: FontWeightManager.extrabold),
    );
  }

  Widget subtTitle({required final String name, required final String value}) {
    return SingleChildScrollView(
      child: Row(
        children: [
          Text(
            "${name.titleCase}:",
            style: TextStyle(
                fontFamily: "Lato",
                color: ColorManager.primary,
                fontSize: FontSizeManager.regular * 0.9,
                fontWeight: FontWeightManager.bold),
          ),
          largeSpacer(),
          Text(
            value,
            style: TextStyle(
                fontFamily: "Lato",
                color: ColorManager.secondary,
                fontSize: FontSizeManager.regular * 0.9,
                fontWeight: FontWeightManager.bold),
          ),
        ],
      ),
    );
  }
}
