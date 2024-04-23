import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';

import '../../../groups/domain/entities/group.dart';
import '../../data/models/create-transaction-data-holder.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repository/create-transaction-repo.dart';

class CreateTransactonProgressScreen extends ConsumerStatefulWidget {
  const CreateTransactonProgressScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTransactonProgressScreenState();
}

class _CreateTransactonProgressScreenState extends ConsumerState<CreateTransactonProgressScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp)async{
      createTransaction();
    });
    
  }

  double value = 0.0;
  bool canPop = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
      },
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
              valueColor: AlwaysStoppedAnimation(ColorManager.accentColor),
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
              color: ColorManager.accentColor,
              fontSize: FontSizeManager.large,
              fontWeight: FontWeightManager.semibold),
        )
      ],
    );
  }

  Widget descriptionText() {
    final products = TransactionDataHolder.products!;
    String text = "Creating Transaction...";

    if(value >= 1/(products.length+1)){
      final productNo = (value * (products.length + 1)).toInt();
      text = "Adding Product $productNo...";
    }
    return Text(
      text,
      style: TextStyle(
          fontFamily: 'quicksand',
          fontSize: FontSizeManager.regular * 0.85,
          color: ColorManager.secondary,
          fontWeight: FontWeightManager.medium),
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
      "DateOfWork": "2024-04-24T10:00:00Z",
    });

    final response = await CreateTransactionRepo.createTransaction(
        groupId: group.groupId, transaction: transaction);

    if (response.error) {
      log(response.body);
    } else {
      final products = TransactionDataHolder.products!;
      setState(() {
        value = 1/(products.length+1);
      });
      final transactionJson = response.messageBody!["data"];
      addProducts(transaction: Transaction.fromJson(json: transactionJson));
    }
  }

  Future<void> addProducts({required final Transaction transaction}) async {
    final group = ModalRoute.of(context)!.settings.arguments! as Group;
    final products = TransactionDataHolder.products!;
    for (final product in products) {
      setState(() {
          value += 1/(products.length+1);
          canPop = value==1;
        });
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
