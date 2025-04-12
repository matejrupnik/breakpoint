import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/accelerometer_data.dart';
import '../services/sensor_service.dart';

class RoadSurfaceProvider with ChangeNotifier {
  final SensorService _sensorService;

  // Store 5 seconds of data at 20Hz sampling rate (100 samples)
  final int _windowSize = 100;
  final ListQueue<AccelerometerData> _dataWindow =
      ListQueue<AccelerometerData>();

  StreamSubscription<AccelerometerData>? _subscription;

  // Road quality metrics
  double _roughnessIndex = 0.0;
  String _surfaceQuality = 'Unknown';

  // Getters for road quality metrics
  double get roughnessIndex => _roughnessIndex;
  String get surfaceQuality => _surfaceQuality;

  // Moving average of vertical acceleration
  double _baselineAcceleration = 0.0;

  // Quality thresholds
  final double _smoothThreshold = 0.8;
  final double _moderateThreshold = 2.0;
  final double _roughThreshold = 4.0;

  RoadSurfaceProvider(this._sensorService) {
    _initialize();
  }

  void _initialize() {
    // We'll reuse the same sensor service that's used for pothole detection
    _subscription = _sensorService.accelerometerStream.listen(
      _processSensorData,
    );
  }

  void _processSensorData(AccelerometerData data) {
    // Add data to our window
    _dataWindow.add(data);

    // Keep only the most recent 5 seconds of data
    if (_dataWindow.length > _windowSize) {
      _dataWindow.removeFirst();
    }

    // Only analyze when we have enough data
    if (_dataWindow.length >= 10) {
      _analyzeRoadSurface();
    }
  }

  void _analyzeRoadSurface() {
    if (_dataWindow.isEmpty) return;

    // Calculate the standard deviation of vertical acceleration
    double sum = 0;
    double sumSquared = 0;

    // First pass: calculate mean
    for (var data in _dataWindow) {
      sum += data.verticalAcceleration;
    }
    double mean = sum / _dataWindow.length;

    // Update baseline with exponential moving average
    const alpha = 0.05;
    _baselineAcceleration = (1 - alpha) * _baselineAcceleration + alpha * mean;

    // Second pass: calculate standard deviation
    for (var data in _dataWindow) {
      double deviation = data.verticalAcceleration - _baselineAcceleration;
      sumSquared += deviation * deviation;
    }

    double variance = sumSquared / _dataWindow.length;
    double stdDev = sqrt(variance);

    // Update roughness index (scale to a more intuitive range)
    _roughnessIndex = stdDev;

    // Categorize road quality based on roughness
    if (_roughnessIndex < _smoothThreshold) {
      _surfaceQuality = 'Smooth';
    } else if (_roughnessIndex < _moderateThreshold) {
      _surfaceQuality = 'Moderate';
    } else if (_roughnessIndex < _roughThreshold) {
      _surfaceQuality = 'Rough';
    } else {
      _surfaceQuality = 'Very Rough';
    }

    // Notify listeners of the updated metrics
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
