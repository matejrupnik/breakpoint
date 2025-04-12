import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/accelerometer_data.dart';
import '../services/sensor_service.dart';

class AccelerometerProvider with ChangeNotifier {
  final SensorService _sensorService;
  final int _maxDataPoints;
  final ListQueue<AccelerometerData> _dataPoints =
      ListQueue<AccelerometerData>();

  StreamSubscription<AccelerometerData>? _subscription;

  // Getter for the z-axis data points for the chart
  List<AccelerometerData> get dataPoints => List.unmodifiable(_dataPoints);

  // Maximum and minimum values for z-axis (for chart scaling)
  double _minZ = -10.0;
  double _maxZ = 10.0;

  double get minZ => _minZ;
  double get maxZ => _maxZ;

  AccelerometerProvider(this._sensorService, {int maxDataPoints = 50})
    : _maxDataPoints = maxDataPoints {
    _initialize();
  }

  void _initialize() {
    // Start the sensor service
    _sensorService.initialize();

    // Subscribe to sensor data
    _subscription = _sensorService.accelerometerStream.listen(
      _handleSensorData,
    );
  }

  void _handleSensorData(AccelerometerData data) {
    // Add new data point
    _dataPoints.add(data);

    // Remove oldest data point if we exceed the max number
    if (_dataPoints.length > _maxDataPoints) {
      _dataPoints.removeFirst();
    }

    // Update min/max z values for chart scaling
    if (data.z < _minZ) _minZ = data.z;
    if (data.z > _maxZ) _maxZ = data.z;

    // Notify listeners about the data change
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
