import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';

class AccelerometerChart extends StatelessWidget {
  const AccelerometerChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccelerometerProvider>(
      builder: (context, provider, child) {
        final dataPoints = provider.dataPoints;

        if (dataPoints.isEmpty) {
          return const Center(
            child: Text('No accelerometer data available yet'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vertical Acceleration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Current: ${dataPoints.isNotEmpty ? dataPoints.last.verticalAcceleration.toStringAsFixed(2) : "0.00"} m/s²',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d)),
                    ),
                    minX: 0,
                    maxX: (dataPoints.length - 1).toDouble(),
                    minY: provider.minVertical,
                    maxY: provider.maxVertical,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          dataPoints.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            dataPoints[index].verticalAcceleration,
                          ),
                        ),
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    lineTouchData: const LineTouchData(enabled: false),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text('${value.toInt()}', style: style),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(value.toStringAsFixed(1), style: style),
    );
  }
}
