import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recase/recase.dart';
import 'package:timelines/timelines.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/font-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import 'package:troco/features/transactions/utils/service-role.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../data/models/process-model.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/virtual-service.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Inorder to listen to the current transaction's changes from the
    // stream provider listener put in place
    transaction = ref.watch(currentTransactionProvider);
    listenToTransactionsChanges();
    timelines = timeline();
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
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;

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
            itemExtentBuilder: (context, index) => (isVirtual || isService)
                ? 50
                : index == 0 || index == subProcesses.length - 1
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
    final isBuyer = transaction.transactionPurpose == TransactionPurpose.Buying;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;
    final isProduct = !isVirtual && !isService;

    final processes = <Process>[];

    final realCreatorIsClient = transaction.role == ServiceRole.Client;
    final name = realCreatorIsClient ? "Client" : "Developer";

    final oppName = name == "Client" ? "Developer" : "Client";

    // Acceptance of Terms
    Process acceptanceOfTerms =
        Process(message: "Acceptance Of Terms", subProcesses: [
      SubProcess(
          message: "${isService ? name : "Seller"} created transaction",
          done: transaction.transactionStatus != TransactionStatus.Cancelled),
      SubProcess(
          message:
              "${isService ? oppName : "Buyer"} ${isService ? "accepted terms and conditions" : "approved transaction"}",
          done: completedAcceptanceOfTerms()),
    ]);
    processes.add(acceptanceOfTerms);

    if (isProduct) {
      // Payment of Transaction
      List<TransactionStatus> paymentStatus = [
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
            if (transaction.hasReturnTransaction &&
                transaction.transactionCategory !=
                    TransactionCategory.Virtual) ...[
              SubProcess(
                  message:
                      "${isBuyer ? "Returning " : "Buyer returned"} ${transaction.returnItems.length} ${transaction.pricingName}${transaction.returnItems.length == 1 ? "" : "s"}",
                  done: transaction.hasReturnTransaction),
              SubProcess(
                  message: "Buyer uploaded returning driver details",
                  done: transaction.hasReturnTransaction)
            ],
            SubProcess(
                message: isVirtual
                    ? "Seller starts leading"
                    : "Seller uploads driver details",
                done: isVirtual
                    ? transaction.sellerStarteedLeading
                    : transaction.hasDriver),
            SubProcess(
                message: isVirtual
                    ? "Buyer accepts lead"
                    : "Admin approves driver details",
                done: isVirtual
                    ? transaction.leadStarted
                    : transaction.hasDriver &&
                        (paymentStatus
                                .contains(transaction.transactionStatus) ||
                            transaction.transactionStatus ==
                                TransactionStatus.Ongoing)),
            if (isVirtual)
              SubProcess(
                  message: "Inspection Started",
                  done: paymentStatus.contains(transaction.transactionStatus))
          ]);
      processes.add(paymentOfTransaction);

      // Delivery of Product
      var deliveryStatus = <TransactionStatus>[
        TransactionStatus.Finalizing,
        TransactionStatus.Completed,
      ];
      final category =
          transaction.transactionCategory == TransactionCategory.Product
              ? "Product"
              : "Service";
      Process deliveryOfTransaction =
          Process(message: "Delivery of ${category.titleCase}", subProcesses: [
        SubProcess(
            message:
                "Driver delivers ${transaction.hasReturnTransaction ? "returned" : ""} $category",
            done: deliveryStatus.contains(transaction.transactionStatus)),
        SubProcess(
            message: "Buyer receives $category",
            done: deliveryStatus.contains(transaction.transactionStatus)),
      ]);
      processes.add(deliveryOfTransaction);

      // Acceptance of Product
      Process acceptanceOfProducts = Process(
          message: "Acceptance of ${transaction.transactionCategory.name}",
          subProcesses: [
            SubProcess(
                message: "Buyer is satisfied with $category",
                done: transaction.buyerSatisfied),
            SubProcess(
                message: "Troco pays seller",
                done: transaction.transactionStatus ==
                    TransactionStatus.Completed),
          ]);
      processes.add(acceptanceOfProducts);
    }

    if (isService) {
      // process per task

      final services = transaction.salesItem.map((e) => e as Service).toList();

      final tasksProcesses = <Process>[];

      for (final task in services) {
        final index = services.indexOf(task) + 1;

        final process = Process(message: "Task $index", subProcesses: [
          SubProcess(
              message: "Buyer made payment for task $index",
              done: task.paymentMade),
          SubProcess(
              message: "Admin approved payment for task $index",
              done: task.approvePayment),
          SubProcess(
              message: "Developer uploaded proof of work for task $index",
              done: task.taskUploaded),
          SubProcess(
              message: "Client satisfied with developer's work",
              done: task.clientSatisfied),
          SubProcess(
              message: "Payment released to the developer's wallet",
              done: task.paymentReleased)
        ]);
        tasksProcesses.add(process);
      }
      processes.addAll(tasksProcesses);
    }

    if (isVirtual) {
      // process per task

      final virtualProducts =
          transaction.salesItem.map((e) => e as VirtualService).toList();

      final tasksProcesses = <Process>[];

      for (final task in virtualProducts) {
        final index = virtualProducts.indexOf(task) + 1;

        final process =
            Process(message: "Virtual-Product $index", subProcesses: [
          SubProcess(
              message: "Buyer made payment for product $index",
              done: task.paymentMade),
          SubProcess(
              message: "Admin approved payment for product $index",
              done: task.approvePayment),
          SubProcess(
              message:
                  "Seller uploaded required/specified document for product $index",
              done: task.documentsUploaded),
          SubProcess(
              message: "Buyer satisfied with seller's material",
              done: task.clientSatisfied),
          SubProcess(
              message: "Payment released to the seller's wallet",
              done: task.paymentReleased)
        ]);
        tasksProcesses.add(process);
      }
      processes.addAll(tasksProcesses);
    }

    Process completed =
        Process(message: "Completed Transaction", subProcesses: [
      SubProcess(
          message: "Transaction is completed",
          done: transaction.transactionStatus == TransactionStatus.Completed),
    ]);
    processes.add(completed);

    return processes;
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
          ref.watch(currentTransactionProvider.notifier).state = t;
        }
      });
    });
  }
}
