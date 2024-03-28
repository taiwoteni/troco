import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/custom-views/chat-contact.dart';
import 'package:troco/custom-views/search-bar.dart';
import 'package:troco/view/clippers/inward-bottom-rounded-clipper.dart';

import '../../app/font-manager.dart';
import '../../custom-views/profile-icon.dart';
import '../../custom-views/spacer.dart';
import '../../models/transaction.dart';
import '../../providers/client-provider.dart';

class GroupPage extends ConsumerStatefulWidget {
  const GroupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends ConsumerState<GroupPage>
    with TickerProviderStateMixin {
  bool isCollapsed = false;
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
            slivers: [
              SliverAppBar(
                systemOverlayStyle: ThemeManager.getGroupsUiOverlayStyle(),
                expandedHeight: 150.0 + MediaQuery.of(context).viewPadding.top,
                pinned: false,
                // onStretchTrigger: () {
                //   return Future.sync(
                //       () => setState(() => isCollapsed = !isCollapsed));
                // },
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
              SliverFillRemaining(
                  fillOverscroll: false,
                  child: TabBarView(controller: tabController, children: [
                    groupsList(),
                    friendList(),
                  ]))
            ],
          )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: SizeManager.bottomBarHeight),
        child: FloatingActionButton(
          onPressed: null,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Business",
                style: TextStyle(
                    fontFamily: 'Lato',
                    color: Colors.white,
                    height: 1.5,
                    fontSize: FontSizeManager.large * 1.1,
                    fontWeight: FontWeightManager.semibold),
              ),
              ProfileIcon(
                profile: DecorationImage(
                    image: FileImage(
                        File(ref.watch(ClientProvider.userProvider)!.profile)),
                    fit: BoxFit.cover),
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

  Widget groupsList() {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.small),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.ease,
                  height: isCollapsed && index == 0
                      ? 51.6 + 10 + MediaQuery.of(context).viewPadding.top
                      : 0,
                ),
                ChatContactWidget(
                  transaction: transactions()[index],
                ),
              ],
            ),
        separatorBuilder: (context, index) => Divider(
              thickness: 0.8,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
        itemCount: transactions().length);
  }

  Widget friendList() {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.small),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.ease,
                  height: isCollapsed && index == 0
                      ? 51.6 + 10 + MediaQuery.of(context).viewPadding.top
                      : 0,
                ),
                ChatContactWidget(
                  transaction: transactions()[index],
                ),
              ],
            ),
        separatorBuilder: (context, index) => Divider(
              thickness: 0.8,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
        itemCount: transactions().length);
  }

  List<Transaction> transactions() {
    return [
      const Transaction.fromJson(json: {
        "transaction detail": "Withdrew 50,000 NGN",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 50000.00,
        "transaction status": "Finalizing",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Bought macbook pro",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 100000.00,
        "transaction status": "Pending",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Shipped Tera Batteries",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Selling",
        "transaction amount": 250000.00,
        "transaction status": "Completed",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Withdrew 50,000 NGN",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 50000.00,
        "transaction status": "Finalizing",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Bought macbook pro",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 100000.00,
        "transaction status": "Pending",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Shipped Tera Batteries",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Selling",
        "transaction amount": 250000.00,
        "transaction status": "Completed",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Withdrew 50,000 NGN",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 50000.00,
        "transaction status": "Finalizing",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Bought macbook pro",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Buying",
        "transaction amount": 100000.00,
        "transaction status": "Pending",
      }),
      const Transaction.fromJson(json: {
        "transaction detail": "Shipped Tera Batteries",
        "transaction id": "ID-87aA8",
        "transaction purpose": "Selling",
        "transaction amount": 250000.00,
        "transaction status": "Completed",
      }),
    ];
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
