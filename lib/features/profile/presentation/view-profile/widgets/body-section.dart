import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/tab-index-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/views/tabs/friends-tab.dart';
import 'package:troco/features/profile/presentation/view-profile/views/tabs/groups-tab.dart';
import 'package:troco/features/profile/presentation/view-profile/views/tabs/referalls-tab.dart';
import 'package:troco/features/profile/presentation/view-profile/views/tabs/user-details-tab.dart';

import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';

class BodySection extends ConsumerStatefulWidget {
  const BodySection({super.key});

  @override
  ConsumerState createState() => _BodySectionState();
}

class _BodySectionState extends ConsumerState<BodySection>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    switch (ref.watch(profileTabIndexProvider)) {
      case 0:
        return const UserDetailsTab();
      case 1:
        return const FriendsTab();
      case 2:
        return const GroupsTab();
      default:
        return const ReferralsTab();
    }
  }
}
