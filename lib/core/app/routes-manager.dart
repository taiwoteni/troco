import 'package:flutter/material.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/features/groups/data/models/group-model.dart';
import 'package:troco/features/chat/presentation/views/chat-screen.dart';
import 'package:troco/features/auth/presentation/login/views/forget-password-otp.dart';
import 'package:troco/features/auth/presentation/login/views/forget-password.dart';
import 'package:troco/features/home/presentation/views/home-screen.dart';
import 'package:troco/features/onboarding/presentation/views/onboarding-sceen.dart';
import 'package:troco/features/auth/presentation/otp/views/otp-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-pin-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-profile-screen.dart';
import 'package:troco/features/auth/presentation/register/views/setup-account-screen.dart';
import 'package:troco/features/splash/presentation/splash-screen.dart';


import '../../features/auth/presentation/login/views/login-screen.dart';
import '../../features/auth/presentation/register/views/register-screen.dart';
import '../../features/auth/presentation/success/views/auth-success-screen.dart';

class Routes {
  static const splashRoute = "/";
  static const onBoardingRoute = "/onboarding";
  static const authRoute = "/auth";
  static const loginRoute = "/login";
  static const registerRoute = "/register";
  static const otpLoginRoute = "/otp-login";
  static const otpRegisterRoute = "/otp-register";
  static const otpForgotPasswordRoute = "/otp-forget-password";
  static const forgotPasswordRoute = "/forgot-password";
  static const setupAccountRoute = '/setup-account';
  static const addProfileRoute = '/add-profile';
  static const addTransactionPinRoute = "/add-transaction-pin";
  static const authSuccessRoute = "/auth-success";
  static const homeRoute = "/home";

  /// [chatRoute] is the route for the chat screen.
  /// Must pass the recipient client as an argument!
  static const chatRoute = "/chat";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.onBoardingRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const OnboardingScreen());
      case Routes.registerRoute:
        LoginData.clear();
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const RegisterScreen());
      case Routes.otpRegisterRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const OTPScreen(
                  isFromLogin: false,
                ));
      case Routes.setupAccountRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const SetupAccountScreen());
      case Routes.addProfileRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const AddProfileScreen(),
        );
      case Routes.addTransactionPinRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const SetTransactionPinScreen());
      case Routes.authSuccessRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const AuthSuccessScreen(),
        );
      case Routes.loginRoute:
        LoginData.clear();
        return MaterialPageRoute(
            settings: routeSettings, builder: (context) => const LoginScreen());
      case Routes.otpLoginRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const OTPScreen(
                  isFromLogin: true,
                ));
      case Routes.forgotPasswordRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ForgotPasswordScreen());
      case Routes.otpForgotPasswordRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const OTPForgetPasswordScreen());
      case Routes.homeRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const HomeScreen(),
        );
      case Routes.chatRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            final group = routeSettings.arguments as GroupModel;
            return ChatScreen(group: group);
          },
        );
      default:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const SplashScreen());
    }
  }
}
