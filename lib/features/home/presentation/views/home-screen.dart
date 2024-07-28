import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/customer%20care/domain/repositories/customer-care-repository.dart';
import 'package:troco/features/home/presentation/providers/home-pages-provider.dart';
import 'package:troco/features/notifications/domain/entities/notification.dart' as n;
import 'package:troco/features/notifications/domain/repository/notification-repository.dart';

import '../widgets/bottom-bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp)async{
      final result = await NotificationRepo.getAllNotifications();

      if(!result.error){
        final notifs = result.messageListBody as List;
        final notifications = notifs.map((e) => n.Notification.fromJson(json: e),).toList();
        AppStorage.saveNotifications(notifications: notifications);
      }

      if(AppStorage.getCustomerCareSessionId() == null){
       final response = await CustomerCareRepository.createChatSession();
       log(response.body);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.background,
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: SizeManager.regular,
        ),
        child: homeItems[ref.watch(homeProvider)].page,
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
