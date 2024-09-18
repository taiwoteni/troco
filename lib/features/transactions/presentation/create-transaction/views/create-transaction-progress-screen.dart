// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/core/components/animations/lottie.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/api/data/model/response-model.dart';
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

class _CreateTransactonProgressScreenState
    extends ConsumerState<CreateTransactonProgressScreen> {
  late Group group;
  late List<SalesItem> pricings;
  double value = 0.0;
  double maxValue = 0.0;
  bool canPop = false;
  bool error = false;
  String errorMessage = "An unknown error occurred.";

  @override
  void initState() {
    pricings = List.from(TransactionDataHolder.items ?? []);
    final bool transactionAlreadyCreated = TransactionDataHolder.id != null;
    if (transactionAlreadyCreated) {
      group = AppStorage.getGroups()
          .firstWhere((element) => element.groupId == TransactionDataHolder.id);
    }

    maxValue = pricings.length + 1;
    super.initState();
    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      if (!transactionAlreadyCreated) {
        setState(() {
          group = ModalRoute.of(context)!.settings.arguments! as Group;
        });

        if (group.hasTransaction) {
          TransactionDataHolder.id = group.groupId;
        }
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
            child: error
                ? errorWidget()
                : Column(
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

  Widget errorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LottieWidget(
            lottieRes: AssetManager.lottieFile(name: "error"),
            size: const Size.square(IconSizeManager.extralarge * 2)),
        mediumSpacer(),
        Text(
          errorMessage,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'Quicksand',
              fontWeight: FontWeightManager.medium,
              fontSize: FontSizeManager.regular * 1.1),
        ),
        regularSpacer(),
        GestureDetector(
          onTap: createTransaction,
          child: Text(
            "Retry?",
            style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'lato',
              fontWeight: FontWeightManager.medium,
              fontSize: FontSizeManager.regular * 1.1,
              decorationColor: ColorManager.accentColor,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
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
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: 'quicksand',
          fontSize: FontSizeManager.regular * 0.85,
          color: !error ? ColorManager.secondary : Colors.redAccent,
          fontWeight: FontWeightManager.medium),
    );
  }

  Future<void> createTransaction() async {
    setState(() {
      error = false;
    });
    // This means a transaction has been created but it wasn't successful
    // We get the transaction
    // So we carry on and just add pricing
    try {
      if (TransactionDataHolder.id != null) {
        debugPrint("Transaction Already Exists");
        final transactionId = TransactionDataHolder.id!;

        final response = await TransactionRepo.getOneTransaction(
            transactionId: transactionId);
        log("Fetching Transaction :${response.body}");
        if (response.error) {
          setState(() {
            error = true;
          });
        } else {
          setState(() {
            if (value == 0) {
              value = 1;
            }
          });
          Transaction transaction =
              Transaction.fromJson(json: response.messageBody!["data"]);
          await carryOn(transaction: transaction);
        }
      } else {
        Transaction transaction = Transaction.fromJson(json: {
          "transactionName": TransactionDataHolder.transactionName!,
          "aboutService": TransactionDataHolder.aboutProduct!,
          "location": TransactionDataHolder.location,
          "inspectionDays": TransactionDataHolder.inspectionDays!,
          "inspectionPeriod":
              TransactionDataHolder.inspectionPeriod! ? "day" : "hour",
          "transaction category":
              TransactionDataHolder.transactionCategory!.name.toLowerCase(),
        });

        final dateOffWork = DateFormat("dd/MM/yyyy").parse(TransactionDataHolder
                .date ??
            DateFormat("dd/MM/yyyy")
                .format(TransactionDataHolder.inspectionPeriodToDateTime()!));

        final response = await TransactionRepo.createTransaction(
            dateOfWork:
                transaction.transactionCategory == TransactionCategory.Service
                    ? TransactionDataHolder.inspectionPeriodToDateTime()!
                        .toIso8601String()
                    : TransactionDataHolder.date == null
                        ? group.transactionTime.toIso8601String()
                        : dateOffWork.toIso8601String(),
            groupId: group.groupId,
            transaction: transaction);
        log("Creating Transaction :${response.body}");

        if (response.error) {
          setState(() {
            error = true;
            errorMessage = response.messageBody?["message"]
                        .toString()
                        .contains("duplicat") ??
                    false
                ? "Transaction already exists."
                : "An unknown error occurred.";
          });
          log(response.body);
        } else {
          setState(() {
            if (value == 0) {
              value = 1;
            }
          });
          TransactionDataHolder.id = response.messageBody!["data"]["_id"];
          await carryOn(
              transaction:
                  Transaction.fromJson(json: response.messageBody!["data"]));
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      setState(
        () {
          errorMessage = "Error occurred when creating transaction";
          error = true;
        },
      );
    }
  }

  Future<void> carryOn({required Transaction transaction}) async {
    //
    // setState(() {
    //   value += 1;
    // });
    // final addedPricing = await addPricing(transaction: transaction);
    // if (addedPricing) {
    //   TransactionDataHolder.clear();
    //   Navigator.pushNamed(context, Routes.transactionSuccessRoute);
    // } else {
    //   setState(() {
    //     error = true;
    //     errorMessage =
    //         "Error occurred when adding ${transaction.pricingName}s.";
    //   });
    // }

    try {
      final futures = addPricingTasks(transactionId: transaction.transactionId);
      final successfulPricings = await futures;

      TransactionDataHolder.clear(ref: ref);
      Navigator.pushNamed(context, Routes.transactionSuccessRoute);
    } catch (e) {
      debugPrint(e.toString());
      setState(
        () {
          errorMessage = "Error occurred when uploading items";
          error = true;
        },
      );
    }
  }

  Future<HttpResponseModel> addPricingItem(
      {required final String transactionId,
      required final SalesItem item}) async {
    final response = await TransactionRepo.createPricing(
        type: TransactionDataHolder.transactionCategory!,
        transactionId: transactionId,
        group: group,
        item: item);
    debugPrint(response.body);

    if (response.error) {
      throw Exception("Error occurred when uploading pricing: ${item.name}");
    }

    return response;
  }

  /// Method that
  Future<List<HttpResponseModel>> addPricingTasks(
      {required final String transactionId}) async {
    final list = <HttpResponseModel>[];
    for (final pricing in pricings) {
      final response =
          await addPricingItem(transactionId: transactionId, item: pricing);

      // The remaining line would execute if no error was thrown
      TransactionDataHolder.items!.remove(pricing);
      setState(() => value += 1);
      list.add(response);
    }
    return list;
    // return pricings.map(
    //   (e) {
    //     return addPricingItem(transactionId: transactionId, item: e)
    //         .onError<Exception>(
    //       (error, stackTrace) {
    //         throw error;
    //       },
    //     ).then<HttpResponseModel>(
    //       (response) {
    //         if (!response.error) {
    //           TransactionDataHolder.items!.remove(e);
    //           setState(() => value += 1);
    //         }
    //
    //         return response;
    //       },
    //     );
    //   },
    // ).toList();
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
      debugPrint("Ended process ${i + 1} :${response.body}");

      if (!response.error) {
        TransactionDataHolder.items!.removeAt(0);
        // if (value + 1 == maxValue) {
        //   setState(() {
        //     value += 1;
        //   });
        //   log("Successfully added all pricings");
        //   return true;
        // }
        successful += 1;
        setState(() {
          value += 1;
        });
      }
    }
    setState(() {
      error = successful != items.length - 1;
    });
    return successful == items.length - 1;
  }
}
