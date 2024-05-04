import 'package:flutter/material.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/features/auth/presentation/auth/views/auth-screen.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/chat/presentation/views/chat-screen.dart';
import 'package:troco/features/auth/presentation/login/views/forget-password-otp.dart';
import 'package:troco/features/auth/presentation/login/views/forget-password.dart';
import 'package:troco/features/home/presentation/views/home-screen.dart';
import 'package:troco/features/notifications/presentation/views/notification-screen.dart';
import 'package:troco/features/onboarding/presentation/views/onboarding-sceen.dart';
import 'package:troco/features/auth/presentation/otp/views/otp-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-pin-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-profile-screen.dart';
import 'package:troco/features/auth/presentation/register/views/setup-account-screen.dart';
import 'package:troco/features/settings/presentation/edit-profile-page/views/edit-profile-screen.dart';
import 'package:troco/features/settings/presentation/language/views/change-language-screen.dart';
import 'package:troco/features/settings/presentation/password/views/change-password-screen.dart';
import 'package:troco/features/settings/presentation/two-factor-authentication/views/two-factor-authentication-screen.dart';
import 'package:troco/features/splash/presentation/splash-screen.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/create-transaction/views/transaction-success-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-products-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-transaction-screen.dart';

import '../../features/auth/presentation/login/views/login-screen.dart';
import '../../features/auth/presentation/register/views/register-screen.dart';
import '../../features/auth/presentation/success/views/auth-success-screen.dart';
import '../../features/transactions/presentation/create-transaction/views/create-transaction-screen.dart';

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

  static const notificationRoute = "/notification";

  /// [chatRoute] is the route for the chat screen.
  /// Must pass the recipient client as an argument!
  static const chatRoute = "/chat";

  static const createTransactionRoute = "/create-transaction";

  static const transactionSuccessRoute = "/create-transaction-success";

  /// [viewTransactionRoute] is the route to view a transaction.
  /// Must pass the transaction as an argument!
  static const viewTransactionRoute = "/view-transaction";
  static const viewProductsRoute = "/view-product";

  static const editProfileRoute = "/edit-profile";
  static const twoFactorAuthenticationRoute = "/two-factor-authentication";
  static const changePasswordRoute = "/change-password";
  static const changeLanguageRoute = "/change-language";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.onBoardingRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const OnboardingScreen());
      case Routes.authRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const AuthScreen(),
        );
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
      case Routes.notificationRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const NotificationScreen(),
        );
      case Routes.chatRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            final group = routeSettings.arguments! as Group;
            return ChatScreen(group: group);
          },
        );
      case Routes.createTransactionRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            // final group = routeSettings.arguments as Group;
            return const CreateTransactionScreen();
          },
        );
      case Routes.transactionSuccessRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            // final group = routeSettings.arguments as Group;
            return const TransactionSuccessScreen();
          },
        );
      case Routes.viewTransactionRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            final transaction = routeSettings.arguments! as Transaction;
            return ViewTransactionScreen(transaction: transaction);
          },
        );
      case Routes.viewProductsRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            final transaction = routeSettings.arguments! as Transaction;
            return ViewProductScreen(transaction: transaction);
          },
        );
      case Routes.editProfileRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const EditProfileScreen());
      case Routes.twoFactorAuthenticationRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const TwoFactorAuthenticationScreen());
      case Routes.changePasswordRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ChangePasswordScreen());
      case Routes.changeLanguageRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ChangeLanguageScreen());
      default:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const SplashScreen());
    }
  }
}
