/// Represents IMU (Inertial Measurement Unit) data from a Muse device.
/// 
/// Includes 3-axis gyroscope and accelerometer readings.
/// Useful for detecting head motion and correlating with EEG artifacts.
class IMUSample {
  /// Device ID this sample came from
  final String deviceId;
  
  /// Timestamp when this sample was captured
  final DateTime timestamp;
  
  /// Milliseconds elapsed since recording session started
  final int msElapsed;
  
  /// Gyroscope X-axis (rotation around X, degrees/second)
  final double? gyroX;
  
  /// Gyroscope Y-axis (rotation around Y, degrees/second)
  final double? gyroY;
  
  /// Gyroscope Z-axis (rotation around Z, degrees/second)
  final double? gyroZ;
  
  /// Accelerometer X-axis (m/s²)
  final double? accelX;
  
  /// Accelerometer Y-axis (m/s²)
  final double? accelY;
  
  /// Accelerometer Z-axis (m/s²)
  final double? accelZ;

  const IMUSample({
    required this.deviceId,
    required this.timestamp,
    required this.msElapsed,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.accelX,
    this.accelY,
    this.accelZ,
  });

  /// Creates sample from platform channel data
  factory IMUSample.fromJson(Map<String, dynamic> json) => IMUSample(
    deviceId: json['deviceId'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    msElapsed: json['msElapsed'] as int,
    gyroX: (json['gyroX'] as num?)?.toDouble(),
    gyroY: (json['gyroY'] as num?)?.toDouble(),
    gyroZ: (json['gyroZ'] as num?)?.toDouble(),
    accelX: (json['accelX'] as num?)?.toDouble(),
    accelY: (json['accelY'] as num?)?.toDouble(),
    accelZ: (json['accelZ'] as num?)?.toDouble(),
  );

  /// Converts to CSV row values
  Map<String, dynamic> toCsvMap() => {
    'DEVICE_ID': deviceId,
    'CLOCK_TIME': timestamp.toUtc().toIso8601String(),
    'ms_ELAPSED': msElapsed,
    'GYRO_X': gyroX?.toStringAsFixed(6) ?? '',
    'GYRO_Y': gyroY?.toStringAsFixed(6) ?? '',
    'GYRO_Z': gyroZ?.toStringAsFixed(6) ?? '',
    'ACCEL_X': accelX?.toStringAsFixed(6) ?? '',
    'ACCEL_Y': accelY?.toStringAsFixed(6) ?? '',
    'ACCEL_Z': accelZ?.toStringAsFixed(6) ?? '',
  };

  @override
  String toString() => 'IMUSample(device: $deviceId, time: $timestamp)';
}
