/// Represents a recording session with one or more Muse devices.
/// 
/// Tracks session metadata, selected columns for CSV export,
/// and manages the recording lifecycle.
class RecordingSession {
  /// Unique session identifier
  final String id;
  
  /// User-defined session name
  final String name;
  
  /// Optional session description/notes
  final String? description;
  
  /// IDs of devices included in this session
  final List<String> deviceIds;
  
  /// Timestamp when session was created
  final DateTime createdAt;
  
  /// Timestamp when recording started
  final DateTime? startedAt;
  
  /// Timestamp when recording ended
  final DateTime? endedAt;
  
  /// Whether this session is currently recording
  final bool isRecording;
  
  /// Selected CSV columns to include in export
  final Set<String> selectedColumns;
  
  /// Total number of samples recorded
  final int totalSamples;
  
  /// Current trigger count (incremented by user markers)
  final int triggerCount;
  
  /// File paths where CSV data is saved (one per device)
  final Map<String, String> csvFilePaths;

  const RecordingSession({
    required this.id,
    required this.name,
    this.description,
    required this.deviceIds,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.isRecording = false,
    required this.selectedColumns,
    this.totalSamples = 0,
    this.triggerCount = 0,
    this.csvFilePaths = const {},
  });

  /// Duration of the recording session
  Duration? get duration {
    if (startedAt == null) return null;
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt!);
  }

  /// Creates a copy with updated fields
  RecordingSession copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? deviceIds,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isRecording,
    Set<String>? selectedColumns,
    int? totalSamples,
    int? triggerCount,
    Map<String, String>? csvFilePaths,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      deviceIds: deviceIds ?? this.deviceIds,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isRecording: isRecording ?? this.isRecording,
      selectedColumns: selectedColumns ?? this.selectedColumns,
      totalSamples: totalSamples ?? this.totalSamples,
      triggerCount: triggerCount ?? this.triggerCount,
      csvFilePaths: csvFilePaths ?? this.csvFilePaths,
    );
  }

  /// Converts to JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'deviceIds': deviceIds,
    'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'isRecording': isRecording,
    'selectedColumns': selectedColumns.toList(),
    'totalSamples': totalSamples,
    'triggerCount': triggerCount,
    'csvFilePaths': csvFilePaths,
  };

  /// Creates session from JSON map
  factory RecordingSession.fromJson(Map<String, dynamic> json) => RecordingSession(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    deviceIds: (json['deviceIds'] as List<dynamic>).cast<String>(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    startedAt: json['startedAt'] != null
        ? DateTime.parse(json['startedAt'] as String)
        : null,
    endedAt: json['endedAt'] != null
        ? DateTime.parse(json['endedAt'] as String)
        : null,
    isRecording: json['isRecording'] as bool? ?? false,
    selectedColumns: (json['selectedColumns'] as List<dynamic>)
        .cast<String>()
        .toSet(),
    totalSamples: json['totalSamples'] as int? ?? 0,
    triggerCount: json['triggerCount'] as int? ?? 0,
    csvFilePaths: (json['csvFilePaths'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
  );

  @override
  String toString() => 'RecordingSession(name: $name, devices: ${deviceIds.length}, recording: $isRecording)';
}
