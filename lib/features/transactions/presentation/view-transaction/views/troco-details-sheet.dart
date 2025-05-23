import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/api/data/model/response-model.dart';
import 'package:troco/core/app/file-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/core/components/texts/outputs/info-text.dart';
import 'package:troco/features/payments/data/sources/troco-account-details.dart';
import 'package:troco/features/payments/domain/repo/payment-repository.dart';
import 'package:troco/features/payments/presentation/widgets/select-payment-profile-widget.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/view-transaction/providers/current-transacton-provider.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../domain/entities/service.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../payments/domain/entity/payment-method.dart';

class TrocoDetailsSheet extends ConsumerStatefulWidget {
  const TrocoDetailsSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TrocoDetailsSheetState();
}

class _TrocoDetailsSheetState extends ConsumerState<TrocoDetailsSheet> {
  bool loading = false;
  int selectedProfileIndex = 0;
  List<PaymentMethod> methods = [];
  final buttonKey = UniqueKey();

  @override
  void initState() {
    methods = AppStorage.getPaymentMethods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.medium),
      decoration: BoxDecoration(
          color: ColorManager.background,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SizeManager.extralarge))),
      child: SingleChildScrollView(
        child: Column(
          children: [
            extraLargeSpacer(),
            const DragHandle(),
            largeSpacer(),
            title(),
            mediumSpacer(),
            Divider(
              thickness: 1,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
            mediumSpacer(),
            methodsList(),
            mediumSpacer(),
            paymentDirection(),
            extraLargeSpacer(),
            button(),
            extraLargeSpacer()
          ],
        ),
      ),
    );
  }

  Widget paymentDirection() {
    final transaction = ref.watch(currentTransactionProvider);
    var amount = transaction.transactionAmountString;
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;
    late String taskPosition;

    final formatter =
        NumberFormat.currency(symbol: '', decimalDigits: 2, locale: 'en_NG');

    if (isService) {
      final tasks = transaction.salesItem
          .map<Service>(
            (e) => e as Service,
          )
          .toList();
      final pendingTask = tasks.firstWhere((task) => !task.taskUploaded);
      final position = tasks.indexOf(pendingTask) + 1;
      taskPosition = position == 1
          ? "1st"
          : position == 2
              ? "2nd"
              : position == 3
                  ? "3rd"
                  : "${position}th";

      amount = "${formatter.format(pendingTask.finalPrice)} NGN";
    }

    if (isVirtual) {
      final tasks = transaction.salesItem
          .map<VirtualService>(
            (e) => e as VirtualService,
          )
          .toList();
      final pendingTask = tasks.firstWhere((task) => !task.documentsUploaded);
      final position = tasks.indexOf(pendingTask) + 1;
      taskPosition = position == 1
          ? "1st"
          : position == 2
              ? "2nd"
              : position == 3
                  ? "3rd"
                  : "${position}th";

      amount = "${formatter.format(pendingTask.finalPrice)} NGN";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoText(
          fontSize: FontSizeManager.small,
          color: ColorManager.secondary,
          text:
              "* You are prompted to transfer $amount NGN to the above account${isService ? " for the $taskPosition task" : ""}. Payment will be made to Troco being the middle man in this transaction. After you have made payment, assure the admin by uploading the receipt.",
        ),
        smallSpacer(),
        InfoText(
          fontSize: FontSizeManager.small,
          color: ColorManager.secondary,
          text: "* The receipt should be an image.",
        ),
        smallSpacer(),
        InfoText(
          fontSize: FontSizeManager.small,
          color: ColorManager.secondary,
          text:
              "* Adulterated, fake or illegitimate receipts will NOT be tolerated.",
        ),
      ],
    );
  }

  Widget title() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: SizeManager.small),
          alignment: Alignment.center,
          child: Text(
            "Payment To Troco",
            style: TextStyle(
                color: ColorManager.primary,
                fontWeight: FontWeightManager.bold,
                fontFamily: "Lato",
                fontSize: FontSizeManager.large * 0.9),
          ),
        ),
        Positioned(
          width: SizeManager.extralarge * 1.1,
          height: SizeManager.extralarge * 1.1,
          right: SizeManager.regular,
          child: IconButton(
              onPressed: () => loading ? null : Navigator.pop(context),
              style: ButtonStyle(
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(
                      ColorManager.accentColor.withOpacity(0.2))),
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.accentColor,
                size: IconSizeManager.small,
              )),
        )
      ],
    );
  }

  Widget methodsList() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SelectPaymentProfileWidget(
                selected: false,
                onChecked: () => null,
                method: trocoAccountDetails.first),
            regularSpacer(),
            regularSpacer(),
            Text(
              "OR",
              style: TextStyle(
                  color: ColorManager.secondary,
                  fontSize: FontSizeManager.regular * .9,
                  fontWeight: FontWeightManager.regular,
                  fontFamily: 'lato'),
            ),
            regularSpacer(),
            regularSpacer(),
            SelectPaymentProfileWidget(
                selected: false,
                onChecked: () => null,
                method: trocoAccountDetails.last),
          ],
        ));
  }

  Widget button() {
    return CustomButton(
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: uploadReceipt,
        label: "Upload Receipt");
  }

  Future<void> uploadReceipt() async {
    final transaction = ref.watch(currentTransactionProvider);
    final isService =
        transaction.transactionCategory == TransactionCategory.Service;
    final isVirtual =
        transaction.transactionCategory == TransactionCategory.Virtual;

    setState(() => loading = true);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 2));
    final file = await FileManager.pickImage();

    if (file != null) {
      final fileStat = await file.stat();
      if (fileStat.size / (1024 * 1024) >= 4) {
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

        setState(() => loading = false);
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "File size too large");
        Navigator.pop(context);
        return;
      }

      late HttpResponseModel result;
      if (isService) {
        final tasks = transaction.salesItem
            .map(
              (e) => e as Service,
            )
            .toList();
        final pendingTask = tasks.firstWhere((task) => !task.taskUploaded);

        result = await PaymentRepository.makePaymentForTask(
            transaction: ref.read(currentTransactionProvider),
            task: pendingTask,
            receiptPath: file.path);
      } else if (isVirtual) {
        final tasks = transaction.salesItem
            .map(
              (e) => e as VirtualService,
            )
            .toList();
        final pendingTask = tasks.firstWhere((task) => !task.documentsUploaded);

        result = await PaymentRepository.makePaymentForVirtualProduct(
            transaction: ref.read(currentTransactionProvider),
            task: pendingTask,
            receiptPath: file.path);
      } else {
        result = await PaymentRepository.uploadReceipt(
            transaction: ref.read(currentTransactionProvider), path: file.path);
      }
      debugPrint(result.body);
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      if (result.error) {
        setState(() => loading = false);
        SnackbarManager.showBasicSnackbar(
            context: context,
            mode: ContentType.failure,
            message: "Failed to upload receipt");
        Navigator.pop(context);

        return;
      }
      ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      Navigator.pop(context, true);
    }
    setState(() => loading = false);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
  }
}
