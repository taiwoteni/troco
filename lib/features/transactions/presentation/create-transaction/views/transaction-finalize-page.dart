// ignore_for_file: use_build_context_synchronously

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/images/profile-icon.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';
import 'package:troco/features/kyc/utils/enums.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../groups/domain/entities/group.dart';
import '../../../domain/entities/transaction.dart';
import '../../../utils/enums.dart';
import '../../../utils/transaction-category-converter.dart';
import '../../view-transaction/widgets/select-return-product-widget.dart';
import '../widgets/transaction-pin-widget.dart';
import 'create-transaction-progress-screen.dart';

class TransactionFinalizePage extends ConsumerStatefulWidget {
  const TransactionFinalizePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPreviewPageState();
}

class _TransactionPreviewPageState
    extends ConsumerState<TransactionFinalizePage> {
  late Transaction transaction;
  final textStyle = TextStyle(
      color: ColorManager.primary,
      fontFamily: 'quicksand',
      fontSize: FontSizeManager.medium,
      fontWeight: FontWeightManager.semibold);
  final buttonKey = UniqueKey();

  @override
  void initState() {
    transaction = TransactionDataHolder.toTransaction();
    super.initState();
  }

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                mediumSpacer(),
                title(),
                mediumSpacer(),

                // transaction name
                name(),
                mediumSpacer(),
                // transaction details
                description(),
                extraLargeSpacer(),
                regularSpacer(),
                // location
                location(),
                regularSpacer(),
                divider(),
                regularSpacer(),
                // inspection period
                inspectionPeriod(),
                regularSpacer(),
                divider(),
                regularSpacer(),
                // estimated time
                estimatedTime(),
                regularSpacer(),
                divider(),
                regularSpacer(),

                // escrow fee
                escrowFee(),
                regularSpacer(),
                largeSpacer(),

                // items
                items(),
                divider(),
                regularSpacer(),
                largeSpacer(),

                //price
                price(),
                regularSpacer(),
                extraLargeSpacer(),

                button(),
                extraLargeSpacer(),
              ],
            ),
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

  Widget title() {
    return Text(
      "Finalization",
      textAlign: TextAlign.start,
      style: TextStyle(
          fontFamily: "Quicksand",
          fontSize: FontSizeManager.large,
          color: ColorManager.primary,
          fontWeight: FontWeightManager.bold),
    );
  }

  Widget divider() {
    return Divider(
      color: ColorManager.secondary.withOpacity(0.09),
    );
  }

  Widget name() {
    return Text(
      transaction.transactionName
          .trim()
          .padRight(transaction.transactionName.length + 1, "."),
      textAlign: TextAlign.left,
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'lato',
          wordSpacing: -0.5,
          fontWeight: FontWeightManager.extrabold,
          fontSize: FontSizeManager.medium * 1.05),
    );
  }

  Widget description() {
    return Text(
      transaction.transactionDetail
          .trim()
          .padRight(transaction.transactionDetail.trim().length + 1, "."),
      style: TextStyle(
          color: ColorManager.secondary,
          fontFamily: 'Quicksand',
          height: 1.4,
          fontWeight: FontWeightManager.medium,
          fontSize: FontSizeManager.regular * 0.9),
    );
  }

  Widget price() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Amount: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "${transaction.transactionAmountString.trim()} NGN",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'lato',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget location() {
    return SizedBox(
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Address: ",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: ColorManager.secondary,
                fontFamily: 'quicksand',
                height: 1.4,
                fontWeight: FontWeightManager.extrabold,
                fontSize: FontSizeManager.medium * 0.8),
          ),
          Expanded(
            child: SizedBox(
              width: double.maxFinite,
              child: Text(
                transaction.address,
                textAlign: TextAlign.right,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    color: ColorManager.primary,
                    fontFamily: 'quicksand',
                    height: 1.4,
                    fontWeight: FontWeightManager.extrabold,
                    fontSize: FontSizeManager.medium * 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inspectionPeriod() {
    final isProduct =
        transaction.transactionCategory == TransactionCategory.Product;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isProduct ? "Inspection Period: " : "Transaction Duration: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          transaction.inspectionString,
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget estimatedTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Estimated End: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          DateFormat.yMMMEd().format(transaction.transactionTime),
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.primary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
    );
  }

  Widget items() {
    return Column(
      children: transaction.salesItem
          .map(
            (e) => Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: SizeManager.regular),
              child: SelectReturnItemWidget(
                item: e,
                onChecked: () {},
                selected: false,
                isDisplay: true,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget escrowFee() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Escrow Fee: ",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.secondary,
              fontFamily: 'quicksand',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
        Text(
          "${NumberFormat.currency(symbol: '', locale: 'en_NG', decimalDigits: 2).format(transaction.escrowCharges)} NGN",
          textAlign: TextAlign.left,
          style: TextStyle(
              color: ColorManager.accentColor,
              fontFamily: 'lato',
              height: 1.4,
              fontWeight: FontWeightManager.extrabold,
              fontSize: FontSizeManager.medium * 0.8),
        ),
      ],
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
      label: TransactionDataHolder.isEditing == true ? "Edit" : "Create",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        final client = ref.watch(clientProvider)!;
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 2));
        final totalPrice = TransactionDataHolder.items!
            .map(
              (e) => e.quantity * e.price,
            )
            .fold(
              0.0,
              (previousValue, element) => previousValue + element,
            );

        if (client.kycTier == VerificationTier.Tier1) {
          if (totalPrice > 200000) {
            SnackbarManager.showBasicSnackbar(
                context: context,
                mode: ContentType.failure,
                message:
                    "Max price for Tier 1 is 200,000 NGN\nUpgrade your KYC Tier");
            ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

            return;
          }
        } else if (client.kycTier == VerificationTier.Tier2) {
          if (totalPrice > 500000) {
            SnackbarManager.showBasicSnackbar(
                context: context,
                mode: ContentType.failure,
                message:
                    "Max price for Tier 1 is 500,000 NGN\nUpgrade your KYC Tier");
            ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);

            return;
          }
        }
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
            settings: RouteSettings(
                arguments: ModalRoute.of(context)!.settings.arguments),
            builder: (context) => const CreateTransactonProgressScreen(),
          ));
    }
  }
}
