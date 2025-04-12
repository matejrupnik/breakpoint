import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/road_surface_provider.dart';

class RoadSurfaceIndicator extends StatelessWidget {
  const RoadSurfaceIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoadSurfaceProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Road Surface Quality',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQualityMeter(context, provider),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Roughness Index',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          provider.roughnessIndex.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getSurfaceQualityColor(provider.surfaceQuality),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        provider.surfaceQuality,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQualityMeter(
    BuildContext context,
    RoadSurfaceProvider provider,
  ) {
    return SizedBox(
      height: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: _getProgressValue(provider.roughnessIndex),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getSurfaceQualityColor(provider.surfaceQuality),
          ),
        ),
      ),
    );
  }

  double _getProgressValue(double roughnessIndex) {
    // Map roughness to a 0-1 progress value
    // Using a max roughness of 10 as reference
    double value = roughnessIndex / 10.0;
    return value.clamp(0.05, 1.0); // Min 5% to always show some progress
  }

  Color _getSurfaceQualityColor(String quality) {
    switch (quality) {
      case 'Smooth':
        return Colors.green;
      case 'Moderate':
        return Colors.yellow.shade700;
      case 'Rough':
        return Colors.orange;
      case 'Very Rough':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
