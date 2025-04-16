import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';
import '../providers/road_surface_provider.dart';
import '../services/sensor_service.dart';
import '../widgets/pothole_detection_banner.dart';

class HomeScreen extends StatelessWidget {
  final String title;

  // Define min/max roughness thresholds for color mapping
  static const double _minRoughness = 0.0;
  static const double _maxRoughness =
      3.0; // Reduced from 5.0 for faster color transition

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => SensorService()),
        ChangeNotifierProxyProvider<SensorService, AccelerometerProvider>(
          create:
              (context) => AccelerometerProvider(
                Provider.of<SensorService>(context, listen: false),
              ),
          update:
              (context, sensorService, previous) =>
                  previous ?? AccelerometerProvider(sensorService),
        ),
        // Add the RoadSurfaceProvider
        ChangeNotifierProxyProvider<SensorService, RoadSurfaceProvider>(
          create:
              (context) => RoadSurfaceProvider(
                Provider.of<SensorService>(context, listen: false),
              ),
          update:
              (context, sensorService, previous) =>
                  previous ?? RoadSurfaceProvider(sensorService),
        ),
      ],
      child: Consumer2<RoadSurfaceProvider, AccelerometerProvider>(
        builder: (context, roadProvider, accelProvider, child) {
          // Check if device is moving
          bool isMoving = roadProvider.isMoving;

          // Get appropriate background color
          // Use grey when stationary, otherwise calculate from roughness index
          Color backgroundColor =
              isMoving
                  ? _getColorFromRoughnessIndex(roadProvider.roughnessIndex)
                  : Colors.grey;

          return AnimatedContainer(
            duration: const Duration(
              milliseconds: 300,
            ), // Reduced from 800ms to 300ms
            curve: Curves.easeInOut, // Makes the transition feel smoother
            color: backgroundColor,
            child: Scaffold(
              extendBodyBehindAppBar:
                  true, // Allow the body to extend behind the AppBar
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 300,
                  ), // Reduced from 800ms to 300ms
                  curve: Curves.easeInOut,
                  color: backgroundColor.withOpacity(0.8),
                  child: AppBar(
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
              backgroundColor:
                  Colors.transparent, // Make scaffold background transparent
              body: Stack(
                children: [
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Movement status indicator
                        AnimatedOpacity(
                          opacity: isMoving ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          child:
                              !isMoving
                                  ? Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.directions_car,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'Waiting for movement...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : const SizedBox(),
                        ),

                        // Large roughness index display
                        Text(
                          roadProvider.roughnessIndex.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Surface quality label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            roadProvider.surfaceQuality,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Label for roughness index
                        const Text(
                          'Road Roughness Index',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Pothole detection banner
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: AnimatedOpacity(
                      opacity: accelProvider.potholeDetected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child:
                          accelProvider.potholeDetected
                              ? PotholeDetectionBanner(
                                detectionTime: accelProvider.lastPotholeTime,
                              )
                              : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColorFromRoughnessIndex(double roughnessIndex) {
    // If roughness is below threshold, stay green
    if (roughnessIndex < 0.3) {
      return Colors.green;
    }

    // Normalize roughness between 0.3 and max for color transitions
    double normalizedRoughness =
        ((roughnessIndex - 0.3).clamp(0.0, _maxRoughness - 0.3)) /
        (_maxRoughness - 0.3);

    // Create a gradient from green to yellow to red
    if (normalizedRoughness <= 0.4) {
      // From green to yellow (0.0 - 0.4 normalized range)
      double t = normalizedRoughness / 0.4;
      return Color.lerp(Colors.green, Colors.yellow.shade700, t)!;
    } else {
      // From yellow to red (0.4 - 1.0 normalized range)
      double t = (normalizedRoughness - 0.4) / 0.6;
      return Color.lerp(Colors.yellow.shade700, Colors.red, t)!;
    }
  }
}
