import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';

class AccelerometerChart extends StatelessWidget {
  const AccelerometerChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccelerometerProvider>(
      builder: (context, provider, child) {
        final dataPoints = provider.dataPoints;
        final isMoving = provider.isMoving;

        // Check if we're not moving - we should show a prompt
        if (!isMoving) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Waiting for Movement',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drive your vehicle. Sensor recording will begin automatically when sustained movement is detected.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Add progress indicator to show we're actively waiting
                  const LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          );
        }

        // If we are moving but no data yet
        if (dataPoints.isEmpty) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Movement Detected!',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collecting sensor data...',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Colors.green),
                ],
              ),
            ),
          );
        }

        // Otherwise, show the chart as before
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
