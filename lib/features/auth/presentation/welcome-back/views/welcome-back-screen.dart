// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/features/auth/presentation/welcome-back/views/password-entry-screen.dart';
import 'package:troco/features/auth/presentation/welcome-back/views/pin-entry-screen.dart';
import 'package:troco/features/settings/presentation/settings-page/providers/settings-provider.dart';
import 'package:troco/features/settings/utils/enums.dart';

class WelcomeBackScreen extends ConsumerStatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends ConsumerState<WelcomeBackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getChatUiOverlayStyle());

      // We're using Chat Ui overlay style because it has white status bar with black icons as well
      // as white nav bar with black nav bar item color
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorManager.background,
        body:ref.read(settingsProvider).appEntryMethod == AppEntryMethod.Password
                ? const PasswordEntryScreen()
                : const PinEntryScreen());
  }
}
