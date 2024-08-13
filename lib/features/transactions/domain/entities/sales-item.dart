import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

abstract class SalesItem extends Equatable {
  final String id, image, name;
  final int price, quantity;

  const SalesItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.quantity,
      required this.image});

  String get priceString =>
      NumberFormat.currency(locale: "en_NG", decimalDigits: 2, symbol: "")
          .format(price);

  double get finalPrice => double.parse(toJson()["finalPrice"].toString());

  double get escrowCharge => double.parse(toJson()["escrowCharges"].toString());

  double get escrowPercentage =>
      double.parse(toJson()["escrowPercentage"].toString());

  Map<dynamic, dynamic> toJson();

  @override
  List<Object?> get props => [id];
}
