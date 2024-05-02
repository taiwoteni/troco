import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/chat/presentation/widgets/client-widget.dart';
import 'package:troco/features/groups/presentation/widgets/empty-screen.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/images/svg.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../groups/domain/entities/group.dart';

class AddGroupMemberWidget extends ConsumerStatefulWidget {
  final Group group;
  const AddGroupMemberWidget({super.key, required this.group});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddGroupMemberWidgetState();
}

class _AddGroupMemberWidgetState extends ConsumerState<AddGroupMemberWidget>
    with TickerProviderStateMixin {
  late TabController controller;
  late TextEditingController textController;
  late Group group;
  List<Client> allClients = [];
  List<Client> queriedClients = [];
  List<Client> invitedClients = [];

  @override
  void initState() {
    group = widget.group;
    controller = TabController(length: 2, vsync: this);
    textController = TextEditingController();
    super.initState();
    fetchAll();
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
    controller.dispose();
    textController.dispose();
    super.dispose();
  }

  Future<void> fetchAll() async {
    List<Client> invitedClients =
        await AppStorage.getInvitedClients(groupId: group.groupId);
    List<Client> allClients = [];
    final result = await ApiInterface.searchUser(query: "");
    if (!result.error) {
      final List<dynamic> clientsJson = result.messageBody!["data"];
      allClients = clientsJson
          .map((e) => Client.fromJson(json: e))
          .toList()
          .where((element) =>
              element.userId != ClientProvider.readOnlyClient!.userId)
          .toList();
    } else {
      log(result.body);
    }

    setState(() {
      this.invitedClients = invitedClients;
      queriedClients = allClients;
      this.allClients = allClients;
    });
    log(allClients.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      padding: const EdgeInsets.only(top: SizeManager.large),
      decoration: BoxDecoration(
        color: ColorManager.background,
      ),
      child: Column(
        children: [
          appBar(),
          regularSpacer(),
          tabBar(),
          Expanded(
            child: TabBarView(controller: controller, children: [
              clientSearch(),
              groupInvitations(),
            ]),
          )
        ],
      ),
    );
  }

  Widget clientSearch() {
    return Column(
      children: [
        regularSpacer(),
        searchBar(),
        regularSpacer(),
        queriedClients.isEmpty
            ? EmptyScreen(
                expanded: true,
                lottie: AssetManager.lottieFile(name: "plane-cloud"),
                label: allClients.isEmpty
                    ? "Getting users"
                    : "No search results for '${textController.text.toString().trim()}'",
              )
            : ListView.separated(
                shrinkWrap: true,
                key: const Key("add-member-list"),
                itemBuilder: (context, index) => ClientWidget(
                      key: ObjectKey(queriedClients[0]),
                      client: queriedClients[index],
                      group: group,
                      inviteMode: true,
                    ),
                separatorBuilder: (context, index) => Divider(
                      thickness: 0.8,
                      color: ColorManager.secondary.withOpacity(0.09),
                    ),
                itemCount: queriedClients.length)
      ],
    );
  }

  Widget groupInvitations() {
    return invitedClients.isEmpty
        ? SizedBox(
            width: double.maxFinite,
            child: EmptyScreen(
              expanded: true,
              lottie: AssetManager.lottieFile(name: "empty"),
              label: "No Invitations so far in this group",
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) => ClientWidget(
                  client: invitedClients[index],
                  group: group,
                  inviteMode: false,
                ),
            separatorBuilder: (context, index) => Divider(
                  color: ColorManager.secondary.withOpacity(0.9),
                ),
            itemCount: invitedClients.length);
  }

  Widget tabBar() {
    return TabBar(
      tabs: const [
        Tab(
          //intentional
          text: " Invite ",
        ),
        Tab(
          text: "Invites",
        )
      ],
      controller: controller,
      dividerHeight: 1,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: ColorManager.accentColor,
      indicatorWeight: SizeManager.small * 1.4,
      labelStyle: TextStyle(
          color: ColorManager.accentColor,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium,
          fontWeight: FontWeightManager.semibold),
      unselectedLabelStyle: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'Lato',
          fontSize: FontSizeManager.medium,
          fontWeight: FontWeightManager.medium),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  iconSize: 40,
                  icon: SvgIcon(
                    svgRes: AssetManager.svgFile(name: 'back'),
                    fit: BoxFit.cover,
                    color: ColorManager.themeColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Add Member",
                  style: TextStyle(
                      color: ColorManager.primary,
                      fontFamily: 'Lato',
                      fontWeight: FontWeightManager.extrabold,
                      fontSize: FontSizeManager.medium * 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.medium, vertical: SizeManager.medium),
      child: TextFormField(
        controller: textController,
        maxLines: 1,
        onChanged: (text) {
          final value = text.trim().toLowerCase();
          final queryClients = allClients.where((element) {
            bool hasfullName =
                element.lastName.toLowerCase().trim().contains(value) ||
                    value.contains(element.lastName.trim().toLowerCase()) ||
                    element.firstName.toLowerCase().trim().contains(value) ||
                    value.contains(element.firstName.trim().toLowerCase());
            bool byRole =
                element.accountCategory.name.toLowerCase().contains(value) ||
                    value.contains(element.accountCategory.name.toLowerCase());
            return hasfullName || byRole;
          }).toList();
          if (value.trim().isEmpty) {
            setState(() {
              queriedClients = allClients;
            });
          } else {
            setState(() {
              queriedClients = queryClients;
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
            hintText: "Search for client",
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
}
