// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/basecomponents/images/profile-icon.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/transactions/domain/repository/create-transaction-repo.dart';
import 'package:troco/features/transactions/presentation/widgets/transaction-pin-widget.dart';

import '../../../../core/app/color-manager.dart';
import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/button/presentation/provider/button-provider.dart';
import '../../../../core/basecomponents/button/presentation/widget/button.dart';
import '../../../groups/domain/entities/group.dart';
import '../../data/models/create-transaction-data-holder.dart';
import '../../domain/entities/transaction.dart';
import 'create-transaction-progress-screen.dart';

class TransactionFinalizePage extends ConsumerStatefulWidget {
  const TransactionFinalizePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPreviewPageState();
}

class _TransactionPreviewPageState
    extends ConsumerState<TransactionFinalizePage> {
  final textStyle = TextStyle(
      color: ColorManager.primary,
      fontFamily: 'quicksand',
      fontSize: FontSizeManager.medium,
      fontWeight: FontWeightManager.semibold);
  final buttonKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.large, right: SizeManager.large),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              groupProfileIcon(),
              mediumSpacer(),
              groupName(),
              mediumSpacer(),
              detailText(),
              extraLargeSpacer(),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget groupProfileIcon() {
    return const GroupProfileIcon(
      size: IconSizeManager.extralarge * 1.35,
    );
  }

  Widget groupName() {
    final group = (ModalRoute.of(context)!.settings.arguments! as Group);
    return Text(
      group.groupName,
      style: textStyle,
    );
  }

  Widget detailText() {
    final group = (ModalRoute.of(context)!.settings.arguments! as Group);
    return Text(
      "You're about to create a transaction in ${group.groupName}.\nNo fraudulent practices will be tolerated.",
      textAlign: TextAlign.center,
      style: textStyle.copyWith(
        height: 2,
        fontSize: FontSizeManager.regular * 0.85,
        color: ColorManager.secondary,
        fontWeight: FontWeightManager.medium,
      ),
    );
  }

  Widget button() {
    return CustomButton.medium(
      label: "Agree",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        await verifyPin();
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }

  Future<void> verifyPin() async {
    final verifyPin = await showModalBottomSheet<bool?>(
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: ColorManager.background,
      context: context,
      builder: (context) {
        return const SingleChildScrollView(child: TransactionPinSheet());
      },
    );

    if (verifyPin ?? false) {
      // createTransaction();
      Navigator.push(
          context,
          MaterialPageRoute(
            settings:
                RouteSettings(arguments: ModalRoute.of(context)!.settings),
            builder: (context) => const CreateTransactonProgressScreen(),
          ));
    }
  }

  Future<void> createTransaction() async {
    final group = ModalRoute.of(context)!.settings.arguments! as Group;

    Transaction transaction = Transaction.fromJson(json: {
      "transactionName": TransactionDataHolder.transactionName!,
      "aboutService": TransactionDataHolder.aboutProduct!,
      "inspectionDays": TransactionDataHolder.inspectionDays!,
      "inspectionPeriod":
          TransactionDataHolder.inspectionPeriod! ? "day" : "hour",
      "transaction category":
          TransactionDataHolder.transactionCategory!.name.toLowerCase(),
      "DateOfWork": "2024-04-24T10:00:00Z",
    });

    final response = await CreateTransactionRepo.createTransaction(
        groupId: group.groupId, transaction: transaction);

    if (response.error) {
      log(response.body);
    } else {
      final transactionJson = response.messageBody!["data"];
      addProducts(transaction: Transaction.fromJson(json: transactionJson));
    }
  }

  Future<void> addProducts({required final Transaction transaction}) async {
    final group = ModalRoute.of(context)!.settings.arguments! as Group;
    final products = TransactionDataHolder.products!;
    for (final product in products) {
      final response = await CreateTransactionRepo.createPricing(
          transactionId: transaction.transactionId,
          groupId: group.groupId,
          buyerId: group.members
              .firstWhere(
                  (element) => element.toString() != transaction.creator)
              .toString(),
          product: product);

      if (response.error) {
        log("Error:${response.body}");
      } else {
        if (products.last == product) {
          log("Success: ${response.messageBody!.toString()}");
        }
      }
    }
  }
}
