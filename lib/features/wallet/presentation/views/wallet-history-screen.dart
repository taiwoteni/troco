import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/my-transactions-list.dart';
import 'package:troco/features/wallet/domain/entities/wallet-transaction.dart';
import 'package:troco/features/wallet/presentation/providers/wallet-history-provider.dart';
import 'package:troco/features/wallet/presentation/widgets/wallet-transaction-item-widget.dart';
import '../../../../../core/app/asset-manager.dart';
import '../../../../../core/app/color-manager.dart';
import '../../../../../core/app/font-manager.dart';
import '../../../../../core/app/size-manager.dart';
import '../../../../../core/cache/shared-preferences.dart';
import '../../../../../core/components/others/spacer.dart';
import '../../../groups/presentation/collections_page/widgets/empty-screen.dart';

class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  late TextEditingController controller;
  List<WalletTransaction> walletHistory = [];
  bool searching = false;
  late Widget searchBarWidget;

  @override
  void initState() {
    walletHistory = AppStorage.getWalletTransactions();
    walletHistory.sort(
      (a, b) => b.time.compareTo(a.time),
    );
    controller = TextEditingController();
    searchBarWidget = searchBar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    listenToChanges();
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: body(transactions: walletHistory),
    );
  }

  Future<void> listenToChanges() async {
    ref.listen(walletHistoryStreamProvider, (previous, next) {
      next.whenData((value) {
        value.sort(
          (a, b) => (b.time.compareTo(a.time)),
        );
        if (!searching) {
          setState(() {
            walletHistory = value;
          });
        }
      });
    });
  }

  Widget emptyBody() {
    return Flexible(
      child: SizedBox(
        width: double.maxFinite,
        child: EmptyScreen(
          expanded: false,
          lottie: AssetManager.lottieFile(
              name: controller.text.trim().isNotEmpty
                  ? "no-search-results"
                  : "empty-transactions"),
          forward: true,
          xIndex: controller.text.trim().isEmpty ? 0 : 0.25,
          label: controller.text.trim().isEmpty
              ? "You don't have any transaction"
              : "No search results for '${controller.text.toString().trim()}'",
        ),
      ),
    );
  }

  Widget body({required final List<WalletTransaction> transactions}) {
    final child = Column(
      children: [
        extraLargeSpacer(),
        back(),
        mediumSpacer(),
        Align(alignment: Alignment.centerLeft, child: title()),
        if (AppStorage.getWalletTransactions().isNotEmpty) ...[
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
    return ListView.separated(
        key: const Key("latestWalletTransactionsList"),
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SizeManager.medium),
              child: WalletTransactionWidget(
                key: ObjectKey(walletHistory[index]),
                transaction: walletHistory[index],
              ),
            ),
        separatorBuilder: (context, index) => Divider(
              thickness: 0.8,
              color: ColorManager.secondary.withOpacity(0.08),
            ),
        itemCount: walletHistory.length);
  }

  Widget title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeManager.large * 1.2),
      child: Text(
        "Wallet History",
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
              .walletHistory
              .where(
                (transaction) => transaction.transactionName
                    .toLowerCase()
                    .contains(search.toLowerCase()),
              )
              .toList();

          setState(() {
            searching = search.isNotEmpty;
            this.walletHistory = search.isEmpty
                ? AppStorage.getWalletTransactions()
                : transactions;
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
            hintText: "Search Wallet",
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
