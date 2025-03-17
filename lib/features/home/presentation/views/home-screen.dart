import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/customer%20care/domain/repositories/customer-care-repository.dart';
import 'package:troco/features/home/presentation/providers/blocked-provider.dart';
import 'package:troco/features/home/presentation/providers/home-pages-provider.dart';
import 'package:troco/features/home/presentation/widgets/blocked-screen.dart';
import 'package:troco/features/notifications/domain/entities/notification.dart'
    as n;
import 'package:troco/features/notifications/domain/repository/notification-repository.dart';
import 'package:troco/features/notifications/presentation/providers/notification-provider.dart';
import 'package:troco/features/services/domain/entities/escrow-fee.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';
import '../../../../core/api/data/repositories/api-interface.dart';
import '../../../auth/domain/entities/client.dart';
import '../widgets/bottom-bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  var pages = homeItems;
  bool showBlockedScreen = ClientProvider.readOnlyClient?.blocked ?? false;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      final result = await NotificationRepo.getAllNotifications();
      debugPrint(AppStorage.getReferrals()
          .map(
            (e) => e.toJson(),
          )
          .toList()
          .toString());

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
        final response = await CustomerCareRepository.createChatSession(
            id: ClientProvider.readOnlyClient!.userId);
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

      saveAllUsersPhones();
      getLatestEscrowCharges();
    });
  }

  @override
  Widget build(BuildContext context) {
    // listenToTransactions();
    listenToBlockedChanges();
    listenToNotificationChanges();
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
        body: showBlockedScreen
            ? const BlockScreen()
            : Padding(
                padding: const EdgeInsets.only(
                  bottom: SizeManager.regular,
                ),
                child: pages[ref.watch(homeProvider)].page,
              ),
        bottomNavigationBar: showBlockedScreen
            ? null
            : BottomBar(
                pages: pages,
              ),
      ),
    );
  }

  Future<void> saveAllUsersPhones() async {
    final response = await ApiInterface.getAllUsersNumbers();
    if (!response.error) {
      final users = (response.messageListBody ?? []);
      final allUsersPhone = users
          .map(
            (e) => Client.fromJson(json: e),
          )
          .toList();
      AppStorage.saveAllUsersPhone(phones: allUsersPhone);
    }
  }

  void listenToBlockedChanges() {
    ref.listen(
      blockedStreamProvider,
      (previous, next) {
        next.when(
          data: (data) => setState(() {
            showBlockedScreen = data;
          }),
          error: (error, stackTrace) => null,
          loading: () => null,
        );
      },
    );
  }

  void listenToNotificationChanges() {
    ref.listen(
      notificationsStreamProvider,
      (previous, next) {
        next.when(
          data: (data) {},
          error: (error, stackTrace) => null,
          loading: () => null,
        );
      },
    );
  }

  Future<void> getLatestEscrowCharges() async {
    final response = await TransactionRepo.getEscrowCharges();
    if (!response.error) {
      AppStorage.saveEscrowCharges(
          escrowCharges: (response.messageBody!["data"] as List)
              .map(
                (e) => EscrowCharge.fromJson(json: e),
              )
              .toList());
    }

    // debugPrint(response.body);
  }

  //5781e0
}
