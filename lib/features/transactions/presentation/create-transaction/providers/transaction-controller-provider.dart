import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'create-transaction-provider.dart';

class PageControllerNotifier extends Notifier<PageController> {
  @override
  PageController build() => PageController();

  void moveNext({required final int nextPageIndex}) {
    state.nextPage(
        duration: const Duration(milliseconds: 450), curve: Curves.ease);
    ref.read(createTransactionProgressProvider.notifier).state = nextPageIndex;
  }

  void moveBack() {
    state.previousPage(
        duration: const Duration(milliseconds: 450), curve: Curves.ease);
  }
}

final transactionPageController =
    NotifierProvider<PageControllerNotifier, PageController>(
        () => PageControllerNotifier());
