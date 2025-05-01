import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/snackbar-manager.dart';
import 'package:troco/core/components/images/svg.dart';
import 'package:troco/core/components/others/spacer.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/pricings-notifier.dart';
import 'package:troco/features/transactions/presentation/create-transaction/providers/transaction-controller-provider.dart';
import 'package:troco/features/transactions/presentation/create-transaction/widgets/add-service-widget.dart';
import 'package:troco/features/transactions/presentation/create-transaction/widgets/add-virtual-service-widget.dart';
import 'package:troco/features/transactions/presentation/create-transaction/widgets/select-role-sheet.dart';
import 'package:troco/features/transactions/utils/service-role.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/components/button/presentation/provider/button-provider.dart';
import '../../../../../core/components/button/presentation/widget/button.dart';
import '../../../../groups/presentation/collections_page/widgets/empty-screen.dart';
import '../../../domain/entities/product.dart';
import '../../../utils/enums.dart';
import '../widgets/add-product-widget.dart';
import '../widgets/transaction-pricing-grid-item.dart';
import '../widgets/transaction-pricing-list-item.dart';

class TransactionPricingPage extends ConsumerStatefulWidget {
  const TransactionPricingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPricingPageState();
}

class _TransactionPricingPageState
    extends ConsumerState<TransactionPricingPage> {
  final formKey = GlobalKey<FormState>();
  final buttonKey = UniqueKey();
  bool listAsGrid = false;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.large, right: SizeManager.large),
        child: ref.watch(pricingsProvider).isEmpty
            ? Column(
                children: [
                  Expanded(child: body()),
                  footer(),
                ],
              )
            : Form(
                key: formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(child: body()),
                    ),
                    footer(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget title() {
    return Row(
      children: [
        Text(
          "Pricing",
          style: TextStyle(
              fontFamily: "Quicksand",
              fontSize: FontSizeManager.large,
              color: ColorManager.primary,
              fontWeight: FontWeightManager.bold),
        ),
        const Spacer(),
        ...[
          IconButton.filled(
              onPressed: () => setState(() => listAsGrid = true),
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(listAsGrid
                      ? ColorManager.accentColor.withOpacity(0.3)
                      : ColorManager.secondary.withOpacity(0.1))),
              icon: SvgIcon(
                svgRes: AssetManager.svgFile(name: 'grid'),
                color: listAsGrid
                    ? ColorManager.accentColor
                    : ColorManager.secondary,
                size: const Size.square(IconSizeManager.regular),
              )),
          regularSpacer(),
          IconButton.filled(
              onPressed: () => setState(() => listAsGrid = false),
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(!listAsGrid
                      ? ColorManager.accentColor.withOpacity(0.3)
                      : ColorManager.secondary.withOpacity(0.1))),
              icon: SvgIcon(
                svgRes: AssetManager.svgFile(name: 'list'),
                color: !listAsGrid
                    ? ColorManager.accentColor
                    : ColorManager.secondary,
                size: const Size.square(IconSizeManager.regular),
              ))
        ]
      ],
    );
  }

  Widget pricingGrid() {
    final items = ref.watch(pricingsProvider);
    final TransactionCategory category =
        TransactionDataHolder.transactionCategory ??
            TransactionCategory.Product;

    if (items.isEmpty) {
      final text = category == TransactionCategory.Service
          ? "\n\nAdd a Task"
          : "\n\nDemonstrate your ${category.name.toLowerCase()}${category == TransactionCategory.Virtual ? "-product" : ""}(s)";

      return EmptyScreen(
        label: " $text",
        scale: 1.8,
        lottie: AssetManager.lottieFile(name: "add-product"),
        expanded: true,
      );
    }

    if (listAsGrid == false) {
      return ListView.separated(
        key: const Key("pricing-list"),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            const Gap(SizeManager.medium * 1.35),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              addItems(editItem: items[index]);
            },
            child: TransactionPricingListWidget(
                editable: TransactionDataHolder.transactionCategory !=
                    TransactionCategory.Service,
                key: ObjectKey(items[index]),
                item: items[index]),
          );
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            addItems(editItem: items[index]);
          },
          child: TransactionPricingGridWidget(
            item: items[index],
            onDelete: () {
              setState(() {
                items.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }

  Widget button() {
    return CustomButton.medium(
      label: "Continue",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.themeColor,
      onPressed: () async {
        TransactionDataHolder.items = ref.read(pricingsProvider);
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 3));

        if ((TransactionDataHolder.items ?? []).isEmpty) {
          setState(() => error = true);
          SnackbarManager.showBasicSnackbar(
              context: context,
              mode: ContentType.failure,
              message: "Add an item");
          ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
          return;
        }

        if (TransactionDataHolder.transactionCategory ==
            TransactionCategory.Service) {
          final totalCost = TransactionDataHolder.items!.fold(
            0.0,
            (previousValue, element) =>
                previousValue +
                (element.isEditing() == true
                    ? element.finalPrice
                    : element.price.toDouble()),
          );
          debugPrint(
              "Data holder total cost: ${TransactionDataHolder.totalCost}");
          debugPrint("Total cost: $totalCost");
          debugPrint("Is Editing: ${TransactionDataHolder.isEditing}");
          debugPrint(
              "Difference: ${totalCost - TransactionDataHolder.totalCost!}");
          debugPrint("Is Ok: ${totalCost >= TransactionDataHolder.totalCost!}");

          if (TransactionDataHolder.isEditing == true
              ? false
              : totalCost != TransactionDataHolder.totalCost) {
            setState(() => error = true);
            SnackbarManager.showBasicSnackbar(
                context: context,
                mode: ContentType.failure,
                message:
                    "Total price of items doesn't add up to the total cost");
            ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
            return;
          }
          if (TransactionDataHolder.isEditing == true) {
            TransactionDataHolder.role = ServiceRole.Developer;
          } else {
            final role = await showModalBottomSheet<ServiceRole?>(
              isScrollControlled: true,
              enableDrag: true,
              useSafeArea: true,
              backgroundColor: ColorManager.background,
              context: context,
              builder: (context) => const SelectRolesSheet(),
            );

            if (role == null) {
              SnackbarManager.showBasicSnackbar(
                  context: context,
                  mode: ContentType.failure,
                  message: "Select your role in this transaction.");
              return;
            }
            TransactionDataHolder.role = role;
          }
        }
        ref.read(transactionPageController.notifier).moveNext(nextPageIndex: 3);
        ButtonProvider.stopLoading(buttonKey: buttonKey, ref: ref);
      },
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount gridDelegate() {
    return const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.6,
      crossAxisSpacing: SizeManager.medium * 1.6,
      mainAxisSpacing: SizeManager.medium * 1.2,
    );
  }

  Widget body() {
    final items = ref.watch(pricingsProvider);
    return Column(
      children: [
        mediumSpacer(),
        title(),
        mediumSpacer(),
        regularSpacer(),
        pricingGrid(),
        if (items.isNotEmpty) ...[mediumSpacer(), smallSpacer()],
      ],
    );
  }

  Widget footer() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.only(
        bottom: SizeManager.large,
      ),
      child: Row(
        children: [
          Expanded(child: button()),
          mediumSpacer(),
          FloatingActionButton(
            onPressed: addItems,
            elevation: 0,
            backgroundColor: ColorManager.themeColor,
            // foregroundColor: Colors.white,
            child: SvgIcon(
              svgRes: AssetManager.svgFile(name: "add-product"),
              size: const Size.square(IconSizeManager.medium * 0.9),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<SalesItem?> getItem({final SalesItem? item}) {
    switch (TransactionDataHolder.transactionCategory) {
      case TransactionCategory.Service:
        return Future.value(AddServiceSheet.bottomSheet(
            context: context, service: item as Service?));
      case TransactionCategory.Product:
        return Future.value(AddProductSheet.bottomSheet(
            context: context, product: item as Product?));
      default:
        return Future.value(AddVirtualServiceSheet.bottomSheet(
            context: context, service: item as VirtualService?));
    }
  }

  Future<void> addItems({SalesItem? editItem}) async {
    final item = await getItem(item: editItem);

    if (item != null) {
      // If I'm to edit
      if (editItem != null) {
        ref
            .read(pricingsProvider.notifier)
            .editItem(oldItem: editItem, newItem: item);
      } else {
        ref.read(pricingsProvider.notifier).addItem(item: item);
      }
      setState(() {});
      TransactionDataHolder.items = ref.read(pricingsProvider);
    }
    // ref.read(pricingsImagesProvider.notifier).state.clear();
  }
}
