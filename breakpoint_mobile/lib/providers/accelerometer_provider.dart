import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/accelerometer_data.dart';
import '../services/sensor_service.dart';
import '../services/pothole_api_service.dart';

class AccelerometerProvider with ChangeNotifier {
  final SensorService _sensorService;
  final PotholeApiService _apiService = PotholeApiService();
  final int _maxDataPoints;
  final ListQueue<AccelerometerData> _dataPoints =
      ListQueue<AccelerometerData>();

  StreamSubscription<AccelerometerData>? _subscription;

  // Pothole detection threshold (in m/s²)
  // Significant vertical acceleration change indicates a pothole
  double _potholeThreshold = 5.0;

  // Getter and setter for pothole threshold
  double get potholeThreshold => _potholeThreshold;
  set potholeThreshold(double value) {
    _potholeThreshold = value;
    notifyListeners();
  }

  // Flag to track if a pothole was detected
  bool _potholeDetected = false;
  bool get potholeDetected => _potholeDetected;

  // Timestamp of the last detected pothole
  DateTime? _lastPotholeTime;
  DateTime? get lastPotholeTime => _lastPotholeTime;

  // Getter for the data points for the chart
  List<AccelerometerData> get dataPoints => List.unmodifiable(_dataPoints);

  // Maximum and minimum values for vertical acceleration (for chart scaling)
  double _minVertical = -10.0;
  double _maxVertical = 10.0;

  double get minVertical => _minVertical;
  double get maxVertical => _maxVertical;

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

    // Update min/max vertical values for chart scaling
    if (data.verticalAcceleration < _minVertical)
      _minVertical = data.verticalAcceleration;
    if (data.verticalAcceleration > _maxVertical)
      _maxVertical = data.verticalAcceleration;

    // Check for pothole based on vertical acceleration
    _checkForPothole(data);

    // Notify listeners about the data change
    notifyListeners();
  }

  void _checkForPothole(AccelerometerData data) {
    // We need at least 3 data points to detect the pattern of a pothole
    if (_dataPoints.length >= 3) {
      // Get the previous two data points
      final previousData = _dataPoints.elementAt(_dataPoints.length - 2);
      final prePreviousData = _dataPoints.elementAt(_dataPoints.length - 3);

      // Calculate vertical acceleration changes between consecutive readings
      final firstChange =
          previousData.verticalAcceleration -
          prePreviousData.verticalAcceleration;
      final secondChange =
          data.verticalAcceleration - previousData.verticalAcceleration;

      // For a pothole:
      // 1. First change should be negative (falling into pothole)
      // 2. Second change should be positive (coming out of pothole)
      // 3. Both changes should be significant (exceed threshold)

      if (firstChange < -_potholeThreshold &&
          secondChange > _potholeThreshold) {
        // This pattern indicates a pothole - negative change followed by positive change
        _potholeDetected = true;
        _lastPotholeTime = data.timestamp;

        // Make an API call to report the pothole
        _reportPothole(data);

        // Reset the detection flag after 1 second to allow for new detections
        Future.delayed(const Duration(seconds: 1), () {
          _potholeDetected = false;
          notifyListeners();
        });
      }
    }
  }

  // Report pothole to the API service
  Future<void> _reportPothole(AccelerometerData data) async {
    try {
      final success = await _apiService.reportPothole(
        data: data,
        threshold: _potholeThreshold,
      );

      if (kDebugMode) {
        print('Pothole report ${success ? 'successful' : 'failed'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reporting pothole: $e');
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
