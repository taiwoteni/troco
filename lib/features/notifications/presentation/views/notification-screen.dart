import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/notifications/domain/repository/notification-repository.dart';
import 'package:troco/features/notifications/presentation/providers/notification-provider.dart';
import 'package:troco/features/notifications/presentation/widgets/notification-item-widget.dart';
import 'package:troco/features/notifications/presentation/widgets/notification-menu-button.dart';

import '../../../../core/app/asset-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/app/theme-manager.dart';
import '../../../../core/components/images/svg.dart';
import '../../../../core/components/others/spacer.dart';
import '../../../groups/presentation/collections_page/widgets/empty-screen.dart';
import '../../domain/entities/notification.dart' as n;
import '../../utils/enums.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  NotificationFilter filter = NotificationFilter.All;
  List<n.Notification> allNotifications = AppStorage.getNotifications();

  @override
  void initState() {
    allNotifications.sort(
      (a, b) => 1.compareTo(0),
    );
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getChatUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    listenToTransactionsChanges();
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: appBar(),
      body: SizedBox.expand(
        child: allNotifications.isEmpty ? emptyBody() : body(),
      ),
    );
  }

  Widget emptyBody() {
    return EmptyScreen(
      lottie: AssetManager.lottieFile(name: 'empty-transactions'),
      label: filter == NotificationFilter.All
          ? "You have no notifications"
          : "You have no ${filter.name.toLowerCase()} notifications",
      scale: 1.5,
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mediumSpacer(),
          menuButtons(),
          mediumSpacer(),
          title(),
          mediumSpacer(),
          notificationsList(),
        ],
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
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
                    color: ColorManager.accentColor,
                    size: const Size.square(40),
                  ),
                ),
                mediumSpacer(),
                Text(
                  "Notifications",
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

  Widget menuButtons() {
    return Row(
      children: [
        extraLargeSpacer(),
        ...NotificationFilter.values.map((filter) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleWidget(
                  selected: filter == this.filter,
                  onChecked: () => setState(() => this.filter = filter),
                  label: filter.name.toLowerCase()),
              regularSpacer(),
              smallSpacer(),
            ],
          );
        })
      ],
    );
  }

  Widget title() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: SizeManager.extralarge * 1.1),
      child: Text(
        filter.name,
        style: TextStyle(
            fontFamily: "Lato",
            fontSize: FontSizeManager.large,
            color: ColorManager.primary,
            fontWeight: FontWeightManager.semibold),
      ),
    );
  }

  Widget notificationsList() {
    final filteredNotifications = filter == NotificationFilter.All
        ? allNotifications
        : allNotifications
            .where(
              (element) => filter == NotificationFilter.Read
                  ? element.read
                  : !element.read,
            )
            .toList();
    return filteredNotifications.isEmpty
        ? SizedBox.fromSize(
            size: Size.fromHeight(MediaQuery.of(context).size.height * .7),
            child: emptyBody(),
          )
        : ListView.separated(
            shrinkWrap: true,
            key: const Key("notification-list"),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => NotificationItemWidget(
                key: ObjectKey(filteredNotifications[index]),
                notification: filteredNotifications[index]),
            separatorBuilder: (context, index) => Divider(
                  color: ColorManager.secondary.withOpacity(0.09),
                ),
            itemCount: filteredNotifications.length);
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(notificationsStreamProvider, (previous, next) {
      next.whenData((value) {
        value.sort(
          (a, b) => 1.compareTo(0),
        );

        setState(() {
          allNotifications = value;
        });
        markNotificationsAsRead();
      });
    });
  }

  Future<void> markNotificationsAsRead() async {
    for (final notif in allNotifications) {
      if (!notif.read) {
        NotificationRepo.markNotificationAsRead(notification: notif).then(
          (value) {
            log(value.body);
          },
        );
      }
    }
  }
}
