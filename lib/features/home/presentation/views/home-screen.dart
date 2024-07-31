import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/customer%20care/domain/repositories/customer-care-repository.dart';
import 'package:troco/features/home/presentation/providers/home-pages-provider.dart';
import 'package:troco/features/notifications/domain/entities/notification.dart'
    as n;
import 'package:troco/features/notifications/domain/repository/notification-repository.dart';
import '../../../auth/utils/phone-number-converter.dart';
import '../../../transactions/utils/enums.dart';
import '../widgets/bottom-bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final pages = homeItems;
  @override
  void initState() {
    if(ClientProvider.readOnlyClient!.accountCategory == Category.Personal){
      pages.remove(1);
    }
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      final result = await NotificationRepo.getAllNotifications();

      if (!result.error) {
        final notifs = result.messageListBody as List;
        final notifications = notifs
            .map(
              (e) => n.Notification.fromJson(json: e),
            )
            .toList();
        AppStorage.saveNotifications(notifications: notifications);
      }

      if (AppStorage.getCustomerCareSessionId() == null) {
        AppStorage.saveCustomerCareChats(chats: []);
        final response = await CustomerCareRepository.createChatSession();
        log(response.body);
        if (!response.error) {
          final id = response.messageBody!["chatSession"]["_id"].toString();
          log(id);

          AppStorage.saveCustomerCareSessionId(sessionId: id);
          // We are saving a preset customer care chat for the intro.
          final result = await CustomerCareRepository.sendIntroCustomerCareChat(
              customerCareId: response.messageBody!["chatSession"]
                  ["customerCare"],
              sessionId: id);

          log(result.body);
        }
      }

      getFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: ref.watch(homeProvider) == 0,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }

        ref.watch(homeProvider.notifier).state = 0;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorManager.background,
        extendBody: true,
        body: Padding(
          padding: const EdgeInsets.only(
            bottom: SizeManager.regular,
          ),
          child: pages[ref.watch(homeProvider)].page,
        ),
        bottomNavigationBar: const BottomBar(),
      ),
    );
  }

  Future<bool> requestPermissions() async {
    PermissionStatus status = await Permission.contacts.request();
    return status.isGranted;
  }

  Future<void> getFriends() async {
    if (await requestPermissions()) {
      final contacts = (await ContactsService.getContacts())
          .where(
            (element) => element.phones != null,
          )
          .toList();
      final phoneNumbers = contacts
          .expand(
            (element) => element.phones!.map(
              (e) => PhoneNumberConverter.convertToFull(
                  e.value!.replaceAll(" ", "")),
            ),
          )
          .toList();

      final response = await ApiInterface.searchUser(query: "");
      if (!response.error) {
        log(response.messageBody!["data"].toString());
        final usersList = (response.messageBody!["data"] as List)
            .map(
              (e) => Client.fromJson(json: e),
            )
            .where(
              (element) =>
                  element.userId != ClientProvider.readOnlyClient!.userId,
            )
            .toList();

        AppStorage.saveFriends(
            friends: usersList
                .where(
                  (element) => phoneNumbers.contains(element.phoneNumber),
                )
                .toList());
      }
    }
  }
}
