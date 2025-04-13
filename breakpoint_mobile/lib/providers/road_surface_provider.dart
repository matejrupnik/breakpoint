import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/accelerometer_data.dart';
import '../services/sensor_service.dart';
import '../services/pothole_api_service.dart';

class RoadSurfaceProvider with ChangeNotifier {
  final SensorService _sensorService;
  final PotholeApiService _apiService = PotholeApiService();

  // Store 2 seconds of data at 20Hz sampling rate (40 samples)
  final int _windowSize = 40;
  final ListQueue<AccelerometerData> _dataWindow =
      ListQueue<AccelerometerData>();

  // Track recent data to detect rapid stabilization
  final int _recentDataSize = 10; // Last 0.5 seconds (at 20Hz)

  StreamSubscription<AccelerometerData>? _subscription;
  StreamSubscription<bool>? _motionSubscription;
  Timer? _reportingTimer;

  // Motion state tracking
  bool _isMoving = false;
  bool get isMoving => _isMoving;

  // Road quality metrics
  double _roughnessIndex = 0.0;
  String _surfaceQuality = 'Unknown';

  // Getters for road quality metrics
  double get roughnessIndex => _roughnessIndex;
  String get surfaceQuality => _surfaceQuality;

  // Moving average of vertical acceleration
  double _baselineAcceleration = 0.0;

  // Quality thresholds with getters (hard-coded to defaults)
  final double _smoothThreshold = 0.8;
  final double _moderateThreshold = 2.0;
  final double _roughThreshold = 4.0;

  // Getters for thresholds (no setters as values are now fixed)
  double get smoothThreshold => _smoothThreshold;
  double get moderateThreshold => _moderateThreshold;
  double get roughThreshold => _roughThreshold;

  // Flags to track stability
  bool _wasRecentlyStable = false;
  int _stableCounter = 0;

  // Reporting configuration
  bool _isReportingEnabled = true;
  bool get isReportingEnabled => _isReportingEnabled;
  set isReportingEnabled(bool value) {
    if (_isReportingEnabled != value) {
      _isReportingEnabled = value;
      if (_isReportingEnabled) {
        _startReporting();
      } else {
        _stopReporting();
      }
      notifyListeners();
    }
  }

  RoadSurfaceProvider(this._sensorService) {
    _initialize();
  }

  void _initialize() {
    // We'll reuse the same sensor service that's used for pothole detection
    _subscription = _sensorService.accelerometerStream.listen(
      _processSensorData,
    );

    // Listen for motion state changes
    _motionSubscription = _sensorService.motionStateStream.listen(
      _handleMotionStateChange,
    );

    // Start the reporting timer
    _startReporting();
  }

  void _handleMotionStateChange(bool isMoving) {
    if (_isMoving != isMoving) {
      _isMoving = isMoving;

      if (!isMoving) {
        // Clear data when stopped
        _dataWindow.clear();
        _roughnessIndex = 0.0;
        _surfaceQuality = 'Unknown';
      }

      notifyListeners();
    }
  }

  void _startReporting() {
    // Cancel any existing timer
    _reportingTimer?.cancel();

    // Create a new timer that fires every 500ms (half second)
    _reportingTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _reportRoughness(),
    );
  }

  void _stopReporting() {
    _reportingTimer?.cancel();
    _reportingTimer = null;
  }

  Future<void> _reportRoughness() async {
    // Only report when moving and roughness is significant
    if (!_isReportingEnabled || !_isMoving || _roughnessIndex <= 0) return;

    try {
      final result = await _apiService.reportRoadRoughness(
        roughnessIndex: _roughnessIndex,
      );

      if (kDebugMode && result) {
        print('Successfully reported roughness: $_roughnessIndex');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reporting roughness: $e');
      }
    }
  }

  void _processSensorData(AccelerometerData data) {
    // Only process data when the vehicle is moving
    if (!_isMoving) return;

    // Add data to our window
    _dataWindow.add(data);

    // Keep only the most recent 2 seconds of data
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

    // Update baseline with exponential moving average - faster adaptation
    const alpha = 0.2; // Increased from 0.05 to 0.2 for faster adaptation
    _baselineAcceleration = (1 - alpha) * _baselineAcceleration + alpha * mean;

    // Second pass: calculate standard deviation
    for (var data in _dataWindow) {
      double deviation = data.verticalAcceleration - _baselineAcceleration;
      sumSquared += deviation * deviation;
    }

    double variance = sumSquared / _dataWindow.length;
    double stdDev = sqrt(variance);

    // Check for rapid stabilization: analyze just the most recent samples
    if (_dataWindow.length >= _recentDataSize) {
      double recentSum = 0;
      double recentSumSquared = 0;
      double recentMean = 0;

      // Get most recent samples
      List<AccelerometerData> recentData = _dataWindow.toList().sublist(
        _dataWindow.length - _recentDataSize,
      );

      // Calculate mean for recent data
      for (var data in recentData) {
        recentSum += data.verticalAcceleration;
      }
      recentMean = recentSum / _recentDataSize;

      // Calculate variance for recent data
      for (var data in recentData) {
        double deviation = data.verticalAcceleration - recentMean;
        recentSumSquared += deviation * deviation;
      }

      double recentVariance = recentSumSquared / _recentDataSize;
      double recentStdDev = sqrt(recentVariance);

      // If recent data is very stable (much more stable than full window)
      // and overall roughness is above smooth threshold
      if (recentStdDev < 0.3 && stdDev > _smoothThreshold) {
        _stableCounter++;

        // If stable for a few consecutive readings, force quicker transition
        if (_stableCounter >= 3) {
          _wasRecentlyStable = true;
          // Blend the full window result with recent stable result
          stdDev = stdDev * 0.3 + recentStdDev * 0.7;
        }
      } else {
        _stableCounter = 0;
        _wasRecentlyStable = false;
      }
    }

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
    _motionSubscription?.cancel();
    _reportingTimer?.cancel();
    super.dispose();
  }
}
