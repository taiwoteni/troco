// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/app/value-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/home/presentation/providers/blocked-provider.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/transactions-provider.dart';

import '../../features/groups/presentation/friends_tab/providers/friends-provider.dart';
import '../../features/kyc/utils/enums.dart';
import '../../features/kyc/utils/kyc-converter.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp._internal(); //private constructor

  static const MyApp instance =
      MyApp._internal(); // final single instance of MyApp

  factory MyApp() => instance;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late Timer userRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        refreshUser();
      },
    );
  }

  @override
  void dispose() {
    // ignore: unnecessary_null_comparison
    if (userRefreshTimer != null) {
      userRefreshTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listenTransactionsChanges();
    listenToFriendsChanges();
    return MaterialApp(
      title: ValuesManager.APP_NAME,
      themeMode: ThemeMode.light,
      initialRoute: Routes.splashRoute,
      onGenerateRoute: (settings) => RouteGenerator.getRoute(settings),
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.getApplicationTheme(),
    );
  }

  void listenTransactionsChanges() {
    ref.listen(
      transactionsStreamProvider,
      (previous, next) {
        next.whenData((value) {
          AppStorage.saveTransactions(transactions: value);
        });
      },
    );
  }

  Future<void> refreshUser() async {
    // we want to regularly show that the user is online.
    // Hence, the need to regularly update the lastSeen time to the current time.
    // This way, wether a user has internet connection or not, we would be able to tell wether
    // ...he is online or not.
    userRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        // We get the user to try to  know if the user is logged in
        // or not.
        final client = ClientProvider.readOnlyClient;
        if (client == null) {
          return;
        }
        await updateOnlineStatus();

        final response = await ApiInterface.findUser(userId: client.userId);
        // log(response.body, name: "User");

        if (!response.error) {
          // To constantly save and update userdata
          final userJson = response.messageBody!["data"];
          // debugPrint(userJson.toString());
          userJson["password"] = ClientProvider.readOnlyClient!.password;
          final updatedClient = Client.fromJson(json: userJson);
          if (AppStorage.getUser() != null) {
            ref.watch(clientProvider.notifier).state = updatedClient;
          }
          AppStorage.saveClient(client: updatedClient);

          if (userJson["kycTier"] != userJson["kyccurrentTier"]) {
            //To save kyc status, if currently verifying or not.
            AppStorage.savekycVerificationStatus(
                tier: KycConverter.convertToEnum(
                    tier: userJson["kyccurrentTier"].toString()));
          } else {
            AppStorage.savekycVerificationStatus(tier: VerificationTier.None);
          }

          // To check if user is blocked.
          final blocked = updatedClient.blocked;

          kIsBlocked = blocked;
        }
      },
    );
  }

  Future<void> updateOnlineStatus() async {
    final response = await AuthenticationRepo.updateOnlineStatus();
  }

  Future<void> listenToFriendsChanges() async {
    ref.listen(friendsStreamProvider, (previous, next) {
      next.when(
        data: (data) {},
        error: (error, stackTrace) => null,
        loading: () => null,
      );
    });
  }
}
