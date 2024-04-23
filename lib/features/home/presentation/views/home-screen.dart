import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/home/presentation/providers/home-pages-provider.dart';
import 'package:troco/features/transactions/domain/repository/transaction-repo.dart';

import '../widgets/bottom-bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) async{
      final response = await TransactionRepo.getAllTransactions();
      if(!response.error){
      log("Test :${response.body}");

      }
    });
  }

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
