// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/others/spacer.dart';

import '../../../../../core/app/routes-manager.dart';
import '../../../../groups/domain/entities/group.dart';
import '../../../data/models/create-transaction-data-holder.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repository/transaction-repo.dart';

class CreateTransactonProgressScreen extends ConsumerStatefulWidget {
  const CreateTransactonProgressScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTransactonProgressScreenState();
}

class _CreateTransactonProgressScreenState
    extends ConsumerState<CreateTransactonProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      createTransaction();
    });
  }

  double value = 0.0;
  bool canPop = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop || error,
      onPopInvoked: (didPop) {},
      child: Scaffold(
          backgroundColor: ColorManager.background,
          body: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.center,
            color: ColorManager.background,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                progressWidget(),
                mediumSpacer(),
                regularSpacer(),
                descriptionText(),
              ],
            ),
          )),
    );
  }

  Widget progressWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.square(
          dimension: IconSizeManager.extralarge * 1.5,
          child: FittedBox(
            child: CircularProgressIndicator(
              backgroundColor: ColorManager.tertiary,
              valueColor: AlwaysStoppedAnimation(
                  error ? Colors.redAccent : ColorManager.accentColor),
              value: value,
              strokeWidth: 2.5,
            ),
          ),
        ),
        Text(
          "${(value * 100).toInt()}%",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "quicksand",
              color: error ? Colors.redAccent : ColorManager.accentColor,
              fontSize: FontSizeManager.large,
              fontWeight: FontWeightManager.semibold),
        )
      ],
    );
  }

  Widget descriptionText() {
    final items = TransactionDataHolder.items ?? [];
    String text = "Creating Transaction...";

    if (value >= 1 / (items.length + 1)) {
      final itemNo = (value * (items.length + 1)).toInt() - 1;
      text = "Adding Product $itemNo...";
    }
    if (value == 1 || items.isEmpty) {
      text = "Created transaction !";
    }
    if (error) {
      text = "Error occurred.\nCheck your internet.";
    }
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'quicksand',
            fontSize: FontSizeManager.regular * 0.85,
            color: !error ? ColorManager.secondary : Colors.redAccent,
            fontWeight: FontWeightManager.medium),
      ),
    );
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
    });
    final day = TransactionDataHolder.date!.substring(0, 2).padLeft(2, '0');
    final month = TransactionDataHolder.date!.substring(3, 5).padLeft(2, '0');
    final year = TransactionDataHolder.date!.substring(6, 10);

    final response = await TransactionRepo.createTransaction(
        dateOfWork: "$year-$month-${day}T00:00:00Z",
        groupId: group.groupId,
        transaction: transaction);
      log(response.body);


    if (response.error) {
      setState(() {
        error = true;
      });
      log(response.body);
    } else {
      final products = TransactionDataHolder.items!;
      setState(() {
        value = 1 / (products.length + 1);
      });
      final transactionJson = response.messageBody!["data"];
      await addPricing(
          transaction: Transaction.fromJson(json: transactionJson));
    }
  }

  Future<void> addPricing({required final Transaction transaction}) async {
    final group = ModalRoute.of(context)!.settings.arguments! as Group;
    final items = TransactionDataHolder.items!;
    for (final item in items) {
      setState(() {
        value += 1 / (items.length + 1);
        canPop = value == 1;
      });
      final response = await TransactionRepo.createPricing(
        type: transaction.transactionCategory,
          transactionId: transaction.transactionId,
          groupId: group.groupId,
          buyerId: group.buyer!.userId,
          item: item);
      log(response.body);    

      if (response.error) {
        log("Error:${response.body}");
        setState(() {
          error = true;
        });
        break;
      } else {
        if (items.last == item) {
          setState(() {
            error = false;
          });
          log("Success: ${response.messageBody!.toString()}");
        }
      }
    }
    // ref.read(createTransactionProgressProvider.notifier).state = 0;
    Navigator.pushNamed(context, Routes.transactionSuccessRoute);
    TransactionDataHolder.clear();
  }
}
