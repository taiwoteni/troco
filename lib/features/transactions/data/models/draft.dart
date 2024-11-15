import 'package:troco/features/transactions/domain/entities/transaction.dart';

class Draft extends Transaction {
  const Draft.fromJson({required super.json}) : super.fromJson();

  Draft.fromTransaction({required final Transaction transaction})
      : super.fromJson(json: transaction.toJson());
}
