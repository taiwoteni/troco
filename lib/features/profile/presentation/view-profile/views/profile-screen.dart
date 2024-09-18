import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/extensions/text-extensions.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/client-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/providers/tab-index-provider.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/body-section.dart';
import 'package:troco/features/profile/presentation/view-profile/widgets/header-section.dart';

import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/components/images/svg.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late Client client;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ref.read(profileTabIndexProvider.notifier).state = 0;
      tabController.addListener(() => ref
          .read(profileTabIndexProvider.notifier)
          .state = tabController.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: ColorManager.background,
      child: RawGestureDetector(
        gestures: {
          // Define gesture recognizers here
        },
        behavior: HitTestBehavior.opaque,
        child: CustomScrollView(
          slivers: [
            const HeaderSection(),
            SliverPersistentHeader(
              delegate:
                  _SliverTabBarDelegate(child: tabBar(), context: context),
              pinned: true,
            ),
            const BodySection(),
          ],
        ),
      ),
    );
  }

  Widget tabBar() {
    return MediaQuery(
      data: MediaQuery.of(context),
      child: Container(
        color: ColorManager.background,
        padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
        child: TabBar(
          controller: tabController,
          tabs: const [
            Tab(
              text: "Details",
            ),
            Tab(
              text: "Friends",
            ),
            Tab(
              text: "Groups",
            ),
            Tab(
              text: "Referrals",
            )
          ],
          onTap: (value) {
            // setState(() => isGroupsTab = value == 0);
          },
          // dividerHeight: 0,
          indicatorColor: ColorManager.accentColor,
          indicatorWeight: SizeManager.small * 1.4,
          dividerHeight: 0.8,
          indicatorPadding:
              const EdgeInsets.symmetric(vertical: SizeManager.small),
          labelStyle: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium * 0.75,
              fontWeight: FontWeightManager.semibold),
          unselectedLabelStyle: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Lato',
              fontSize: FontSizeManager.medium * 0.75,
              fontWeight: FontWeightManager.medium),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final BuildContext context;

  _SliverTabBarDelegate({required this.child, required this.context});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 51.6 + MediaQuery.viewPaddingOf(context).top;

  @override
  double get minExtent => 51.6 + MediaQuery.viewPaddingOf(context).top;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
