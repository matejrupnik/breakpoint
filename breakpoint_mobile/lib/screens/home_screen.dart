import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';
import '../providers/road_surface_provider.dart';
import '../services/sensor_service.dart';
import '../widgets/pothole_detection_banner.dart';

class HomeScreen extends StatelessWidget {
  final String title;

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
          // Get background color based on road quality
          Color backgroundColor = _getSurfaceQualityColor(
            roadProvider.surfaceQuality,
          );
          bool isMoving = roadProvider.isMoving;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: backgroundColor.withOpacity(0.8),
              elevation: 0,
            ),
            backgroundColor: backgroundColor,
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

                      const SizedBox(height: 8),

                      // Label for roughness index
                      const Text(
                        'Roughness Index',
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
          );
        },
      ),
    );
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
