import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/color-manager.dart';
import 'package:troco/core/app/theme-manager.dart';
import 'package:troco/features/transactions/data/datasources/my-transaction-tab-items.dart';
import 'package:troco/features/transactions/presentation/my-transactions/providers/tab-provider.dart';
import 'package:troco/features/transactions/presentation/my-transactions/widgets/bottom-bar.dart';

class MyTransactionScreen extends ConsumerStatefulWidget {
  const MyTransactionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyTransactionScreenState();
}

class _MyTransactionScreenState extends ConsumerState<MyTransactionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle(
          ThemeManager.getSettingsUiOverlayStyle());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      bottomNavigationBar: const BottomBar(),
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: tabItems()[ref.watch(tabProvider)].page,
      ),
    );
  }
}
