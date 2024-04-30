import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timelines/timelines.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import '../../../../../core/basecomponents/others/spacer.dart';
import '../../../data/models/process-model.dart';
import '../../../domain/entities/transaction.dart';
import '../../../utils/enums.dart';

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

  @override
  void initState() {
    transaction = widget.transaction;
    timelines = timeline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.maxFinite,
        color: ColorManager.background,
        padding: const EdgeInsets.symmetric(horizontal: SizeManager.extralarge),
        child: FixedTimeline.tileBuilder(
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
            mediumSpacer(),
            subTimelineWidget(subProcesses: process.subProcesses),
          ],
        ));
  }

  Widget subTimelineWidget({required final List<SubProcess> subProcesses}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
      child: FixedTimeline.tileBuilder(
        theme: TimelineTheme.of(context).copyWith(
            nodePosition: 0,
            connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
                  thickness: 1.0,
                ),
            indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
                  size: 10.0,
                  position: 0.5,
                ),
            direction: Axis.vertical,
            color: ColorManager.accentColor),
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
                            : ColorManager.secondary.withOpacity(0.4),
                        fontSize: FontSizeManager.small * 1.1,
                        fontFamily: 'quicksand')),
              );
            },
            itemExtentBuilder: (context, index) =>
                index == 0 || index == subProcesses.length - 1 ? 20 : 30,
            nodeItemOverlapBuilder: (context, index) =>
                index == 0 || index == subProcesses.length - 1 ? true : null,
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
        Process(message: "Acceptance Of Terms.", subProcesses: [
      SubProcess(
          message: "seller created transaction",
          done: transaction.transactionStatus != TransactionStatus.Cancelled),
      SubProcess(
          message: "buyer approved transaction",
          done: transaction.transactionStatus != TransactionStatus.Pending),
      SubProcess(
          message: "admin approved transaction",
          done: completedAcceptanceOfTerms()),
    ]);

    Process paymentOfTransaction = Process(
        message: "Payment of ${transaction.transactionCategory.name}",
        subProcesses: [
          SubProcess(
              message: "buyer makes payment", done: transaction.paymentDone),
          SubProcess(
              message: "seller uploaded driver details",
              done: transaction.hasDriver &&
                  transaction.transactionStatus == TransactionStatus.Ongoing),
          SubProcess(
              message: "seller has sent the driver",
              done: transaction.hasDriver
                  ? transaction.driver.checkedOut
                  : false),
        ]);

    Process deliveryOfTransaction = Process(
        message: "Delivery of ${transaction.transactionCategory.name}",
        subProcesses: [
          SubProcess(
              message: "driver delivers product",
              done: transaction.transactionStatus ==
                  TransactionStatus.Finalizing),
          SubProcess(
              message: "buyer recieves product",
              done: transaction.transactionStatus ==
                  TransactionStatus.Finalizing),
        ]);

    Process acceptanceOfProducts = Process(
        message: "Acceptance of ${transaction.transactionCategory.name}",
        subProcesses: [
          SubProcess(
              message: "buyer satisfied with product",
              done:
                  transaction.transactionStatus == TransactionStatus.Completed),
          SubProcess(
              message: "troco pays seller",
              done:
                  transaction.transactionStatus == TransactionStatus.Completed),
        ]);
    Process completed =
        Process(message: "Completed Transaction", subProcesses: [
      SubProcess(
          message: "transaction is completed",
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
    final status = transaction.transactionStatus;

    List<TransactionStatus> criterias = [
      TransactionStatus.Pending,
      TransactionStatus.Inprogress,
      TransactionStatus.Processing,
    ];

    return criterias.contains(status) && transaction.hasAdmin;
  }
}
