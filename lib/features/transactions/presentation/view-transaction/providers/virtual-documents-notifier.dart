import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/data/models/virtual-document.dart';

class VirtualDocumentsNotifier extends Notifier<List<VirtualDocument>> {
  @override
  List<VirtualDocument> build() {
    return [];
  }

  void clear() {
    state = [];
  }

  void add({required final VirtualDocument document}) {
    state.add(document);
  }

  void addAll({required final List<VirtualDocument> documents}) {
    state.addAll(documents);
  }

  VirtualDocument remove({required int index}) {
    return state.removeAt(index);
  }
}

final virtualDocumentsProvider =
    NotifierProvider<VirtualDocumentsNotifier, List<VirtualDocument>>(
  () => VirtualDocumentsNotifier(),
);
