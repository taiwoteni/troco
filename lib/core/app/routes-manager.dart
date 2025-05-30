import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:troco/features/about%20us/presentation/views/about-us-screen.dart';
import 'package:troco/features/auth/data/models/login-data.dart';
import 'package:troco/features/auth/data/models/otp-data.dart';
import 'package:troco/features/auth/domain/entities/client.dart';
import 'package:troco/features/auth/presentation/auth/views/auth-screen.dart';
import 'package:troco/features/auth/presentation/welcome-back/views/welcome-back-screen.dart';
import 'package:troco/features/block/presentation/screen/blocked-users-screen.dart';
import 'package:troco/features/chat/domain/entities/chat.dart';
import 'package:troco/features/chat/presentation/views/view-attachment-screen.dart';
import 'package:troco/features/contact-us/presentation/views/contact-us.dart';
import 'package:troco/features/customer%20care/presentation/views/customer-care-chat-screen.dart';
import 'package:troco/features/disclaimer/presentation/views/disclaimer.dart';
import 'package:troco/features/groups/domain/entities/group.dart';
import 'package:troco/features/chat/presentation/views/chat-screen.dart';
import 'package:troco/features/auth/presentation/login/views/forget-password.dart';
import 'package:troco/features/groups/presentation/group_tab/views/contacts-screen.dart';
import 'package:troco/features/home/presentation/views/home-screen.dart';
import 'package:troco/features/home/presentation/widgets/blocked-screen.dart';
import 'package:troco/features/how-to-use-troco/presentation/views/how-to-use-troco.dart';
import 'package:troco/features/notifications/presentation/views/notification-screen.dart';
import 'package:troco/features/onboarding/presentation/views/onboarding-sceen.dart';
import 'package:troco/features/auth/presentation/otp/views/otp-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-pin-screen.dart';
import 'package:troco/features/auth/presentation/register/views/add-profile-screen.dart';
import 'package:troco/features/auth/presentation/register/views/setup-account-screen.dart';
import 'package:troco/features/payments/presentation/views/payment-method-screen.dart';
import 'package:troco/features/payments/presentation/views/payment-screen.dart';
import 'package:troco/features/privacy%20policy/presentation/views/privacy-policy.dart';
import 'package:troco/features/profile/presentation/edit-profile/views/edit-profile-screen.dart';
import 'package:troco/features/profile/presentation/view-profile/views/view-profile-screen.dart';
import 'package:troco/features/protection-and-safety/presentation/views/protection-and-safety.dart';
import 'package:troco/features/settings/presentation/change-email/views/change-email-screen.dart';
import 'package:troco/features/settings/presentation/change-phoneNumber/views/change-phone-number-screen.dart';
import 'package:troco/features/settings/presentation/language/views/change-language-screen.dart';
import 'package:troco/features/settings/presentation/password/views/change-password-screen.dart';
import 'package:troco/features/settings/presentation/pin/views/change-pin-screen.dart';
import 'package:troco/features/settings/presentation/pin/views/forget-pin.dart';
import 'package:troco/features/settings/presentation/two-factor-authentication/views/two-factor-authentication-screen.dart';
import 'package:troco/features/splash/presentation/splash-screen.dart';
import 'package:troco/features/terms-and-conditions/presentation/views/terms-and-conditions.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/create-transaction/views/transaction-success-screen.dart';
import 'package:troco/features/transactions/presentation/my-transactions/views/my-transaction-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-products-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-receipt-screen.dart';
import 'package:troco/features/transactions/presentation/view-transaction/views/view-transaction-screen.dart';
import 'package:troco/features/wallet/domain/entities/wallet-transaction.dart';
import 'package:troco/features/wallet/presentation/views/referrals-screen.dart';
import 'package:troco/features/wallet/presentation/views/wallet-history-screen.dart';
import 'package:troco/features/wallet/presentation/views/wallet-transaction-screen.dart';
import 'package:troco/features/wallet/presentation/views/withdraw-screen.dart';

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
  static const forgotPasswordRoute = "/forgot-password";
  static const forgotPin = "/forgot-pin";

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
  static const changeEmail = "/change-email";
  static const changePhoneNumber = "/change-phoneNumber";
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
  static const viewContacts = "/view-contacts";
  static const aboutUsRoute = "/about-us";
  static const customerCareRoute = "/customer-care";

  static const cardPaymentScreen = "/payment-screen";
  static const blockedScreenRoute = "/blocked-screen";
  static const withdrawRoute = "/withdraw";
  static const referredRoute = "/referred";

  static const walletHistoryRoute = "/wallet-history";
  static const walletTransactionRoute = "/wallet-transaction";
  static const blockedUsersRoute = "/blocked-users";

  static const privacyPolicyRoute = '/privacy-policy';
  static const termsAndConditionsRoute = '/terms-and-conditions';
  static const howToUseTrocoRoute = '/how-to-use-troco';
  static const contactUsRoute = '/contact-us';

  static const disclaimerRoute = '/disclaimer';
  static const viewReceiptRoute = "/view-receipt";
  static const protectionAndSafetyRoute = '/protection-and-safety';
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
        final isEmail = OtpData.email != null;
        final target = OtpData.email ?? OtpData.phoneNumber!;
        final verificationType =
            routeSettings.arguments as OtpVerificationType?;
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => OTPScreen(
                  target: target,
                  isEmail: isEmail,
                  otpVerificationType:
                      verificationType ?? OtpVerificationType.Authentication,
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
      case Routes.forgotPin:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ForgotPinScreen());
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
      case Routes.viewReceiptRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            final receiptBytes = routeSettings.arguments! as Uint8List;
            return ViewReceiptScreen(receiptBytes: receiptBytes);
          },
        );
      case Routes.viewProductsRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            return const ViewProductScreen();
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
                group: group,
              );
            });
      case Routes.viewContacts:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const ContactsScreen());
      case Routes.aboutUsRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const AboutUsScreen());
      case Routes.cardPaymentScreen:
        final redirectLink = routeSettings.arguments as String;
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => PaymentScreen(redirectLink: redirectLink));
      case Routes.customerCareRoute:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const CustomerCareChatScreen());
      case Routes.blockedScreenRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const BlockScreen(),
        );
      case Routes.withdrawRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const WithdrawScreen(),
        );
      case Routes.changeEmail:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const ChangeEmailScreen(),
        );
      case Routes.changePhoneNumber:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const ChangePhoneNumberScreen(),
        );

      case Routes.blockedUsersRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const BlockedUsersScreen(),
        );

      case Routes.referredRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const ReferredScreen(),
        );
      case Routes.walletHistoryRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const WalletHistoryScreen(),
        );
      case Routes.privacyPolicyRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const PrivacyPolicyScreen(),
        );
      case Routes.disclaimerRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const DisclaimerScreen(),
        );
      case Routes.protectionAndSafetyRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const ProtectionAndSafety(),
        );
      case Routes.termsAndConditionsRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const TermsAndConditions(),
        );
      case Routes.contactUsRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const ContactUsScreen(),
        );
      case Routes.howToUseTrocoRoute:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => const HowToUseTroco(),
        );
      case Routes.walletTransactionRoute:
        final walletTransaction = routeSettings.arguments as WalletTransaction;
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) =>
              WalletTransactionScreen(walletTransaction: walletTransaction),
        );

      default:
        return MaterialPageRoute(
            settings: routeSettings,
            builder: (context) => const SplashScreen());
    }
  }
}
