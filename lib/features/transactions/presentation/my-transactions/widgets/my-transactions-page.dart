import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/my-transactions-list.dart';
import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../../dashboard/presentation/widgets/transaction-item-widget.dart';
import '../../../../groups/presentation/collections_page/widgets/empty-screen.dart';
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
  bool searching = false;
  late Widget searchBarWidget;

  @override
  void initState() {
    transactions = AppStorage.getAllTransactions();
    controller = TextEditingController();
    searchBarWidget = searchBar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    listenToChanges();
    return body(transactions: transactions);
  }

  Future<void> listenToChanges() async {
    ref.listen(transactionsStreamProvider, (previous, next) {
      next.whenData((value) {
        value.sort(
          (a, b) => (1.compareTo(0)),
        );
        if (!searching) {
          setState(() {
            transactions = value;
          });
        }
      });
    });
  }

  Widget emptyBody() {
    return Flexible(
      child: EmptyScreen(
        expanded: false,
        lottie: AssetManager.lottieFile(
            name: controller.text.trim().isNotEmpty
                ? "no-search-results"
                : "empty-transaction"),
        forward: true,
        xIndex: controller.text.trim().isEmpty ? 1 : 0.25,
        label: controller.text.trim().isEmpty
            ? "You don't have any transaction"
            : "No search results for '${controller.text.toString().trim()}'",
      ),
    );
  }

  Widget body({required final List<Transaction> transactions}) {
    final child = Column(
      children: [
        extraLargeSpacer(),
        back(),
        mediumSpacer(),
        Align(alignment: Alignment.centerLeft, child: title()),
        if (AppStorage.getAllTransactions().isNotEmpty) ...[
          extraLargeSpacer(),
          searchBarWidget,
          mediumSpacer(),
        ],
        if (transactions.isNotEmpty) querySearchList() else emptyBody(),
      ],
    );
    return transactions.isEmpty
        ? child
        : SingleChildScrollView(
            child: child,
          );
  }

  Widget querySearchList() {
    transactions.sort((a, b) => b.creationTime.compareTo(a.creationTime));
    return ListView.separated(
        key: const Key("latestTransactionsList"),
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.medium),
              child: TransactionItemWidget(
                key: ObjectKey(transactions[index]),
                transaction: transactions[index],
                fromDarkStatusBar: true,
              ),
            ),
        separatorBuilder: (context, index) => Divider(
              thickness: 0.8,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
        itemCount: transactions.length);
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
    return Container(
      alignment: Alignment.centerRight,
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
        onChanged: (text) {
          final search = text.trim();

          final transactions = this
              .transactions
              .where(
                (transaction) => transaction.transactionName
                    .toLowerCase()
                    .contains(search.toLowerCase()),
              )
              .toList();

          setState(() {
            searching = search.isNotEmpty;
            this.transactions =
                search.isEmpty ? AppStorage.getAllTransactions() : transactions;
          });
        },
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
