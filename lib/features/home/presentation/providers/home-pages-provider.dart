import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/asset-manager.dart';
import 'package:troco/features/home/data/models/home-item-model.dart';
import 'package:troco/features/dashboard/presentation/views/home-page.dart';
import 'package:troco/features/settings/presentation/settings-page/views/settings-page.dart';
import 'package:troco/features/transactions/utils/enums.dart';
import 'package:troco/features/wallet/presentation/views/wallet-page.dart';

import '../../../auth/presentation/providers/client-provider.dart';
import '../../../groups/presentation/groups_page/views/group-page.dart';
import '../../../services/presentation/core/views/services-page.dart';

List<HomeItemModel> homeItems = [
  HomeItemModel(
      icon: AssetManager.svgFile(name: 'home'),
      label: "Home",
      page: const HomePage()),
  if (ClientProvider.readOnlyClient!.accountCategory != Category.Personal)
    HomeItemModel(
        icon: AssetManager.svgFile(name: 'wallet'),
        label: "Wallet",
        page: const WalletPage()),
  HomeItemModel(
      icon: AssetManager.svgFile(name: 'group'),
      label: "Group",
      page: const GroupPage()),
  HomeItemModel(
      icon: AssetManager.svgFile(name: 'services'),
      label: "Escrow",
      page: const ServicesPage()),
  HomeItemModel(
      icon: AssetManager.svgFile(name: 'settings'),
      label: "Settings",
      page: const SettingsPage())
];

final homeProvider = StateProvider<int>((ref) {
  return 0;
});
