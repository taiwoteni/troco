import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/my-transactions-list.dart';
import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../groups/presentation/widgets/empty-screen.dart';
import '../../../domain/entities/transaction.dart';
import '../../view-transaction/providers/transactions-provider.dart';

class MyTransactionsPage extends ConsumerStatefulWidget {
  const MyTransactionsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<MyTransactionsPage> {
  late TextEditingController controller;
  List<Transaction> transactions = [];

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(transactionsStreamProvider).when(
      data: (transactions) {
        this.transactions = transactions;
        return transactions.isEmpty ? emptyBody() : body();
      },
      error: (error, stackTrace) {
        transactions = AppStorage.getTransactions();
        return transactions.isEmpty ? emptyBody() : body();
      },
      loading: () {
        transactions = AppStorage.getTransactions();
        return transactions.isEmpty ? emptyBody() : body();
      },
    );
  }

  Widget emptyBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extraLargeSpacer(),
          back(),
          mediumSpacer(),
          title(),
          EmptyScreen(
            lottie: AssetManager.lottieFile(name: "empty-transactions"),
            scale: 1.5,
            label: "You do not have any transactions.",
            expanded: true,
          ),
        ],
      ),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      // padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extraLargeSpacer(),
          back(),
          mediumSpacer(),
          title(),
          largeSpacer(),
          mediumSpacer(),
          searchBar(),
          largeSpacer(),
          const MyTransactionsList(),
          mediumSpacer(),
        ],
      ),
    );
  }

  Widget title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Text(
        "My Transactions",
        textAlign: TextAlign.left,
        style: TextStyle(
            color: ColorManager.accentColor,
            fontFamily: 'lato',
            fontSize: FontSizeManager.large * 1.2,
            fontWeight: FontWeightManager.extrabold),
      ),
    );
  }

  Widget back() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: ButtonStyle(
                shape: const MaterialStatePropertyAll(CircleBorder()),
                backgroundColor: MaterialStatePropertyAll(
                    ColorManager.accentColor.withOpacity(0.2))),
            icon: Icon(
              Icons.close_rounded,
              color: ColorManager.accentColor,
              size: IconSizeManager.small,
            )),
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: TextFormField(
        controller: controller,
        maxLines: 1,
        onChanged: (text) {},
        cursorColor: ColorManager.themeColor,
        cursorRadius: const Radius.circular(SizeManager.medium),
        style: defaultStyle(),
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                vertical: SizeManager.medium,
                horizontal: SizeManager.medium * 1.3),
            isDense: true,
            hintText: "Search Transaction",
            floatingLabelBehavior: FloatingLabelBehavior.never,
            hintStyle: defaultStyle().copyWith(color: ColorManager.secondary),
            fillColor: ColorManager.tertiary,
            filled: true,
            border: defaultBorder(),
            enabledBorder: defaultBorder(),
            errorBorder: defaultBorder(),
            focusedBorder: defaultBorder(),
            disabledBorder: defaultBorder(),
            focusedErrorBorder: defaultBorder()),
      ),
    );
  }

  TextStyle defaultStyle() {
    return TextStyle(
        color: ColorManager.primary,
        fontSize: FontSizeManager.regular,
        fontWeight: FontWeightManager.medium,
        fontFamily: 'Lato');
  }

  InputBorder defaultBorder() {
    return OutlineInputBorder(
        borderSide:
            BorderSide(color: ColorManager.themeColor, style: BorderStyle.none),
        borderRadius: BorderRadius.circular(SizeManager.large));
  }
}
