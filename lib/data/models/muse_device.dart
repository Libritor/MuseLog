/// Represents a Muse S or Muse S Athena headband device.
/// 
/// Contains device metadata, connection state, battery level,
/// and contact quality information for the four EEG electrodes.
class MuseDevice {
  /// Stable unique identifier (e.g., MAC address, UUID from SDK)
  final String id;
  
  /// Human-readable device name
  final String name;
  
  /// Current connection status
  final bool isConnected;
  
  /// Battery percentage (0-100)
  final int batteryPercent;
  
  /// Contact quality (HSI) for TP9 electrode
  /// Values: 1 = good, 2 = medium, 4 = bad
  final int tp9Hsi;
  
  /// Contact quality (HSI) for AF7 electrode
  final int af7Hsi;
  
  /// Contact quality (HSI) for AF8 electrode
  final int af8Hsi;
  
  /// Contact quality (HSI) for TP10 electrode
  final int tp10Hsi;
  
  /// Whether TP9 signal is artifact-free
  final bool tp9ArtifactFree;
  
  /// Whether AF7 signal is artifact-free
  final bool af7ArtifactFree;
  
  /// Whether AF8 signal is artifact-free
  final bool af8ArtifactFree;
  
  /// Whether TP10 signal is artifact-free
  final bool tp10ArtifactFree;
  
  /// Last time this device's data was updated
  final DateTime lastUpdateTime;

  const MuseDevice({
    required this.id,
    required this.name,
    this.isConnected = false,
    this.batteryPercent = 0,
    this.tp9Hsi = 4,
    this.af7Hsi = 4,
    this.af8Hsi = 4,
    this.tp10Hsi = 4,
    this.tp9ArtifactFree = false,
    this.af7ArtifactFree = false,
    this.af8ArtifactFree = false,
    this.tp10ArtifactFree = false,
    DateTime? lastUpdateTime,
  }) : lastUpdateTime = lastUpdateTime ?? DateTime.now();

  /// Creates a copy with updated fields
  MuseDevice copyWith({
    String? id,
    String? name,
    bool? isConnected,
    int? batteryPercent,
    int? tp9Hsi,
    int? af7Hsi,
    int? af8Hsi,
    int? tp10Hsi,
    bool? tp9ArtifactFree,
    bool? af7ArtifactFree,
    bool? af8ArtifactFree,
    bool? tp10ArtifactFree,
    DateTime? lastUpdateTime,
  }) {
    return MuseDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      tp9Hsi: tp9Hsi ?? this.tp9Hsi,
      af7Hsi: af7Hsi ?? this.af7Hsi,
      af8Hsi: af8Hsi ?? this.af8Hsi,
      tp10Hsi: tp10Hsi ?? this.tp10Hsi,
      tp9ArtifactFree: tp9ArtifactFree ?? this.tp9ArtifactFree,
      af7ArtifactFree: af7ArtifactFree ?? this.af7ArtifactFree,
      af8ArtifactFree: af8ArtifactFree ?? this.af8ArtifactFree,
      tp10ArtifactFree: tp10ArtifactFree ?? this.tp10ArtifactFree,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  /// Converts device to JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isConnected': isConnected,
    'batteryPercent': batteryPercent,
    'tp9Hsi': tp9Hsi,
    'af7Hsi': af7Hsi,
    'af8Hsi': af8Hsi,
    'tp10Hsi': tp10Hsi,
    'tp9ArtifactFree': tp9ArtifactFree,
    'af7ArtifactFree': af7ArtifactFree,
    'af8ArtifactFree': af8ArtifactFree,
    'tp10ArtifactFree': tp10ArtifactFree,
    'lastUpdateTime': lastUpdateTime.toIso8601String(),
  };

  /// Creates device from JSON map
  factory MuseDevice.fromJson(Map<String, dynamic> json) => MuseDevice(
    id: json['id'] as String,
    name: json['name'] as String,
    isConnected: json['isConnected'] as bool? ?? false,
    batteryPercent: json['batteryPercent'] as int? ?? 0,
    tp9Hsi: json['tp9Hsi'] as int? ?? 4,
    af7Hsi: json['af7Hsi'] as int? ?? 4,
    af8Hsi: json['af8Hsi'] as int? ?? 4,
    tp10Hsi: json['tp10Hsi'] as int? ?? 4,
    tp9ArtifactFree: json['tp9ArtifactFree'] as bool? ?? false,
    af7ArtifactFree: json['af7ArtifactFree'] as bool? ?? false,
    af8ArtifactFree: json['af8ArtifactFree'] as bool? ?? false,
    tp10ArtifactFree: json['tp10ArtifactFree'] as bool? ?? false,
    lastUpdateTime: json['lastUpdateTime'] != null
        ? DateTime.parse(json['lastUpdateTime'] as String)
        : null,
  );

  @override
  String toString() => 'MuseDevice(id: $id, name: $name, connected: $isConnected)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuseDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
