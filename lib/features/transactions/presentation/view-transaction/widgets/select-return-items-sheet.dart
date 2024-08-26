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

class SelectReturnItemsSheet extends ConsumerStatefulWidget {
  final Transaction transaction;
  const SelectReturnItemsSheet({super.key, required this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectPaymentMethodSheetState();
}

class _SelectPaymentMethodSheetState
    extends ConsumerState<SelectReturnItemsSheet> {
  bool loading = false;
  List<String> selectedIds = [];
  List<SalesItem> items = [];
  final buttonKey = UniqueKey();

  @override
  void initState() {
    items = widget.transaction.hasReturnTransaction
        ? widget.transaction.returnItems
        : widget.transaction.salesItem;
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

    if (selectedIds.isEmpty) {
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
            extraLargeSpacer(),
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
            "Select Unsatisfactory ${widget.transaction.transactionCategory == TransactionCategory.Product ? "Product" : "Service"}(s)",
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
          child: SelectReturnProductWidget(
            selected: selectedIds.contains(items[index].id),
            onChecked: () => setState(() {
              if (selectedIds.contains(items[index].id)) {
                selectedIds.remove(items[index].id);
              } else {
                selectedIds.add(items[index].id);
              }
            }),
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
        onPressed: selectProfile,
        label: "Return");
  }

  Future<void> selectProfile() async {
    setState(() => loading = true);
    ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => loading = false);
    ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
    Navigator.pop(context, selectedIds);
  }
}
