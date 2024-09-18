import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:troco/features/transactions/domain/entities/service.dart';

abstract class SalesItem extends Equatable {
  final String id, name;
  final List<String> images;
  final int price, quantity;

  const SalesItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.quantity,
      required this.images});

  String get priceString =>
      NumberFormat.currency(locale: "en_NG", decimalDigits: 2, symbol: "")
          .format(price);

  bool get noImage => images.isEmpty;

  String mainImage() {
    if (noImage) {
      throw Exception("Sales Item must have at least one image");
    }
    return images[0];
  }

  double get finalPrice => double.parse(toJson()["finalPrice"].toString());

  double get escrowCharge => double.parse(toJson()["escrowCharges"].toString());

  double get escrowPercentage =>
      double.parse(toJson()["escrowPercentage"].toString());

  Map<dynamic, dynamic> toJson();

  @override
  List<Object?> get props => [id];
}
