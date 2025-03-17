import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

abstract class SalesItem extends Equatable {
  final String id, name;
  final List<String> images;
  final double price;
  final int quantity;

  const SalesItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.quantity,
      required this.images});

  String get priceString =>
      NumberFormat.currency(locale: "en_NG", decimalDigits: 2, symbol: "")
          .format(price);

  String get finalPriceString =>
      NumberFormat.currency(locale: "en_NG", decimalDigits: 2, symbol: "")
          .format(finalPrice);

  bool get noImage => images.isEmpty;

  String mainImage() {
    if (noImage) {
      throw Exception("Sales Item must have at least one image");
    }
    return images[0];
  }

  /// How we know if a sales item exists already and may be edited is that
  /// the [id] is not a number but rather a string i.e "66f2d3e0g7tff4"
  bool isEditing() {
    final isId = double.tryParse(id);

    return isId == null;
  }

  List<String> get removedImages => ((toJson()['removedImages'] ?? []) as List)
      .map((e) => e.toString())
      .toList();

  double get finalPrice => double.parse(toJson()["finalPrice"].toString());

  double get escrowCharge => double.parse(toJson()["escrowCharges"].toString());

  double get escrowPercentage =>
      double.parse(toJson()["escrowPercentage"].toString());

  Map<dynamic, dynamic> toJson();

  @override
  List<Object?> get props => [id];
}
