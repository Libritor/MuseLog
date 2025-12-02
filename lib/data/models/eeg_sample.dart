/// Represents a single EEG data sample from a Muse device.
/// 
/// Includes raw EEG values for the four main electrodes (TP9, AF7, AF8, TP10)
/// plus reference electrodes (DRL, REF).
/// 
/// Sample rate is typically 256 Hz.
class EEGSample {
  /// Device ID this sample came from
  final String deviceId;
  
  /// Timestamp when this sample was captured
  final DateTime timestamp;
  
  /// Milliseconds elapsed since recording session started
  final int msElapsed;
  
  /// Raw EEG value for TP9 electrode (left ear)
  final double? tp9Raw;
  
  /// Raw EEG value for AF7 electrode (left forehead)
  final double? af7Raw;
  
  /// Raw EEG value for AF8 electrode (right forehead)
  final double? af8Raw;
  
  /// Raw EEG value for TP10 electrode (right ear)
  final double? tp10Raw;
  
  /// DRL (Driven Right Leg) reference value
  final double? drl;
  
  /// REF (Reference) electrode value
  final double? ref;
  
  /// Contact quality (HSI) for TP9
  final int? tp9Hsi;
  
  /// Contact quality (HSI) for AF7
  final int? af7Hsi;
  
  /// Contact quality (HSI) for AF8
  final int? af8Hsi;
  
  /// Contact quality (HSI) for TP10
  final int? tp10Hsi;
  
  /// Whether TP9 is artifact-free
  final bool? tp9ArtifactFree;
  
  /// Whether AF7 is artifact-free
  final bool? af7ArtifactFree;
  
  /// Whether AF8 is artifact-free
  final bool? af8ArtifactFree;
  
  /// Whether TP10 is artifact-free
  final bool? tp10ArtifactFree;

  const EEGSample({
    required this.deviceId,
    required this.timestamp,
    required this.msElapsed,
    this.tp9Raw,
    this.af7Raw,
    this.af8Raw,
    this.tp10Raw,
    this.drl,
    this.ref,
    this.tp9Hsi,
    this.af7Hsi,
    this.af8Hsi,
    this.tp10Hsi,
    this.tp9ArtifactFree,
    this.af7ArtifactFree,
    this.af8ArtifactFree,
    this.tp10ArtifactFree,
  });

  /// Creates sample from platform channel data
  factory EEGSample.fromJson(Map<String, dynamic> json) => EEGSample(
    deviceId: json['deviceId'] as String,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    msElapsed: json['msElapsed'] as int,
    tp9Raw: (json['tp9Raw'] as num?)?.toDouble(),
    af7Raw: (json['af7Raw'] as num?)?.toDouble(),
    af8Raw: (json['af8Raw'] as num?)?.toDouble(),
    tp10Raw: (json['tp10Raw'] as num?)?.toDouble(),
    drl: (json['drl'] as num?)?.toDouble(),
    ref: (json['ref'] as num?)?.toDouble(),
    tp9Hsi: json['tp9Hsi'] as int?,
    af7Hsi: json['af7Hsi'] as int?,
    af8Hsi: json['af8Hsi'] as int?,
    tp10Hsi: json['tp10Hsi'] as int?,
    tp9ArtifactFree: json['tp9ArtifactFree'] as bool?,
    af7ArtifactFree: json['af7ArtifactFree'] as bool?,
    af8ArtifactFree: json['af8ArtifactFree'] as bool?,
    tp10ArtifactFree: json['tp10ArtifactFree'] as bool?,
  );

  /// Converts to CSV row values
  Map<String, dynamic> toCsvMap() => {
    'DEVICE_ID': deviceId,
    'CLOCK_TIME': timestamp.toUtc().toIso8601String(),
    'ms_ELAPSED': msElapsed,
    'TP9_RAW': tp9Raw?.toStringAsFixed(6) ?? '',
    'AF7_RAW': af7Raw?.toStringAsFixed(6) ?? '',
    'AF8_RAW': af8Raw?.toStringAsFixed(6) ?? '',
    'TP10_RAW': tp10Raw?.toStringAsFixed(6) ?? '',
    'DRL': drl?.toStringAsFixed(6) ?? '',
    'REF': ref?.toStringAsFixed(6) ?? '',
    'TP9_CONNECTION_STRENGTH(HSI)': tp9Hsi?.toString() ?? '',
    'AF7_CONNECTION_STRENGTH(HSI)': af7Hsi?.toString() ?? '',
    'AF8_CONNECTION_STRENGTH(HSI)': af8Hsi?.toString() ?? '',
    'TP10_CONNECTION_STRENGTH(HSI)': tp10Hsi?.toString() ?? '',
    'TP9_ARTIFACT_FREE(IS_GOOD)': tp9ArtifactFree != null ? (tp9ArtifactFree! ? '1' : '0') : '',
    'AF7_ARTIFACT_FREE(IS_GOOD)': af7ArtifactFree != null ? (af7ArtifactFree! ? '1' : '0') : '',
    'AF8_ARTIFACT_FREE(IS_GOOD)': af8ArtifactFree != null ? (af8ArtifactFree! ? '1' : '0') : '',
    'TP10_ARTIFACT_FREE(IS_GOOD)': tp10ArtifactFree != null ? (tp10ArtifactFree! ? '1' : '0') : '',
  };

  @override
  String toString() => 'EEGSample(device: $deviceId, time: $timestamp, tp9: $tp9Raw)';
}
