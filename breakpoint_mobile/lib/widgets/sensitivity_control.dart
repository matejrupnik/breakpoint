import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';

class SensitivityControl extends StatelessWidget {
  const SensitivityControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccelerometerProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pothole Detection Sensitivity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Text('High Sensitivity'),
                    Spacer(),
                    Text('Low Sensitivity'),
                  ],
                ),
                Slider(
                  value: provider.potholeThreshold,
                  min: 1.0,
                  max: 10.0,
                  divisions: 18,
                  label: provider.potholeThreshold.toStringAsFixed(1),
                  onChanged: (value) {
                    provider.potholeThreshold = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
