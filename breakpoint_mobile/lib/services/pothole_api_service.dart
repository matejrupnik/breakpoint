import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/accelerometer_data.dart';
import 'location_service.dart';

class PotholeApiService {
  // API endpoint for reporting potholes
  final String _baseUrl = 'http://165.232.115.82:4000/api/surface';
  final LocationService _locationService = LocationService();

  // Device fingerprint (hardcoded for now, should be dynamically generated in production)
  final String _deviceFingerprint = '51e7f4a6-b140-4726-a8bb-5e2b1f5aa88f';

  // Send pothole detection data to the API
  Future<bool> reportPothole({
    required AccelerometerData data,
    required double threshold,
  }) async {
    try {
      // Get current location
      final Position? position = await _locationService.getCurrentPosition();

      if (position == null) {
        print('Error: Could not get device location');
        return false;
      }

      // Surface reading (hardcoded for now, should use actual value in production)
      const double surfaceReading = 1.1;

      // Print to console for debugging
      print('🕳️ POTHOLE DETECTED: Sending data to $_baseUrl');
      print('  - Device Fingerprint: $_deviceFingerprint');
      print('  - Surface Reading: $surfaceReading');
      print('  - Location: ${position.latitude}, ${position.longitude}');
      print(
        '  - Vertical acceleration: ${data.verticalAcceleration.toStringAsFixed(2)} m/s²',
      );

      // Make the actual HTTP request
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_fingerprint': _deviceFingerprint,
          'surface_reading': surfaceReading,
          'longitude': position.longitude,
          'latitude': position.latitude,
        }),
      );

      final bool isSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccess) {
        print('API Error: ${response.statusCode} - ${response.body}');
      }

      return isSuccess;
    } catch (e) {
      print('Error reporting pothole: $e');
      return false;
    }
  }
}
