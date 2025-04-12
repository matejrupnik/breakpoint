import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/accelerometer_data.dart';

class SensorService {
  // Stream controller to broadcast accelerometer data
  final _accelerometerStreamController =
      StreamController<AccelerometerData>.broadcast();

  // Stream to access from outside the service
  Stream<AccelerometerData> get accelerometerStream =>
      _accelerometerStreamController.stream;

  // Subscription to the sensor events
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Initialize the service and start listening to the accelerometer
  void initialize() {
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      final data = AccelerometerData(
        x: event.x,
        y: event.y,
        z: event.z,
        timestamp: DateTime.now(),
      );
      _accelerometerStreamController.add(data);
    });
  }

  // Dispose the service and stop listening to the accelerometer
  void dispose() {
    _accelerometerSubscription?.cancel();
    _accelerometerStreamController.close();
  }
}
