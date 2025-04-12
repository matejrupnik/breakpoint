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

  // Pothole detection threshold (in m/s²)
  // Significant z-axis acceleration change indicates a pothole
  final double _potholeThreshold = 5.0;
  
  // Flag to track if a pothole was detected
  bool _potholeDetected = false;
  bool get potholeDetected => _potholeDetected;
  
  // Timestamp of the last detected pothole
  DateTime? _lastPotholeTime;
  DateTime? get lastPotholeTime => _lastPotholeTime;

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

    // Check for pothole based on z-axis acceleration
    _checkForPothole(data);

    // Notify listeners about the data change
    notifyListeners();
  }

  void _checkForPothole(AccelerometerData data) {
    // If we have at least 2 data points, we can check for sudden changes
    if (_dataPoints.length >= 2) {
      // Get the previous data point
      final previousData = _dataPoints.elementAt(_dataPoints.length - 2);
      
      // Calculate the absolute difference in z-axis acceleration
      final zDifference = (data.z - previousData.z).abs();
      
      // If the difference exceeds our threshold, it's likely a pothole
      if (zDifference > _potholeThreshold) {
        // Update pothole detection status
        _potholeDetected = true;
        _lastPotholeTime = data.timestamp;
        
        // Reset the detection flag after 3 seconds to allow for new detections
        Future.delayed(const Duration(seconds: 3), () {
          _potholeDetected = false;
          notifyListeners();
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}
