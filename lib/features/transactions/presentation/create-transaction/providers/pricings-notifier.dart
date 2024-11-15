import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/transactions/data/models/create-transaction-data-holder.dart';
import 'package:troco/features/transactions/domain/entities/product.dart';
import 'package:troco/features/transactions/domain/entities/sales-item.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';
import 'package:troco/features/transactions/domain/entities/virtual-service.dart';

class PricingsNotifier extends Notifier<List<SalesItem>> {
  @override
  List<SalesItem> build() {
    return TransactionDataHolder.items ?? [];
  }

  void addItem({required final SalesItem item}) {
    state.add(item);
  }

  void removeItem({required final SalesItem item}) {
    state.remove(item);
  }

  void reduceQuantity({required final SalesItem item}) {
    final index = state.indexOf(item);

    final newQuantity = item.quantity - 1;

    final json = item.toJson();
    json["quantity"] = newQuantity;

    state[index] = item is Service
        ? Service.fromJson(json: json)
        : item is Product
            ? Product.fromJson(json: json)
            : VirtualService.fromJson(json: json);
  }

  void increaseQuantity({required final SalesItem item}) {
    final index = state.indexOf(item);

    final newQuantity = item.quantity + 1;

    final json = item.toJson();
    json["quantity"] = newQuantity;

    state[index] = item is Service
        ? Service.fromJson(json: json)
        : item is Product
            ? Product.fromJson(json: json)
            : VirtualService.fromJson(json: json);
  }

  void editItem(
      {required final SalesItem oldItem, required final SalesItem newItem}) {
    final index = state.indexOf(oldItem);
    state[index] = newItem;
  }

  void clear() {
    state.clear();
  }
}

final pricingsProvider = NotifierProvider<PricingsNotifier, List<SalesItem>>(
  () => PricingsNotifier(),
);
