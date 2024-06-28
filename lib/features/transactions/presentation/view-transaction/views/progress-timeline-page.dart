import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:timelines/timelines.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../data/models/process-model.dart';
import '../../../domain/entities/transaction.dart';
import '../../../utils/enums.dart';
import '../providers/transactions-provider.dart';

class ProgressTimelinePage extends ConsumerStatefulWidget {
  final Transaction transaction;
  const ProgressTimelinePage({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProgressTimelinePageState();
}

class _ProgressTimelinePageState extends ConsumerState<ProgressTimelinePage> {
  late Transaction transaction;
  late List<Process> timelines;
  final double minPerfectScreenWidth = 337.0;

  @override
  void initState() {
    transaction = widget.transaction;
    timelines = timeline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log(MediaQuery.of(context).size.width.toString());
    listenToTransactionsChanges();
    return Container(
        width: double.maxFinite,
        color: ColorManager.background,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
        child: SingleChildScrollView(
          child: Column(
            children: [
              mediumSpacer(),
              FixedTimeline.tileBuilder(
                mainAxisSize: MainAxisSize.min,
                theme: TimelineThemeData(
                    indicatorTheme: const IndicatorThemeData(
                      position: 0,
                      size: 20.0,
                    ),
                    connectorTheme: const ConnectorThemeData(
                      thickness: 2.5,
                    ),
                    direction: Axis.vertical,
                    color: ColorManager.accentColor),
                builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.after,
                    oppositeContentsBuilder: (context, index) => const SizedBox(
                          width: 0,
                          height: 0,
                        ),
                    nodePositionBuilder: (context, index) => 0,
                    contentsAlign: ContentsAlign.basic,
                    contentsBuilder: (context, index) {
                      return timeLineWidget(process: timelines[index]);
                    },
                    connectorBuilder: (context, index, type) {
                      final process = timelines[index];
                      return Connector.solidLine(
                        color: process.completed
                            ? ColorManager.accentColor
                            : ColorManager.secondary.withOpacity(0.2),
                      );
                    },
                    indicatorBuilder: (context, index) {
                      final process = timelines[index];
                      if (!process.completed) {
                        if (index == 0) {
                          return DotIndicator(
                            color: ColorManager.accentColor,
                          );
                        }
                        if (timelines[index - 1].completed) {
                          return DotIndicator(
                            color: ColorManager.accentColor,
                          );
                        }
                        return OutlinedDotIndicator(
                          borderWidth: 2.5,
                          color: ColorManager.secondary.withOpacity(0.3),
                        );
                      }
                      return DotIndicator(
                        color: ColorManager.accentColor,
                        child: Icon(
                          Icons.check_rounded,
                          size: IconSizeManager.small * 0.9,
                          color: ColorManager.primaryDark,
                        ),
                      );
                    },
                    itemCount: timelines.length),
              ),
              mediumSpacer(),
            ],
          ),
        ));
  }

  Widget timeLineWidget({required final Process process}) {
    return Container(
        width: double.maxFinite,
        color: ColorManager.background,
        padding: const EdgeInsets.only(left: SizeManager.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              process.message,
              style: titleTextStyle(),
            ),
            regularSpacer(),
            subTimelineWidget(subProcesses: process.subProcesses),
            regularSpacer()
          ],
        ));
  }

  Widget subTimelineWidget({required final List<SubProcess> subProcesses}) {
    final overflowing =
        MediaQuery.of(context).size.width < minPerfectScreenWidth;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
      child: FixedTimeline.tileBuilder(
        builder: TimelineTileBuilder(
            nodePositionBuilder: (context, index) => 0,
            contentsAlign: ContentsAlign.basic,
            startConnectorBuilder: (_, index) => Connector.solidLine(),
            endConnectorBuilder: (_, index) => Connector.solidLine(),
            contentsBuilder: (context, index) {
              final subProcess = subProcesses[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: SizeManager.medium),
                child: Text(subProcess.message,
                    style: TextStyle(
                        color: subProcess.done
                            ? ColorManager.accentColor
                            : ColorManager.secondary.withOpacity(0.5),
                        fontSize: FontSizeManager.small * 1.1,
                        fontWeight: FontWeightManager.medium,
                        fontFamily: 'quicksand')),
              );
            },
            themeBuilder: (context, index) {
              final subProcess = subProcesses[index];

              return TimelineTheme.of(context).copyWith(
                  nodePosition: 0,
                  connectorTheme: TimelineTheme.of(context)
                      .connectorTheme
                      .copyWith(
                          thickness: 1.0,
                          color: subProcess.done
                              ? ColorManager.accentColor
                              : ColorManager.secondary.withOpacity(0.4)),
                  indicatorTheme:
                      TimelineTheme.of(context).indicatorTheme.copyWith(
                            size: 10.0,
                            position: 0.5,
                          ),
                  direction: Axis.vertical,
                  color: ColorManager.accentColor);
            },
            itemExtentBuilder: (context, index) =>
                index == 0 || index == subProcesses.length - 1
                    ? overflowing
                        ? 40
                        : 30
                    : overflowing
                        ? 50
                        : 40,
            nodeItemOverlapBuilder: (context, index) => false,
            indicatorBuilder: (context, index) {
              final subProcess = subProcesses[index];
              if (!subProcess.done) {
                return DotIndicator(
                  color: ColorManager.secondary.withOpacity(0.4),
                );
              }
              return DotIndicator(
                color: ColorManager.accentColor,
                // child: Icon(
                //   Icons.check_rounded,
                //   size: IconSizeManager.small * 0.9,
                //   color: ColorManager.primaryDark,
                // ),
              );
            },
            itemCount: subProcesses.length),
      ),
    );
  }

  TextStyle titleTextStyle() {
    return TextStyle(
        color: ColorManager.primary,
        fontFamily: 'quicksand',
        fontSize: FontSizeManager.medium,
        fontWeight: FontWeightManager.semibold);
  }

  List<Process> timeline() {
    Process acceptanceOfTerms =
        Process(message: "Acceptance Of Terms", subProcesses: [
      SubProcess(
          message: "Seller created transaction",
          done: transaction.transactionStatus != TransactionStatus.Cancelled),
      SubProcess(
          message: "Buyer approved transaction",
          done: completedAcceptanceOfTerms()),
    ]);

    List<TransactionStatus> paymentStatus = [
      TransactionStatus.Ongoing,
      TransactionStatus.Processing,
      TransactionStatus.Finalizing,
      TransactionStatus.Completed,
    ];

    Process paymentOfTransaction = Process(
        message: "Payment of ${transaction.transactionCategory.name}",
        subProcesses: [
          SubProcess(
              message: "Buyer makes payment", done: transaction.paymentDone),
          SubProcess(
              message: "Admin approves payment",
              done: transaction.adminApprovesPayment),
          SubProcess(
              message: "Seller uploaded driver details",
              done: transaction.hasDriver),
          SubProcess(
              message: "Admin approves driver details",
              done: transaction.hasDriver &&
                  paymentStatus.contains(transaction.transactionStatus)),
          SubProcess(
              message: "Seller sends the driver", done: transaction.hasDriver)
        ]);

    var deliveryStatus = <TransactionStatus>[
      TransactionStatus.Finalizing,
      TransactionStatus.Completed,
    ];
    final category = transaction.transactionCategory.name.toLowerCase();
    Process deliveryOfTransaction =
        Process(message: "Delivery of ${category.titleCase}", subProcesses: [
      SubProcess(
          message: "Driver delivers $category",
          done: deliveryStatus.contains(transaction.transactionStatus)),
      SubProcess(
          message: "Buyer recieves $category",
          done: deliveryStatus.contains(transaction.transactionStatus)),
    ]);

    //TODO: VALUE TO KNOW WHEN BUYER IS SATISFIED WITH PRODUCT.

    Process acceptanceOfProducts = Process(
        message: "Acceptance of ${transaction.transactionCategory.name}",
        subProcesses: [
          SubProcess(
              message: "Buyer is satisfied with $category",
              done: transaction.buyerSatisfied),
          SubProcess(
              message: "Troco pays seller", done: transaction.trocoPaysSeller),
        ]);
    Process completed =
        Process(message: "Completed Transaction", subProcesses: [
      SubProcess(
          message: "Seller confirms payment",
          done: transaction.transactionStatus == TransactionStatus.Completed),
      SubProcess(
          message: "Transaction is completed",
          done: transaction.transactionStatus == TransactionStatus.Completed),
    ]);

    return [
      acceptanceOfTerms,
      paymentOfTransaction,
      deliveryOfTransaction,
      acceptanceOfProducts,
      completed
    ];
  }

  bool completedAcceptanceOfTerms() {
    return transaction.transactionStatus != TransactionStatus.Pending &&
        transaction.transactionStatus != TransactionStatus.Cancelled;
  }

  Future<void> listenToTransactionsChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        if (value
            .map((t) => t.transactionId)
            .contains(transaction.transactionId)) {
          final t = value.firstWhere(
              (tr) => tr.transactionId == transaction.transactionId);
          setState(() {
            transaction = t;
          });
        }
      });
    });
  }
}
