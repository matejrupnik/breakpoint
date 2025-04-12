import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';
import '../providers/road_surface_provider.dart';
import '../services/sensor_service.dart';
import '../widgets/accelerometer_chart.dart';
import '../widgets/pothole_detection_banner.dart';
import '../widgets/sensitivity_control.dart';
import '../widgets/road_surface_indicator.dart';

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
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Road surface indicator moved to the top
                  const RoadSurfaceIndicator(),

                  // Sensitivity control now second
                  const SensitivityControl(),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const AccelerometerChart(),
                ],
              ),
            ),
            // Pothole detection banner that shows when a pothole is detected
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Consumer<AccelerometerProvider>(
                builder: (context, provider, child) {
                  // Only show the banner when a pothole is detected
                  if (!provider.potholeDetected) {
                    return const SizedBox.shrink(); // Return empty widget when no pothole detected
                  }

                  // Show the banner with an animation
                  return AnimatedOpacity(
                    opacity: provider.potholeDetected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: PotholeDetectionBanner(
                      detectionTime: provider.lastPotholeTime,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
