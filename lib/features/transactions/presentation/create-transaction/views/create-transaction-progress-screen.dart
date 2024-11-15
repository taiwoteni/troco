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
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/service.dart' as s;
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/product-images-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/api/data/model/response-model.dart';
import '../../../../../core/app/routes-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../groups/domain/entities/group.dart';
import '../../../data/models/create-transaction-data-holder.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repository/transaction-repo.dart';
import '../../view-transaction/providers/ction-screen-provider.dart';
import '../providers/create-transaction-provider.dart';

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
  late bool isEdit;
  double value = 0.0;
  double maxValue = 0.0;
  bool canPop = false;
  bool error = false;
  String errorMessage = "An unknown error occurred.";

  @override
  void initState() {
    /// We make a copy of the pricings (sales items) from the static class..
    /// Used to store currently-created transaction data locally.
    pricings = List.from(TransactionDataHolder.items ?? []);
    final bool transactionAlreadyCreated = TransactionDataHolder.id != null;

    isEdit = TransactionDataHolder.isEditing == true;

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
    String text = isEdit ? "Editing Transaction..." : "Creating Transaction...";

    if (value > 0) {
      final itemNo = value.toInt();
      final editingItem =
          pricings.elementAtOrNull(itemNo - 1)?.isEditing() ?? false;
      text =
          "${editingItem ? "Editing" : "Creating"} ${TransactionDataHolder.transactionCategory!.name + (TransactionDataHolder.transactionCategory! == TransactionCategory.Virtual ? " Service" : "")} $itemNo...";
    }
    if (value == maxValue) {
      text = isEdit ? "Editing Transaction !" : "Created transaction !";
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

  Future<void> editOrCreateTransaction() async {
    Transaction transaction = Transaction.fromJson(json: {
      "transactionName": TransactionDataHolder.transactionName!,
      "aboutService": TransactionDataHolder.aboutProduct!,
      "location": TransactionDataHolder.location,
      "inspectionDays": TransactionDataHolder.inspectionDays!,
      "inspectionPeriod":
          TransactionDataHolder.inspectionPeriod?.name.toLowerCase(),
      "transaction category":
          TransactionDataHolder.transactionCategory!.name.toLowerCase(),
    });
    final dateOfWork = transaction.transactionCategory ==
            TransactionCategory.Service
        ? TransactionDataHolder.inspectionPeriodToDateTime()!.toIso8601String()
        : TransactionDataHolder.date == null
            ? group.transactionTime.toIso8601String()
            : DateFormat("dd/MM/yyyy")
                .parse(TransactionDataHolder.date!)
                .toIso8601String();

    final response = await (isEdit
        ? TransactionRepo.editTransaction(
            dateOfWork: dateOfWork,
            groupId: group.groupId,
            transaction: transaction)
        : TransactionRepo.createTransaction(
            dateOfWork: dateOfWork,
            groupId: group.groupId,
            transaction: transaction));
    log("${isEdit ? "Editing" : "Creating"} Transaction :${response.body}");

    if (response.error) {
      setState(() {
        error = true;
        errorMessage =
            response.messageBody?["message"].toString().contains("duplicat") ??
                    false
                ? "Transaction already exists."
                : "An unknown error occurred.";
      });
      log(response.body);

      return;
    }

    setState(() {
      if (value == 0) {
        value = 1;
      }
    });

    if (!isEdit) {
      TransactionDataHolder.id = response.messageBody!["data"]["_id"];
    }

    await carryOn(transactionId: TransactionDataHolder.id!);
  }

  Future<void> getTransaction() async {
    final transactionId = TransactionDataHolder.id!;
    debugPrint("Transaction Already Exists");

    final response =
        await TransactionRepo.getOneTransaction(transactionId: transactionId);
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

      await carryOn(transactionId: response.messageBody!["data"]["_id"]);
    }
  }

  Future<void> createTransaction() async {
    setState(() {
      error = false;
    });

    try {
      if (!isEdit && TransactionDataHolder.id != null) {
        // This means a transaction has been created but it wasn't successful
        // We get the transaction
        // So we carry on and just add pricing
        getTransaction();
      } else {
        /// This means we're either trying to create a transaction or edit it
        editOrCreateTransaction();
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

  Future<void> carryOn({required String transactionId}) async {
    debugPrint(
        'Removed Images: ${ref.read(removedImagesItemsProvider.notifier).state.toString()}');
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
      final futures = pricingTasks(transactionId: transactionId);
      final successfulPricings = await futures;

      if (successfulPricings.length >= pricings.length) {
        ref.watch(popTransactionScreen.notifier).state = true;
        ref.read(createTransactionProgressProvider.notifier).state = 0;
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.transactionSuccessRoute,
          ModalRoute.withName(
              isEdit ? Routes.viewTransactionRoute : Routes.chatRoute),
        );
      }
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

  SalesItem convertItem({required Map json}) {
    switch (TransactionDataHolder.transactionCategory) {
      case TransactionCategory.Service:
        return s.Service.fromJson(json: json);
      case TransactionCategory.Product:
        return Product.fromJson(json: json);
      default:
        return VirtualService.fromJson(json: json);
    }
  }

  Future<HttpResponseModel> addOrEditPricingItem(
      {required final String transactionId,
      required final SalesItem item}) async {
    final editing = item.isEditing();

    debugPrint("Id of Item ${pricings.indexOf(item) + 1}: ${item.id}");
    debugPrint("Editing Item ${pricings.indexOf(item) + 1}: $editing");

    var itemClone = item.toJson();
    if (item.isEditing()) {
      // We remove the images that have not changed (i.e) that's are urls.
      final pricingImage = ((itemClone['pricingImage'] ?? []) as List)
          .map(
            (e) => e.toString(),
          )
          .where((element) => !element.startsWith('http'))
          .toList();
      itemClone['pricingImage'] = pricingImage;

      if (ref.read(removedImagesItemsProvider.notifier).state.any(
            (element) => element['_id'] == item.id,
          )) {
        final imageRemovedItem =
            ref.read(removedImagesItemsProvider.notifier).state.firstWhere(
                  (element) => element['_id'] == item.id,
                );
        final removedImages = (imageRemovedItem['removedImages'] as List)
            .map(
              (e) => e.toString(),
            )
            .where(
              (element) => element.startsWith('http'),
            )
            .toList();

        itemClone['removedImages'] = removedImages;
      }

      // We add a `removedImages` attribute which is a list gotten from mapping
      // the id to that of the removedImagesProvider.
    }

    final itemResult = convertItem(json: itemClone);

    final response = await (editing
        ? TransactionRepo.editPricing(
            type: TransactionDataHolder.transactionCategory!,
            transactionId: transactionId,
            group: group,
            item: itemResult)
        : TransactionRepo.createPricing(
            type: TransactionDataHolder.transactionCategory!,
            transactionId: transactionId,
            group: group,
            item: item));
    debugPrint(response.body);

    if (response.error) {
      throw Exception("Error occurred when uploading pricing: ${item.name}");
    }

    return response;
  }

  /// Method that
  Future<List<HttpResponseModel>> pricingTasks(
      {required final String transactionId}) async {
    final list = <HttpResponseModel>[];
    for (final pricing in pricings) {
      final response = await addOrEditPricingItem(
          transactionId: transactionId, item: pricing);

      // The remaining line would execute if no error was thrown
      TransactionDataHolder.items!.remove(pricing);
      setState(() => value += 1);
      list.add(response);
    }
    return list;
  }

//   Future<bool> addPricing({required final Transaction transaction}) async {
//     final items = List<SalesItem>.from(TransactionDataHolder.items!);
//     log(items.length.toString());
//     int successful = 0;
//     for (int i = 0; i < items.length; i++) {
//       log("Adding pricing ${i + 1}");
//       final item = items[i];
//       final response = await TransactionRepo.createPricing(
//           type: TransactionDataHolder.transactionCategory!,
//           transactionId: transaction.transactionId,
//           group: group,
//           item: item);
//       debugPrint("Ended process ${i + 1} :${response.body}");
//
//       if (!response.error) {
//         TransactionDataHolder.items!.removeAt(0);
//         // if (value + 1 == maxValue) {
//         //   setState(() {
//         //     value += 1;
//         //   });
//         //   log("Successfully added all pricings");
//         //   return true;
//         // }
//         successful += 1;
//         setState(() {
//           value += 1;
//         });
//       }
//     }
//     setState(() {
//       error = successful != items.length - 1;
//     });
//     return successful == items.length - 1;
//   }
// }
}
