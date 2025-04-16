import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';

class AccelerometerChart extends StatelessWidget {
  const AccelerometerChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccelerometerProvider>(
      builder: (context, provider, child) {
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

        // When moving - instead of graph, show a card indicating active monitoring
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
                  Icons.sensors,
                  size: 48,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'Pothole Detection Active',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.green,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitoring road surface. Potholes will be automatically detected and reported.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Small indicator showing active status
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
