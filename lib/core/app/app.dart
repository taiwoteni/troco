import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:troco/core/api/data/repositories/api-interface.dart';
import 'package:troco/core/app/routes-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/core/app/value-manager.dart';
import 'package:troco/features/auth/domain/repositories/authentication-repo.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

class MyApp extends StatefulWidget {
  const MyApp._internal(); //private constructor

  static const MyApp instance =
      MyApp._internal(); // final single instance of MyApp

  factory MyApp() => instance;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer onlineTimer;
  late Timer blockedTimer;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      // updateOnlineStatus(); 
      checkBlockStatus();
    },);
    
  }

  @override
  void dispose() {
    // ignore: unnecessary_null_comparison
    if(onlineTimer != null){
      onlineTimer.cancel();
    }
    blockedTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ValuesManager.APP_NAME,
      themeMode: ThemeMode.light,    
      initialRoute: Routes.splashRoute,
      onGenerateRoute: (settings) => RouteGenerator.getRoute(settings),
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.getApplicationTheme(),
    );
  }

  Future<void> updateOnlineStatus()async{
    // we want to regularly show that the user is online.
    // Hence, the need to regularly update the lastSeen time to the current time.
    // This way, wether a user has internet connection or not, we would be able to tell wether
    // ...he is online or not.
    onlineTimer =  Timer.periodic(const Duration(minutes: 4), (timer) async{
      final response = await AuthenticationRepo.updateOnlineStatus();
    log(response.body);
    },);
    
  }

  Future<void> checkBlockStatus()async{
    // we want to regularly show that the user is online.
    // Hence, the need to regularly update the lastSeen time to the current time.
    // This way, wether a user has internet connection or not, we would be able to tell wether
    // ...he is online or not.
    blockedTimer =  Timer.periodic(const Duration(minutes: 4), (timer) async{
      final client = ClientProvider.readOnlyClient;
      if(client == null){
        return;
      }

      final response = await ApiInterface.findUser(userId: client.userId);
      if(!response.error){
        final blocked = response.messageBody!["data"]["blocked"] == true;
        final currentRoute = ModalRoute.of(context);

        if(blocked && currentRoute != null && currentRoute.settings.name != Routes.blockedScreenRoute){
          // Change to blocked screen;
          Navigator.pushNamedAndRemoveUntil(context, Routes.blockedScreenRoute, (route) => false);
          
          
        }
      }
    },);
    
  }


}
