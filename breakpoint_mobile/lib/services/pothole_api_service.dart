import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accelerometer_data.dart';

class PotholeApiService {
  // Mock API endpoint - in a real app, this would be your actual endpoint
  final String _baseUrl = '165.232.115.82:4000/api';

  // Send pothole detection data to the API
  Future<bool> reportPothole({
    required AccelerometerData data,
    required double threshold,
  }) async {
    try {
      // For now, we'll simulate the API call with a delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Print to console for debugging
      print('🕳️ POTHOLE DETECTED: Mock API call to $_baseUrl');
      print(
        '  - Vertical acceleration: ${data.verticalAcceleration.toStringAsFixed(2)} m/s²',
      );
      print('  - Threshold used: ${threshold.toStringAsFixed(2)} m/s²');
      print('  - Time: ${data.timestamp}');

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
          // Additional fields like location would be added here
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
