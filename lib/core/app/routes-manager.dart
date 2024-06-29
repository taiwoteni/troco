import 'package:flutter/material.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/auth/views/auth-screen.dart';
import 'package:troco/features/auth/presentation/welcome-back/views/welcome-back-screen.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';
import 'package:troco/features/chat/presentation/views/view-attachment-screen.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/chat/presentation/views/chat-screen.dart';
import 'package:troco/features/auth/presentation/login/views/forget-password.dart';
import 'package:troco/features/home/presentation/views/home-screen.dart';
import 'package:troco/features/notifications/presentation/views/notification-screen.dart';
import 'package:troco/features/onboarding/presentation/views/onboarding-sceen.dart';
import 'package:troco/features/auth/presentation/otp/views/otp-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-pin-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-profile-screen.dart';
import 'package:troco/features/auth/presentation/register/views/setup-account-screen.dart';
import 'package:troco/features/payments/presentation/views/payment-method-screen.dart';
import 'package:troco/features/profile/presentation/edit-profile/views/edit-profile-screen.dart';
import 'package:troco/features/profile/presentation/view-profile/views/view-profile-screen.dart';
import 'package:troco/features/settings/presentation/language/views/change-language-screen.dart';
import 'package:troco/features/settings/presentation/password/views/change-password-screen.dart';
import 'package:troco/features/settings/presentation/pin/views/change-pin-screen.dart';
import 'package:troco/features/settings/presentation/two-factor-authentication/views/two-factor-authentication-screen.dart';
import 'package:troco/features/splash/presentation/splash-screen.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/create-transaction/views/transaction-success-screen.dart';
import 'package:troco/features/transactions/presentation/my-transactions/views/my-transaction-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-products-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-transaction-screen.dart';

import '../../features/auth/presentation/login/views/login-screen.dart';
import '../../features/auth/presentation/register/views/register-screen.dart';
import '../../features/auth/presentation/success/views/auth-success-screen.dart';
import '../../features/groups/presentation/view-group/views/view-group-screen.dart';
import '../../features/kyc/presentation/views/kyc-verification-intro-screen.dart';
import '../../features/kyc/presentation/views/kyc-verification-screen.dart';
import '../../features/services/presentation/calc/views/fee-calculator-screen.dart';
import '../../features/transactions/presentation/create-transaction/views/create-transaction-screen.dart';

class Routes {
  static const splashRoute = "/";
  static const welcomeBackRoute = "/welcome-back";
  static const onBoardingRoute = "/onboarding";
  static const authRoute = "/auth";
  static const loginRoute = "/login";
  static const registerRoute = "/register";
  static const otpRoute = "/otp";
  static const otpPhoneRoute = "/otp";
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
  static const changePinRoute = "/change-pin";
  static const changeLanguageRoute = "/change-language";

  static const paymentMethodRoute = "/payment-methods";

  static const kycVerificationIntroRoute = "/kyc-verification";
  static const kycVerificationRoute = "/kyc-verification-input";

  static const myTransactionsRoute = "/my-transactions";

  static const feeCalculatorRoute = "/fee-calculator";
  static const viewProfileRoute = "/view-profile";
  static const viewGroupRoute = "/view-group";

  /// Make sure when using, u are passing [Chat,Group] as the arguments
  /// for [viewAttachmentRoute].
  static const viewAttachmentRoute = "/view-attachments";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.welcomeBackRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const WelcomeBackScreen());
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
      case Routes.otpRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const OTPScreen(
                  email: true,
                ));
      case Routes.otpPhoneRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const OTPScreen(
                  email: false,
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
      case Routes.forgotPasswordRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ForgotPasswordScreen());
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
      case Routes.changePinRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ChangePinScreen());
      case Routes.changeLanguageRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ChangeLanguageScreen());
      case Routes.paymentMethodRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const PaymentMethodsScreen());
      case Routes.kycVerificationRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const KycVerificationScreen());
      case Routes.kycVerificationIntroRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const KycVerificationIntroScreen());
      case Routes.myTransactionsRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const MyTransactionScreen());
      case Routes.feeCalculatorRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const FeeCalculatorScreen());
      case Routes.viewProfileRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) {
              final client = routeSettings.arguments! as Client;
              return ViewProfileScreen(
                client: client,
              );
            });
      case Routes.viewGroupRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) {
              final group = routeSettings.arguments! as Group;
              return ViewGroupScreen(
                group: group,
              );
            });
      case Routes.viewAttachmentRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) {
              final arguments = routeSettings.arguments! as List;

              final chat = arguments[0] as Chat;
              final group = arguments[1] as Group;
              return ViewAttachmentScreen(
                chat: chat,
                group:group,
              );
            });

      default:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const SplashScreen());
    }
  }
}
