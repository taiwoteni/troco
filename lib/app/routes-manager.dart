import 'package:flutter/material.dart';
import 'package:troco/view/auth-screen/auth-screen.dart';
import 'package:troco/view/otp-screen/otp-screen.dart';
import 'package:troco/view/register-screen/add-pin-screen.dart';
import 'package:troco/view/register-screen/add-profile-screen.dart';
import 'package:troco/view/register-screen/register-success-screen.dart';
import 'package:troco/view/register-screen/setup-account-screen.dart';
import 'package:troco/view/splash-screen/splash-screen.dart';

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
  static const setupAccountRoute = '/setup-account';
  static const addProfileRoute = '/add-profile';
  static const addTransactionPinRoute = "/add-transaction-pin";
  static const registerSuccessRoute = "/register-success";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.authRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const AuthScreen(),
        );
      case Routes.registerRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const RegisterScreen());
      case Routes.otpRegisterRoute:
        return MaterialPageRoute(
          settings: routeSettings,
            builder: (context) => OTPScreen(
                  onVerifySuccessful: () => Navigator.pushReplacementNamed(
                      context, Routes.setupAccountRoute),
            ));
      case Routes.setupAccountRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const SetupAccountScreen());
      case Routes.addProfileRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) => const AddProfileScreen(),);
      case Routes.addTransactionPinRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const SetTransactionPinScreen());
      case Routes.registerSuccessRoute:
      return MaterialPageRoute(settings: routeSettings,builder: (context) => const RegisterSuccessScreen(),);
      case Routes.loginRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const LoginScreen());
      case Routes.otpLoginRoute:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const OTPScreen());
      default:
        return MaterialPageRoute(settings: routeSettings,builder: (context) => const SplashScreen());
    }
  }
}
