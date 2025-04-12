class AccelerometerData {
  final double x;
  final double y;
  final double z;
  final double
  verticalAcceleration; // Acceleration in Earth's vertical direction
  final DateTime timestamp;

  AccelerometerData({
    required this.x,
    required this.y,
    required this.z,
    required this.verticalAcceleration,
    required this.timestamp,
  });
}
