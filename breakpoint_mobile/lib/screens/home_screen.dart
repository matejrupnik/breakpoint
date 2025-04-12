import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/accelerometer_provider.dart';
import '../services/sensor_service.dart';
import '../widgets/accelerometer_chart.dart';

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
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                'Pothole Detection App',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'This application helps detect potholes while driving to improve road safety.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const AccelerometerChart(),
            ],
          ),
        ),
      ),
    );
  }
}
