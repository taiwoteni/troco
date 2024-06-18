import 'package:troco/features/transactions/utils/enums.dart';

class ProductQualityConverter {
  static ProductQuality convertToEnum({required final String quality}) {
    switch (quality.toLowerCase()) {
      case 'good quality':
        return ProductQuality.Good;
      case 'faulty quality':
        return ProductQuality.Faulty;
      case 'high quality':
        return ProductQuality.High;
      default:
        return ProductQuality.Low;
    }
  }

  static String convertToString({required final ProductQuality quality}) {
    switch (quality) {
      case ProductQuality.Faulty:
        return "Faulty Quality";
      case ProductQuality.Good:
        return "Good Quality";
      case ProductQuality.High:
        return "High Quality";
      default:
        return "Low Quality";
    }
  }
}
