/// Represents fNIRS (functional Near-Infrared Spectroscopy) data from Muse S Athena.
/// 
/// Captures photodiode intensities at multiple wavelengths:
/// - 730nm and 850nm (for oxyhemoglobin/deoxyhemoglobin calculation)
/// - RED and AMBIENT (for motion artifact correction)
/// 
/// Each wavelength has readings for LEFT/RIGHT and OUTER/INNER positions.
class FNIRSSample {
  /// Device ID this sample came from
  final String deviceId;
  
  /// Timestamp when this sample was captured
  final DateTime timestamp;
  
  /// Milliseconds elapsed since recording session started
  final int msElapsed;
  
  // 730nm wavelength (for deoxyhemoglobin)
  final double? nm730LeftOuter;
  final double? nm730RightOuter;
  final double? nm730LeftInner;
  final double? nm730RightInner;
  
  // 850nm wavelength (for oxyhemoglobin)
  final double? nm850LeftOuter;
  final double? nm850RightOuter;
  final double? nm850LeftInner;
  final double? nm850RightInner;
  
  // RED wavelength
  final double? redLeftOuter;
  final double? redRightOuter;
  final double? redLeftInner;
  final double? redRightInner;
  
  // AMBIENT light (for noise correction)
  final double? ambientLeftOuter;
  final double? ambientRightOuter;
  final double? ambientLeftInner;
  final double? ambientRightInner;

  const FNIRSSample({
    required this.deviceId,
    required this.timestamp,
    required this.msElapsed,
    this.nm730LeftOuter,
    this.nm730RightOuter,
    this.nm730LeftInner,
    this.nm730RightInner,
    this.nm850LeftOuter,
    this.nm850RightOuter,
    this.nm850LeftInner,
    this.nm850RightInner,
    this.redLeftOuter,
    this.redRightOuter,
    this.redLeftInner,
    this.redRightInner,
    this.ambientLeftOuter,
    this.ambientRightOuter,
    this.ambientLeftInner,
    this.ambientRightInner,
  });

  /// Creates sample from platform channel data
  factory FNIRSSample.fromJson(Map<String, dynamic> json) => FNIRSSample(
    deviceId: json['deviceId'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    msElapsed: json['msElapsed'] as int,
    nm730LeftOuter: (json['nm730LeftOuter'] as num?)?.toDouble(),
    nm730RightOuter: (json['nm730RightOuter'] as num?)?.toDouble(),
    nm730LeftInner: (json['nm730LeftInner'] as num?)?.toDouble(),
    nm730RightInner: (json['nm730RightInner'] as num?)?.toDouble(),
    nm850LeftOuter: (json['nm850LeftOuter'] as num?)?.toDouble(),
    nm850RightOuter: (json['nm850RightOuter'] as num?)?.toDouble(),
    nm850LeftInner: (json['nm850LeftInner'] as num?)?.toDouble(),
    nm850RightInner: (json['nm850RightInner'] as num?)?.toDouble(),
    redLeftOuter: (json['redLeftOuter'] as num?)?.toDouble(),
    redRightOuter: (json['redRightOuter'] as num?)?.toDouble(),
    redLeftInner: (json['redLeftInner'] as num?)?.toDouble(),
    redRightInner: (json['redRightInner'] as num?)?.toDouble(),
    ambientLeftOuter: (json['ambientLeftOuter'] as num?)?.toDouble(),
    ambientRightOuter: (json['ambientRightOuter'] as num?)?.toDouble(),
    ambientLeftInner: (json['ambientLeftInner'] as num?)?.toDouble(),
    ambientRightInner: (json['ambientRightInner'] as num?)?.toDouble(),
  );

  /// Computes oxygenation proxy (ratio of 850nm to 730nm)
  /// Higher ratio suggests more oxyhemoglobin relative to deoxyhemoglobin
  double? getOxygenationRatio(String position) {
    double? nm850;
    double? nm730;
    
    switch (position) {
      case 'leftOuter':
        nm850 = nm850LeftOuter;
        nm730 = nm730LeftOuter;
        break;
      case 'rightOuter':
        nm850 = nm850RightOuter;
        nm730 = nm730RightOuter;
        break;
      case 'leftInner':
        nm850 = nm850LeftInner;
        nm730 = nm730LeftInner;
        break;
      case 'rightInner':
        nm850 = nm850RightInner;
        nm730 = nm730RightInner;
        break;
      default:
        return null;
    }
    
    if (nm850 != null && nm730 != null && nm730 != 0) {
      return nm850 / nm730;
    }
    return null;
  }

  /// Converts to CSV row values
  Map<String, dynamic> toCsvMap() => {
    'DEVICE_ID': deviceId,
    'CLOCK_TIME': timestamp.toUtc().toIso8601String(),
    'ms_ELAPSED': msElapsed,
    '730nm_LEFT_OUTER': nm730LeftOuter?.toStringAsFixed(6) ?? '',
    '730nm_RIGHT_OUTER': nm730RightOuter?.toStringAsFixed(6) ?? '',
    '850nm_LEFT_OUTER': nm850LeftOuter?.toStringAsFixed(6) ?? '',
    '850nm_RIGHT_OUTER': nm850RightOuter?.toStringAsFixed(6) ?? '',
    '730nm_LEFT_INNER': nm730LeftInner?.toStringAsFixed(6) ?? '',
    '730nm_RIGHT_INNER': nm730RightInner?.toStringAsFixed(6) ?? '',
    '850nm_LEFT_INNER': nm850LeftInner?.toStringAsFixed(6) ?? '',
    '850nm_RIGHT_INNER': nm850RightInner?.toStringAsFixed(6) ?? '',
    'RED_LEFT_OUTER': redLeftOuter?.toStringAsFixed(6) ?? '',
    'RED_RIGHT_OUTER': redRightOuter?.toStringAsFixed(6) ?? '',
    'AMBIENT_LEFT_OUTER': ambientLeftOuter?.toStringAsFixed(6) ?? '',
    'AMBIENT_RIGHT_OUTER': ambientRightOuter?.toStringAsFixed(6) ?? '',
    'RED_LEFT_INNER': redLeftInner?.toStringAsFixed(6) ?? '',
    'RED_RIGHT_INNER': redRightInner?.toStringAsFixed(6) ?? '',
    'AMBIENT_LEFT_INNER': ambientLeftInner?.toStringAsFixed(6) ?? '',
    'AMBIENT_RIGHT_INNER': ambientRightInner?.toStringAsFixed(6) ?? '',
  };

  @override
  String toString() => 'FNIRSSample(device: $deviceId, time: $timestamp)';
}
