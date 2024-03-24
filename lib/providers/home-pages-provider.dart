import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/asset-manager.dart';
import 'package:troco/models/home-item.dart';
import 'package:troco/view/home-page/home-page.dart';
import 'package:troco/view/services-page/services-page.dart';
import 'package:troco/view/settings-page/settings-page.dart';
import 'package:troco/view/wallet-page/wallet-page.dart';

import '../view/group-page/group-page.dart';

List<HomeItem> homeItems = [
  HomeItem(
      icon: AssetManager.svgFile(name: 'home'),
      label: "Home",
      page: const HomePage()),
  HomeItem(
      icon: AssetManager.svgFile(name: 'wallet'),
      label: "Wallet",
      page: const WalletPage()),
  HomeItem(
      icon: AssetManager.svgFile(name: 'group'),
      label: "Group",
      page: const GroupPage()),
  HomeItem(
      icon: AssetManager.svgFile(name: 'services'),
      label: "Escrow",
      page: const ServicesPage()),
  HomeItem(
      icon: AssetManager.svgFile(name: 'settings'),
      label: "Settings",
      page: const SettingsPage())
];

final homeProvider = StateProvider<int>((ref) {
  return 0;
});
