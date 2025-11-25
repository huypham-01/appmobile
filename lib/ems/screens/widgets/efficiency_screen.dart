import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/ems/data/models/machine_model.dart';

class HourlyBarChart extends StatelessWidget {
  final List<HourlyDataModel> data;

  const HourlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            data.map((e) => e.avgEfficiency).reduce((a, b) => a > b ? a : b) +
            10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int hour = value.toInt();
                if (hour % 2 == 0) {
                  return Text('aa', style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data
            .map(
              (e) => BarChartGroupData(
                x: e.hour,
                barRods: [
                  BarChartRodData(
                    toY: e.avgEfficiency,
                    color: e.avgEfficiency >= 100
                        ? Colors.green
                        : e.avgEfficiency >= 95
                        ? Colors.orange
                        : Colors.red,
                    width: 10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
