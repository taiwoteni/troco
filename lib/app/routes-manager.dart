import 'package:flutter/material.dart';
import 'package:troco/data/login-data.dart';
import 'package:troco/view/auth-screen/auth-screen.dart';
import 'package:troco/view/chat-screen/chat-screen.dart';
import 'package:troco/view/forget-password-screen/forget-password-otp.dart';
import 'package:troco/view/forget-password-screen/forget-password.dart';
import 'package:troco/view/home-screen/home-screen.dart';
import 'package:troco/view/otp-screen/otp-screen.dart';
import 'package:troco/view/register-screen/add-pin-screen.dart';
import 'package:troco/view/register-screen/add-profile-screen.dart';
import 'package:troco/view/register-screen/register-success-screen.dart';
import 'package:troco/view/register-screen/setup-account-screen.dart';
import 'package:troco/view/splash-screen/splash-screen.dart';

import '../models/client.dart';
import '../view/login-screen/login-screen.dart';
import '../view/register-screen/register-screen.dart';

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
  static const registerSuccessRoute = "/register-success";

  static const homeRoute = "/home";

  /// [chatRoute] is the route for the chat screen.
  /// Must pass the recipient client as an argument!
  static const chatRoute = "/chat";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.authRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const AuthScreen(),);
      case Routes.registerRoute:
      LoginData.clear();
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const RegisterScreen());
      case Routes.otpRegisterRoute:
        return MaterialPageRoute(settings: routeSettings, builder: (context) => const OTPScreen(isFromLogin: false,));
      case Routes.setupAccountRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const SetupAccountScreen());
      case Routes.addProfileRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) => const AddProfileScreen(),);
      case Routes.addTransactionPinRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const SetTransactionPinScreen());
      case Routes.registerSuccessRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) => const RegisterSuccessScreen(),);
      case Routes.loginRoute:
      LoginData.clear();
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const LoginScreen());
      case Routes.otpLoginRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const OTPScreen(isFromLogin: true,));
      case Routes.forgotPasswordRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) => const ForgotPasswordScreen());
      case Routes.otpForgotPasswordRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) => const OTPForgetPasswordScreen());
      case Routes.homeRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) => const HomeScreen(),);
      case Routes.chatRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) {
        final client = routeSettings.arguments as Client;
        return ChatScreen(client: client);
      },);
      default:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const SplashScreen());
    }
  }
}
