import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/accelerometer_data.dart';
import 'location_service.dart';

class PotholeApiService {
  // Mock API endpoint - in a real app, this would be your actual endpoint
  final String _baseUrl = 'https://api.example.com/potholes';
  final LocationService _locationService = LocationService();
  
  // Send pothole detection data to the API
  Future<bool> reportPothole({
    required AccelerometerData data,
    required double threshold,
  }) async {
    try {
      // Get current location
      final Position? position = await _locationService.getCurrentPosition();
      
      // For now, we'll simulate the API call with a delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Print to console for debugging
      print('🕳️ POTHOLE DETECTED: Mock API call to $_baseUrl');
      print('  - Vertical acceleration: ${data.verticalAcceleration.toStringAsFixed(2)} m/s²');
      print('  - Threshold used: ${threshold.toStringAsFixed(2)} m/s²');
      print('  - Time: ${data.timestamp}');
      
      if (position != null) {
        print('  - Location: ${position.latitude}, ${position.longitude}');
      } else {
        print('  - Location: Unknown (could not get coordinates)');
      }
      
      // In a real implementation, you would make an actual HTTP request:
      /*
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'timestamp': data.timestamp.toIso8601String(),
          'verticalAcceleration': data.verticalAcceleration,
          'rawAcceleration': {
            'x': data.x,
            'y': data.y,
            'z': data.z,
          },
          'threshold': threshold,
          'location': position != null ? {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
          } : null,
        }),
      );
      
      return response.statusCode >= 200 && response.statusCode < 300;
      */
      
      // Return success for mock implementation
      return true;
    } catch (e) {
      print('Error reporting pothole: $e');
      return false;
    }
  }
}
