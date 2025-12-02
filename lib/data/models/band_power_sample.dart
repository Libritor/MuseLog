/// Represents band power data (absolute and relative) for EEG frequency bands.
/// 
/// Includes Delta, Theta, Alpha, Beta, and Gamma bands for all four electrodes.
/// Band powers are typically computed from FFT of raw EEG.
class BandPowerSample {
  /// Device ID this sample came from
  final String deviceId;
  
  /// Timestamp when this sample was captured
  final DateTime timestamp;
  
  /// Milliseconds elapsed since recording session started
  final int msElapsed;
  
  // ===== ABSOLUTE BAND POWERS =====
  
  // Delta (0.5-4 Hz) - Absolute
  final double? tp9DeltaAbsolute;
  final double? af7DeltaAbsolute;
  final double? af8DeltaAbsolute;
  final double? tp10DeltaAbsolute;
  
  // Theta (4-8 Hz) - Absolute
  final double? tp9ThetaAbsolute;
  final double? af7ThetaAbsolute;
  final double? af8ThetaAbsolute;
  final double? tp10ThetaAbsolute;
  
  // Alpha (8-13 Hz) - Absolute
  final double? tp9AlphaAbsolute;
  final double? af7AlphaAbsolute;
  final double? af8AlphaAbsolute;
  final double? tp10AlphaAbsolute;
  
  // Beta (13-30 Hz) - Absolute
  final double? tp9BetaAbsolute;
  final double? af7BetaAbsolute;
  final double? af8BetaAbsolute;
  final double? tp10BetaAbsolute;
  
  // Gamma (30-50 Hz) - Absolute
  final double? tp9GammaAbsolute;
  final double? af7GammaAbsolute;
  final double? af8GammaAbsolute;
  final double? tp10GammaAbsolute;
  
  // ===== RELATIVE BAND POWERS =====
  
  // Delta - Relative
  final double? tp9DeltaRelative;
  final double? af7DeltaRelative;
  final double? af8DeltaRelative;
  final double? tp10DeltaRelative;
  
  // Theta - Relative
  final double? tp9ThetaRelative;
  final double? af7ThetaRelative;
  final double? af8ThetaRelative;
  final double? tp10ThetaRelative;
  
  // Alpha - Relative
  final double? tp9AlphaRelative;
  final double? af7AlphaRelative;
  final double? af8AlphaRelative;
  final double? tp10AlphaRelative;
  
  // Beta - Relative
  final double? tp9BetaRelative;
  final double? af7BetaRelative;
  final double? af8BetaRelative;
  final double? tp10BetaRelative;
  
  // Gamma - Relative
  final double? tp9GammaRelative;
  final double? af7GammaRelative;
  final double? af8GammaRelative;
  final double? tp10GammaRelative;

  const BandPowerSample({
    required this.deviceId,
    required this.timestamp,
    required this.msElapsed,
    // Absolute
    this.tp9DeltaAbsolute,
    this.af7DeltaAbsolute,
    this.af8DeltaAbsolute,
    this.tp10DeltaAbsolute,
    this.tp9ThetaAbsolute,
    this.af7ThetaAbsolute,
    this.af8ThetaAbsolute,
    this.tp10ThetaAbsolute,
    this.tp9AlphaAbsolute,
    this.af7AlphaAbsolute,
    this.af8AlphaAbsolute,
    this.tp10AlphaAbsolute,
    this.tp9BetaAbsolute,
    this.af7BetaAbsolute,
    this.af8BetaAbsolute,
    this.tp10BetaAbsolute,
    this.tp9GammaAbsolute,
    this.af7GammaAbsolute,
    this.af8GammaAbsolute,
    this.tp10GammaAbsolute,
    // Relative
    this.tp9DeltaRelative,
    this.af7DeltaRelative,
    this.af8DeltaRelative,
    this.tp10DeltaRelative,
    this.tp9ThetaRelative,
    this.af7ThetaRelative,
    this.af8ThetaRelative,
    this.tp10ThetaRelative,
    this.tp9AlphaRelative,
    this.af7AlphaRelative,
    this.af8AlphaRelative,
    this.tp10AlphaRelative,
    this.tp9BetaRelative,
    this.af7BetaRelative,
    this.af8BetaRelative,
    this.tp10BetaRelative,
    this.tp9GammaRelative,
    this.af7GammaRelative,
    this.af8GammaRelative,
    this.tp10GammaRelative,
  });

