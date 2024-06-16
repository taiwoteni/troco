
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/cache/shared-preferences.dart';
import 'package:troco/features/payments/domain/entity/payment-method.dart';

final paymentMethodProvider = StateProvider<List<PaymentMethod>>((ref) => AppStorage.getPaymentMethods(),);