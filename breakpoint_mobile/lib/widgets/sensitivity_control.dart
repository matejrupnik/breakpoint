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
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      'Current sensitivity: ${provider.potholeThreshold.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
