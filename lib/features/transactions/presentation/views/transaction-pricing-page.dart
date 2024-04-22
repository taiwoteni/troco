import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/basecomponents/images/svg.dart';
import 'package:troco/core/basecomponents/others/spacer.dart';
import 'package:troco/features/groups/presentation/widgets/empty-screen.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/presentation/providers/product-images-provider.dart';
import 'package:troco/features/transactions/presentation/widgets/add-product-widget.dart';
import 'package:troco/features/transactions/presentation/widgets/transaction-pricing-grid-item.dart';
import 'package:troco/features/transactions/presentation/widgets/transaction-pricing-list-item.dart';

import '../../../../core/app/font-manager.dart';
import '../../../../core/app/size-manager.dart';
import '../../../../core/basecomponents/button/presentation/provider/button-provider.dart';
import '../../../../core/basecomponents/button/presentation/widget/button.dart';
import '../../domain/entities/product.dart';

class TransactionPricingPage extends ConsumerStatefulWidget {
  const TransactionPricingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionPricingPageState();
}

class _TransactionPricingPageState extends ConsumerState<TransactionPricingPage> {
  final formKey = GlobalKey<FormState>();
  final buttonKey = UniqueKey();
  final List<Product> products = TransactionDataHolder.products ?? [];
  bool listAsGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
            left: SizeManager.large, right: SizeManager.large),
        child: products.isEmpty
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
    if (products.isEmpty) {
      return EmptyScreen(
        label: "\n\nAdd a product.",
        scale: 1.8,
        lottie: AssetManager.lottieFile(name: "add-product"),
        expanded: true,
      );
    }

    if (listAsGrid == false) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            const Gap(SizeManager.medium * 1.35),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return TransactionPricingListWidget(product: products[index]);
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return TransactionPricingGridWidget(
          product: products[index],
        );
      },
    );
  }

  Widget button() {
    return CustomButton.medium(
      label: "Continue",
      usesProvider: true,
      buttonKey: buttonKey,
      color: ColorManager.accentColor,
      onPressed: () async {
        ButtonProvider.startLoading(buttonKey: buttonKey, ref: ref);
        await Future.delayed(const Duration(seconds: 3));
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          // TransactionDataHolder.inspectionPeriod = inspectByDay;
          // TransactionDataHolder.inspectionDays = inspectionDay;
          // ref.read(createTransactionPageController.notifier).state.nextPage(
          //     duration: const Duration(milliseconds: 450), curve: Curves.ease);
          // ref.read(createTransactionProgressProvider.notifier).state = 2;
        }
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
    return Column(
      children: [
        mediumSpacer(),
        title(),
        mediumSpacer(),
        regularSpacer(),
        pricingGrid(),
        if (products.isNotEmpty) ...[mediumSpacer(), smallSpacer()]
      ],
    );
  }

  Widget footer() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.only(
        bottom: SizeManager.regular,
      ),
      child: Row(
        children: [
          Expanded(child: button()),
          mediumSpacer(),
          FloatingActionButton(
            onPressed: () {
              showModalBottomSheet<Product>(
                isScrollControlled: true,
                enableDrag: true,
                useSafeArea: false,
                backgroundColor: ColorManager.background,
                context: context,
                builder: (context) {
                  return const AddProductWidget();
                },
              ).then((product) {
                ref.read(productImagesProvider.notifier).state.clear();
                if (product != null) {
                  setState(() {
                    products.add(product);
                  });
                  TransactionDataHolder.products = products;
                }
              });
            },
            elevation: 0,
            backgroundColor: ColorManager.accentColor,
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
}
