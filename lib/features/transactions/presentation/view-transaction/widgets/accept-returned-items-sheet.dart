import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/components/button/presentation/provider/button-provider.dart';
import 'package:troco/core/components/button/presentation/widget/button.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/transaction.dart';
import 'package:troco/features/transactions/presentation/view-transaction/widgets/select-return-product-widget.dart';
import 'package:troco/features/transactions/utils/enums.dart';

import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/others/drag-handle.dart';
import '../../../../../core/components/others/spacer.dart';

class AcceptItemsSheet extends ConsumerStatefulWidget {
  final Transaction transaction;
  const AcceptItemsSheet({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectPaymentMethodSheetState();

  static Future<bool?> bottomSheet(
      {required final Transaction transaction, required BuildContext context}) {
    return showModalBottomSheet<bool?>(
        isScrollControlled: true,
        enableDrag: true,
        useSafeArea: false,
        isDismissible: false,
        backgroundColor: ColorManager.background,
        context: context,
        builder: (context) => AcceptItemsSheet(transaction: transaction));
  }
}

class _SelectPaymentMethodSheetState extends ConsumerState<AcceptItemsSheet> {
  bool loading = false;
  bool accept = false;
  List<SalesItem> items = [];
  final buttonKey = UniqueKey();

  late bool isService;
  late bool isProduct;

  @override
  void initState() {
    items = widget.transaction.hasReturnTransaction
        ? widget.transaction.returnItems
        : widget.transaction.salesItem;
    isProduct =
        widget.transaction.transactionCategory == TransactionCategory.Product;
    isService =
        widget.transaction.trocoPaysSeller == TransactionCategory.Service;
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) {
      return;
    }

    super.setState(fn);

    if (!accept) {
      ButtonProvider.disable(buttonKey: buttonKey, ref: ref);
    } else {
      ButtonProvider.enable(buttonKey: buttonKey, ref: ref);
    }
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
            itemsList(),
            mediumSpacer(),
            smallSpacer(),
            acceptItemsAbove(),
            largeSpacer(),
            button(),
            extraLargeSpacer()
          ],
        ),
      ),
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
            widget.transaction.hasReturnTransaction
                ? "Accept Returned Items"
                : isProduct
                    ? "Accept The Products"
                    : (isService
                        ? "Accept The Software"
                        : "Accept The Document"),
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

  Widget itemsList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeManager.regular),
          child: SelectReturnItemWidget(
            selected: false,
            isDisplay: true,
            onChecked: () {},
            item: items[index],
          ),
        );
      },
      shrinkWrap: true,
    );
  }

  Widget button() {
    return CustomButton(
        buttonKey: buttonKey,
        usesProvider: true,
        onPressed: acceptItems,
        label: "Next");
  }

  Widget acceptItemsAbove() {
    final isReturn = widget.transaction.hasReturnTransaction;
    return Row(
      children: [
        regularSpacer(),
        SizedBox.square(
          dimension: IconSizeManager.regular * 1.85,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Checkbox(
              value: accept,
              onChanged: (value) => setState(() => accept = value ?? true),
              fillColor: WidgetStatePropertyAll(
                  accept ? ColorManager.accentColor : ColorManager.background),
              checkColor: Colors.white,
              side: BorderSide(
                  style: BorderStyle.solid,
                  color: accept
                      ? ColorManager.accentColor
                      : ColorManager.secondary),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        Text(
          "I ${isReturn ? "accept" : "have received"} the ${isReturn ? "returned items" : isProduct ? "merchandise" : isService ? "software" : "document"} above.",
          style: TextStyle(
              fontFamily: 'lato',
              wordSpacing: 2.5,
              fontSize: FontSizeManager.small * 1.15,
              fontWeight: FontWeightManager.regular,
              color: ColorManager.primary),
        )
      ],
    );
  }

  Future<void> acceptItems() async {
    setState(() => loading = true);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pop(context, true);
  }
}
