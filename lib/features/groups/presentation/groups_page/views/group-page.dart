import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/features/groups/presentation/group_tab/widgets/group-widget.dart';
import 'package:troco/core/components/texts/inputs/search-bar.dart';
import 'package:troco/core/components/clippers/inward-bottom-rounded-clipper.dart';
import 'package:troco/features/groups/presentation/group_tab/widgets/create-group-sheet.dart';
import 'package:troco/features/groups/presentation/group_tab/views/groups-tab.dart';

import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/snackbar-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../../core/components/images/profile-icon.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../auth/presentation/providers/client-provider.dart';
import '../../../../transactions/utils/enums.dart';

class GroupPage extends ConsumerStatefulWidget {
  const GroupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends ConsumerState<GroupPage>
    with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getGroupsUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Padding(
          padding: const EdgeInsets.only(bottom: SizeManager.medium),
          child: CustomScrollView(
            primary: true,
            slivers: [
              SliverAppBar(
                systemOverlayStyle: ThemeManager.getGroupsUiOverlayStyle(),
                expandedHeight: 150.0 + MediaQuery.of(context).viewPadding.top,
                pinned: false,
                backgroundColor: ColorManager.accentColor,
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax, background: appBar()),
                elevation: 0,
                forceElevated: true,
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate:
                      _SliverTabBarDelegate(child: tabBar(), context: context)),
              const GroupsPage(),
            ],
          )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: SizeManager.bottomBarHeight),
        child: FloatingActionButton(
          onPressed: tabController.index == 0 ? createGroup : null,
          heroTag: "add-group",
          shape: const CircleBorder(),
          backgroundColor: ColorManager.accentColor,
          foregroundColor: Colors.white,
          child: const Icon(
            Icons.add_rounded,
            size: IconSizeManager.regular,
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium * 1.5),
      color: ColorManager.accentColor,
      child: Column(
        children: [
          Gap(MediaQuery.of(context).viewPadding.top),
          mediumSpacer(),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Groups",
                style: TextStyle(
                    fontFamily: 'Lato',
                    color: Colors.white,
                    height: 1.5,
                    fontSize: FontSizeManager.large * 1.1,
                    fontWeight: FontWeightManager.semibold),
              ),
              UserProfileIcon(
                size: IconSizeManager.medium * 1.3,
              ),
            ],
          ),
          const Spacer(),
          SearchBarWidget(label: "Search", onChanged: (v) {}),
          const Spacer(),
        ],
      ),
    );
  }

  Widget tabBar() {
    return ClipPath(
      clipper: InwardBottomRoundedClipper(),
      child: Container(
        alignment: Alignment.bottomCenter,
        color: ColorManager.accentColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: tabController,
              tabs: const [
                Tab(
                  text: "Groups",
                ),
                Tab(
                  text: "Friends",
                )
              ],
              dividerHeight: 0,
              indicatorColor: Colors.white,
              indicatorWeight: SizeManager.small * 1.4,
              indicatorPadding:
                  const EdgeInsets.symmetric(vertical: SizeManager.small),
              labelStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontSize: FontSizeManager.medium,
                  fontWeight: FontWeightManager.semibold),
              unselectedLabelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Lato',
                  fontSize: FontSizeManager.medium,
                  fontWeight: FontWeightManager.medium),
            ),
            regularSpacer()
          ],
        ),
      ),
    );
  }

  Widget friendList() {
    final groups = [];
    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.small),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => ChatContactWidget(
              group: groups[index],
            ),
        separatorBuilder: (context, index) => Divider(
              thickness: 0.8,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
        itemCount: groups.length);
  }

  Future<void> createGroup() async {
    if (AppStorage.getGroups().length >= 20) {
      if (ClientProvider.readOnlyClient!.accountCategory == Category.Personal) {
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "Max groups for Personal Account is 20.");
      }
      return;
    }
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) {
        return const SingleChildScrollView(child: CreateGroupSheet());
      },
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
  double get maxExtent => 51.6 + 10 + MediaQuery.of(context).viewPadding.top;

  @override
  double get minExtent => 51.6 + 10 + MediaQuery.of(context).viewPadding.top;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
