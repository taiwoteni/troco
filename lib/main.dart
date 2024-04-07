import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app/app.dart';
import 'core/cache/shared-preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppStorage.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const ProviderScope(child: MyApp.instance)));
}
