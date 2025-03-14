import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AnalyticsChart extends StatelessWidget {
  final List<charts.Series> seriesList;

  AnalyticsChart(this.seriesList);

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(seriesList);
  }
}
