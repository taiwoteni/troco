import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/app/color-manager.dart';
import 'package:troco/app/size-manager.dart';
import 'package:troco/providers/home-pages-provider.dart';

import 'bottom-bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.background,
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: SizeManager.regular,
        ),
        child: homeItems[ref.watch(homeProvider)].page,
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
