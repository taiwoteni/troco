import 'package:flutter/material.dart';
import 'package:troco/app/routes-manager.dart';
import 'package:troco/app/theme-manager.dart';
import 'package:troco/app/value-manager.dart';

class MyApp extends StatelessWidget {
  const MyApp._internal(); //private constructor

  static const MyApp instance =
      MyApp._internal(); // final single instance of MyApp

  factory MyApp() => instance;
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
}