  /// Creates sample from platform channel data
  factory BandPowerSample.fromJson(Map<String, dynamic> json) => BandPowerSample(
    deviceId: json['deviceId'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    msElapsed: json['msElapsed'] as int,
    // Absolute
    tp9DeltaAbsolute: (json['tp9DeltaAbsolute'] as num?)?.toDouble(),
    af7DeltaAbsolute: (json['af7DeltaAbsolute'] as num?)?.toDouble(),
    af8DeltaAbsolute: (json['af8DeltaAbsolute'] as num?)?.toDouble(),
    tp10DeltaAbsolute: (json['tp10DeltaAbsolute'] as num?)?.toDouble(),
    tp9ThetaAbsolute: (json['tp9ThetaAbsolute'] as num?)?.toDouble(),
    af7ThetaAbsolute: (json['af7ThetaAbsolute'] as num?)?.toDouble(),
    af8ThetaAbsolute: (json['af8ThetaAbsolute'] as num?)?.toDouble(),
    tp10ThetaAbsolute: (json['tp10ThetaAbsolute'] as num?)?.toDouble(),
    tp9AlphaAbsolute: (json['tp9AlphaAbsolute'] as num?)?.toDouble(),
    af7AlphaAbsolute: (json['af7AlphaAbsolute'] as num?)?.toDouble(),
    af8AlphaAbsolute: (json['af8AlphaAbsolute'] as num?)?.toDouble(),
    tp10AlphaAbsolute: (json['tp10AlphaAbsolute'] as num?)?.toDouble(),
    tp9BetaAbsolute: (json['tp9BetaAbsolute'] as num?)?.toDouble(),
    af7BetaAbsolute: (json['af7BetaAbsolute'] as num?)?.toDouble(),
    af8BetaAbsolute: (json['af8BetaAbsolute'] as num?)?.toDouble(),
    tp10BetaAbsolute: (json['tp10BetaAbsolute'] as num?)?.toDouble(),
    tp9GammaAbsolute: (json['tp9GammaAbsolute'] as num?)?.toDouble(),
    af7GammaAbsolute: (json['af7GammaAbsolute'] as num?)?.toDouble(),
    af8GammaAbsolute: (json['af8GammaAbsolute'] as num?)?.toDouble(),
    tp10GammaAbsolute: (json['tp10GammaAbsolute'] as num?)?.toDouble(),
    // Relative
    tp9DeltaRelative: (json['tp9DeltaRelative'] as num?)?.toDouble(),
    af7DeltaRelative: (json['af7DeltaRelative'] as num?)?.toDouble(),
    af8DeltaRelative: (json['af8DeltaRelative'] as num?)?.toDouble(),
    tp10DeltaRelative: (json['tp10DeltaRelative'] as num?)?.toDouble(),
    tp9ThetaRelative: (json['tp9ThetaRelative'] as num?)?.toDouble(),
    af7ThetaRelative: (json['af7ThetaRelative'] as num?)?.toDouble(),
    af8ThetaRelative: (json['af8ThetaRelative'] as num?)?.toDouble(),
    tp10ThetaRelative: (json['tp10ThetaRelative'] as num?)?.toDouble(),
    tp9AlphaRelative: (json['tp9AlphaRelative'] as num?)?.toDouble(),
    af7AlphaRelative: (json['af7AlphaRelative'] as num?)?.toDouble(),
    af8AlphaRelative: (json['af8AlphaRelative'] as num?)?.toDouble(),
    tp10AlphaRelative: (json['tp10AlphaRelative'] as num?)?.toDouble(),
    tp9BetaRelative: (json['tp9BetaRelative'] as num?)?.toDouble(),
    af7BetaRelative: (json['af7BetaRelative'] as num?)?.toDouble(),
    af8BetaRelative: (json['af8BetaRelative'] as num?)?.toDouble(),
    tp10BetaRelative: (json['tp10BetaRelative'] as num?)?.toDouble(),
    tp9GammaRelative: (json['tp9GammaRelative'] as num?)?.toDouble(),
    af7GammaRelative: (json['af7GammaRelative'] as num?)?.toDouble(),
    af8GammaRelative: (json['af8GammaRelative'] as num?)?.toDouble(),
    tp10GammaRelative: (json['tp10GammaRelative'] as num?)?.toDouble(),
  );

  /// Converts to CSV row values
  Map<String, dynamic> toCsvMap() => {
    'DEVICE_ID': deviceId,
    'CLOCK_TIME': timestamp.toUtc().toIso8601String(),
    'ms_ELAPSED': msElapsed,
    // Absolute
    'TP9_DELTA_ABSOLUTE': tp9DeltaAbsolute?.toStringAsFixed(6) ?? '',
    'AF7_DELTA_ABSOLUTE': af7DeltaAbsolute?.toStringAsFixed(6) ?? '',
    'AF8_DELTA_ABSOLUTE': af8DeltaAbsolute?.toStringAsFixed(6) ?? '',
    'TP10_DELTA_ABSOLUTE': tp10DeltaAbsolute?.toStringAsFixed(6) ?? '',
    'TP9_THETA_ABSOLUTE': tp9ThetaAbsolute?.toStringAsFixed(6) ?? '',
    'AF7_THETA_ABSOLUTE': af7ThetaAbsolute?.toStringAsFixed(6) ?? '',
    'AF8_THETA_ABSOLUTE': af8ThetaAbsolute?.toStringAsFixed(6) ?? '',
    'TP10_THETA_ABSOLUTE': tp10ThetaAbsolute?.toStringAsFixed(6) ?? '',
    'TP9_ALPHA_ABSOLUTE': tp9AlphaAbsolute?.toStringAsFixed(6) ?? '',
    'AF7_ALPHA_ABSOLUTE': af7AlphaAbsolute?.toStringAsFixed(6) ?? '',
    'AF8_ALPHA_ABSOLUTE': af8AlphaAbsolute?.toStringAsFixed(6) ?? '',
    'TP10_ALPHA_ABSOLUTE': tp10AlphaAbsolute?.toStringAsFixed(6) ?? '',
    'TP9_BETA_ABSOLUTE': tp9BetaAbsolute?.toStringAsFixed(6) ?? '',
    'AF7_BETA_ABSOLUTE': af7BetaAbsolute?.toStringAsFixed(6) ?? '',
    'AF8_BETA_ABSOLUTE': af8BetaAbsolute?.toStringAsFixed(6) ?? '',
    'TP10_BETA_ABSOLUTE': tp10BetaAbsolute?.toStringAsFixed(6) ?? '',
    'TP9_GAMMA_ABSOLUTE': tp9GammaAbsolute?.toStringAsFixed(6) ?? '',
    'AF7_GAMMA_ABSOLUTE': af7GammaAbsolute?.toStringAsFixed(6) ?? '',
    'AF8_GAMMA_ABSOLUTE': af8GammaAbsolute?.toStringAsFixed(6) ?? '',
    'TP10_GAMMA_ABSOLUTE': tp10GammaAbsolute?.toStringAsFixed(6) ?? '',
    // Relative
    'TP9_DELTA_RELATIVE': tp9DeltaRelative?.toStringAsFixed(6) ?? '',
    'AF7_DELTA_RELATIVE': af7DeltaRelative?.toStringAsFixed(6) ?? '',
    'AF8_DELTA_RELATIVE': af8DeltaRelative?.toStringAsFixed(6) ?? '',
    'TP10_DELTA_RELATIVE': tp10DeltaRelative?.toStringAsFixed(6) ?? '',
    'TP9_THETA_RELATIVE': tp9ThetaRelative?.toStringAsFixed(6) ?? '',
    'AF7_THETA_RELATIVE': af7ThetaRelative?.toStringAsFixed(6) ?? '',
    'AF8_THETA_RELATIVE': af8ThetaRelative?.toStringAsFixed(6) ?? '',
    'TP10_THETA_RELATIVE': tp10ThetaRelative?.toStringAsFixed(6) ?? '',
    'TP9_ALPHA_RELATIVE': tp9AlphaRelative?.toStringAsFixed(6) ?? '',
    'AF7_ALPHA_RELATIVE': af7AlphaRelative?.toStringAsFixed(6) ?? '',
    'AF8_ALPHA_RELATIVE': af8AlphaRelative?.toStringAsFixed(6) ?? '',
    'TP10_ALPHA_RELATIVE': tp10AlphaRelative?.toStringAsFixed(6) ?? '',
    'TP9_BETA_RELATIVE': tp9BetaRelative?.toStringAsFixed(6) ?? '',
    'AF7_BETA_RELATIVE': af7BetaRelative?.toStringAsFixed(6) ?? '',
    'AF8_BETA_RELATIVE': af8BetaRelative?.toStringAsFixed(6) ?? '',
    'TP10_BETA_RELATIVE': tp10BetaRelative?.toStringAsFixed(6) ?? '',
    'TP9_GAMMA_RELATIVE': tp9GammaRelative?.toStringAsFixed(6) ?? '',
    'AF7_GAMMA_RELATIVE': af7GammaRelative?.toStringAsFixed(6) ?? '',
    'AF8_GAMMA_RELATIVE': af8GammaRelative?.toStringAsFixed(6) ?? '',
    'TP10_GAMMA_RELATIVE': tp10GammaRelative?.toStringAsFixed(6) ?? '',
  };

  @override
  String toString() => 'BandPowerSample(device: $deviceId, time: $timestamp)';
}
