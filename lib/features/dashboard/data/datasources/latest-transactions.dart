import 'package:troco/core/cache/shared-preferences.dart';

import '../../../transactions/domain/entities/transaction.dart';

List<Transaction> latestTransactions() {
  return [
    const Transaction.fromJson(json: {
      "transaction detail": "selling My Passport Ultra Hard Drive",
      "transaction id": "ID-87aA8",
      "transaction time": "2024-06-02T00:00:00Z",
      "transaction purpose": "Selling",
      "transaction amount": 50000.00,
      "transaction status": "Finalizing",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "buying macbook pro",
      "transaction id": "ID-87aA8",
      "transaction time": "2024-06-04T00:00:00Z",
      "transaction purpose": "Buying",
      "transaction amount": 100000.00,
      "transaction status": "Pending",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "shipping Tera Batteries",
      "transaction id": "ID-87aA8",
      "transaction purpose": "Selling",
      "transaction time": "2024-06-05T00:00:00Z",
      "transaction amount": 250000.00,
      "transaction status": "Completed",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "selling Ultra Drive",
      "transaction id": "ID-87aA8",
      "transaction time": "2024-06-05T08:00:00Z",
      "transaction purpose": "Selling",
      "transaction amount": 50000.00,
      "transaction status": "Finalizing",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "buying macbook press",
      "transaction id": "ID-87aA8",
      "transaction time": "2024-06-07T00:00:00Z",
      "transaction purpose": "Buying",
      "transaction amount": 100000.00,
      "transaction status": "Pending",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "shipping Zeta Batteries",
      "transaction id": "ID-87aA8",
      "transaction purpose": "Selling",
      "transaction time": "2024-06-09T00:00:00Z",
      "transaction amount": 250000.00,
      "transaction status": "Completed",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "shipping Lubega Batteries",
      "transaction id": "ID-87aA8",
      "transaction purpose": "Selling",
      "transaction time": "2024-06-10T00:00:00Z",
      "transaction amount": 250000.00,
      "transaction status": "Completed",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "selling HD Ultra Drive",
      "transaction id": "ID-87aA8",
      "transaction time": "2024-06-13T00:00:00Z",
      "transaction purpose": "Selling",
      "transaction amount": 50000.00,
      "transaction status": "Finalizing",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "buying macbook press",
      "transaction id": "ID-87aA8",
      "transaction time": "2024-06-14T00:00:00Z",
      "transaction purpose": "Buying",
      "transaction amount": 100000.00,
      "transaction status": "Pending",
    }),
    const Transaction.fromJson(json: {
      "transaction detail": "shipping Zeta Batteries",
      "transaction id": "ID-87aA8",
      "transaction purpose": "Selling",
      "transaction time": "2024-06-18T00:00:00Z",
      "transaction amount": 250000.00,
      "transaction status": "Completed",
    }),
    ...AppStorage.getTransactions()
  ];
}
