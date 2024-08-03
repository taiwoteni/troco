// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
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

class _CreateTransactonProgressScreenState extends ConsumerState<CreateTransactonProgressScreen> {
  late Group group;

  @override
  void initState() {
    final bool transactionAlreadyCreated = TransactionDataHolder.id != null;
    if(transactionAlreadyCreated){
      group = AppStorage.getGroups().firstWhere((element) => element.groupId == TransactionDataHolder.id);
    }
    maxValue = TransactionDataHolder.items!.length + 1;
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
          if(!transactionAlreadyCreated){
            setState((){
    group = ModalRoute.of(context)!.settings.arguments! as Group;

          });
          }
          
      createTransaction();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    super.setState(fn);
  }

  double value = 0.0;
  double maxValue = 0.0;
  bool canPop = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
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
              value: value / maxValue,
              strokeWidth: 2.5,
            ),
          ),
        ),
        Text(
          "${(value / maxValue * 100).toInt()}%",
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
    String text = "Creating Transaction...";

    if (value > 0) {
      final itemNo = value.toInt();
      text =
          "Adding ${TransactionDataHolder.transactionCategory!.name + (TransactionDataHolder.transactionCategory! == TransactionCategory.Virtual ? " Service" : "")} $itemNo...";
    }
    if (value == maxValue) {
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
    // This means a transaction has been created but it wasn't successful
    // We get the transaction
    // So we carry on and just add pricing
    if (TransactionDataHolder.id != null) {
      final transactionId = TransactionDataHolder.id!;

      final response =
          await TransactionRepo.getOneTransaction(transactionId: transactionId);
      log("Fetching Transaction :${response.body}");
      if (response.error) {
        setState(() {
          error = true;
        });
      } else {
        Transaction transaction =
            Transaction.fromJson(json: response.messageBody!["data"]);
        await carryOn(transaction: transaction);
      }
    } else {
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
      log("Creating Transaction :${response.body}");

      if (response.error) {
        setState(() {
          error = true;
        });
        log(response.body);
      } else {
        TransactionDataHolder.id = response.messageBody!["data"]["_id"];
        await carryOn(
            transaction:
                Transaction.fromJson(json: response.messageBody!["data"]));
      }
    }
  }

  Future<void> carryOn({required Transaction transaction}) async {
    setState(() {
      value += 1;
    });

    final addedPricing = await addPricing(transaction: transaction);
    if (addedPricing) {
      TransactionDataHolder.clear();
      Navigator.pushNamed(context, Routes.transactionSuccessRoute);
    } else {
      setState(() => error = true);
    }
  }

  Future<bool> addPricing({required final Transaction transaction}) async {
    final items = List<SalesItem>.from(TransactionDataHolder.items!);
    log(items.length.toString());
    int successful = 0;
    for (int i = 0; i < items.length; i++) {
      log("Adding pricing ${i + 1}");
      final item = items[i];
      final response = await TransactionRepo.createPricing(
          type: TransactionDataHolder.transactionCategory!,
          transactionId: transaction.transactionId,
          group: group,
          item: item);
      log("Ended process ${i + 1} :${response.body}");

      if (!response.error) {
        TransactionDataHolder.items!.removeAt(0);
        if (value + 1 == maxValue) {
          setState(() {
            value += 1;
          });
          log("Successfully added all pricings");
          return true;
        }
        successful += 1;
        setState(() {
          value += 1;
        });
      }
    }
    setState(() {
      error = successful == items.length - 1;
    });
    return error;
  }

}
