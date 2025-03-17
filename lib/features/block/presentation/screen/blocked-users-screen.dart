import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/block/presentation/provider/blocked-users-provider.dart';
import 'package:troco/features/block/presentation/widgets/blocked-user-widget.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../auth/domain/entities/client.dart';
import '../../../groups/presentation/collections_page/widgets/empty-screen.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  late TextEditingController textController;
  List<Client> blockedUsers = AppStorage.getBlockedUsers();

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
    listenToBlockedUserChanges();
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: ColorManager.background,
        padding: const EdgeInsets.symmetric(
          horizontal: SizeManager.large * 1.2,
        ),
        child: blockedUsersSearch(),
      ),
    );
  }

  Widget title() {
    return Text(
      "Blocked Users",
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

  Widget blockedUsersSearch() {
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
        blockedUsers.isEmpty
            ? Flexible(
                child: EmptyScreen(
                  expanded: false,
                  lottie: AssetManager.lottieFile(name: "plane-cloud"),
                  label: textController.text.trim().isEmpty
                      ? "You don't have any blocked users"
                      : "No search results for '${textController.text.toString().trim()}'",
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                key: const Key("blocked-users-list"),
                itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                          bottom: index == blockedUsers.length - 1
                              ? SizeManager.large * 1.5
                              : 0),
                      child: BlockedUserWidget(
                        key: ObjectKey(blockedUsers[index]),
                        client: blockedUsers[index],
                      ),
                    ),
                separatorBuilder: (context, index) => Divider(
                      thickness: 0.8,
                      color: ColorManager.secondary.withOpacity(0.09),
                    ),
                itemCount: blockedUsers.length),
      ],
    );
    return blockedUsers.isEmpty
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
          final queriedUsers = AppStorage.getBlockedUsers().where((element) {
            bool hasfullName =
                element.lastName.toLowerCase().trim().contains(value) ||
                    value.contains(element.lastName.trim().toLowerCase()) ||
                    element.firstName.toLowerCase().trim().contains(value) ||
                    value.contains(element.firstName.trim().toLowerCase());
            return hasfullName;
          }).toList();
          if (value.trim().isEmpty) {
            setState(() {
              blockedUsers = AppStorage.getBlockedUsers();
            });
          } else {
            setState(() {
              blockedUsers = queriedUsers;
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
            hintText: "Search for a blocked user",
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

  Future<void> listenToBlockedUserChanges() async {
    ref.listen(blockedUsersStreamProvider, (previous, next) {
      next.when(
        data: (data) {
          setState(
            () => blockedUsers = data,
          );
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      );
    });
  }
}
