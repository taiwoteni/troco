import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/my-statistics-page.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/my-transactions-page.dart';

import '../../../home/data/models/home-item-model.dart';

List<HomeItemModel> tabItems() {
  return [
    HomeItemModel(
        icon: AssetManager.svgFile(name: "transaction"),
        label: "Transactions",
        page: const MyTransactionsPage()),
    HomeItemModel(
        icon: AssetManager.svgFile(name: "statistics"),
        label: "Statistics",
        page: const MyStatisticsPage())
  ];
}
