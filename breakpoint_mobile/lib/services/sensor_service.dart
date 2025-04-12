import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/accelerometer_data.dart';
import 'package:vector_math/vector_math.dart';

class SensorService {
  // Stream controller to broadcast accelerometer data
  final _accelerometerStreamController =
      StreamController<AccelerometerData>.broadcast();

  // Stream to access from outside the service
  Stream<AccelerometerData> get accelerometerStream =>
      _accelerometerStreamController.stream;

  // Subscriptions to the sensor events
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;

  // Set the sampling interval to control frequency (in milliseconds)
  // 20ms = 50Hz, 50ms = 20Hz, 100ms = 10Hz
  final int _samplingIntervalMs = 50; // 20Hz sampling rate

  DateTime? _lastSampleTime;

  // Current device orientation data
  final Vector3 _gravity = Vector3(
    0,
    0,
    9.81,
  ); // Default gravity vector pointing down

  // Buffer for user acceleration (without gravity)
  final Vector3 _userAcceleration = Vector3.zero();

  // Initialize the service and start listening to the sensors
  void initialize() {
    // Subscribe to accelerometer to get raw acceleration (including gravity)
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      // Update our estimate of the gravity vector
      // We use a simple low-pass filter
      const double alpha = 0.8; // Filter coefficient
      _gravity.x = alpha * _gravity.x + (1 - alpha) * event.x;
      _gravity.y = alpha * _gravity.y + (1 - alpha) * event.y;
      _gravity.z = alpha * _gravity.z + (1 - alpha) * event.z;

      // Process data at the specified sampling rate
      _processSensorData();
    });

    // Subscribe to user accelerometer (acceleration without gravity)
    _userAccelerometerSubscription = userAccelerometerEvents.listen((
      UserAccelerometerEvent event,
    ) {
      // Store user acceleration
      _userAcceleration.x = event.x;
      _userAcceleration.y = event.y;
      _userAcceleration.z = event.z;

      // We don't process here - we'll process in the accelerometer callback
    });
  }

  void _processSensorData() {
    final now = DateTime.now();

    // Only process data at the specified sampling rate
    if (_lastSampleTime == null ||
        now.difference(_lastSampleTime!).inMilliseconds >=
            _samplingIntervalMs) {
      _lastSampleTime = now;

      // Calculate vertical acceleration relative to Earth
      // Normalize the gravity vector
      final normalizedGravity = _gravity.normalized();

      // Project user acceleration onto normalized gravity vector to get vertical component
      // Dot product gives us projection magnitude
      final verticalAcceleration = _userAcceleration.dot(normalizedGravity);

      final data = AccelerometerData(
        x: _userAcceleration.x,
        y: _userAcceleration.y,
        z: _userAcceleration.z,
        verticalAcceleration: verticalAcceleration,
        timestamp: now,
      );

      _accelerometerStreamController.add(data);
    }
  }

  // Dispose the service and stop listening to the sensors
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _accelerometerStreamController.close();
  }
}
