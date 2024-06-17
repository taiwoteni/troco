
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/statistics-page.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/transactions-page.dart';

import '../../../home/data/models/home-item-model.dart';

List<HomeItemModel> tabItems(){

  return [
    HomeItemModel(
      icon: AssetManager.svgFile(name: "transaction"),
      label: "Transactions",
      page: const TransactionsPage()),
      HomeItemModel(
      icon: AssetManager.svgFile(name: "statistics"),
      label: "Statistics",
      page: const StatisticsPage())
  ];

}