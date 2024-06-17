import 'package:fl_chart/fl_chart.dart';

extension PieChartExtension on PieChart {
  PieChart animateSections({required final List<PieChartSectionData> section}) {
    return PieChart(
      data.copyWith(sections: section),
      swapAnimationCurve: curve,
      swapAnimationDuration: duration,
    );
  }
  PieChart animateValuesFactor({required final List<PieChartSectionData> section, required final double factor}) {
    return PieChart(
      data.copyWith(sections: section.map((e) => e.copyWith(value:e.value*factor),).toList()),
      swapAnimationCurve: curve,
      swapAnimationDuration: duration,
    );
  }


}
