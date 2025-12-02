import 'dart:async';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/eeg_sample.dart';
import '../models/band_power_sample.dart';
import '../models/fnirs_sample.dart';
import '../models/imu_sample.dart';

/// Service for writing Muse data to CSV files.
/// 
/// Features:
/// - Streaming writes (doesn't hold entire dataset in memory)
/// - User-selectable columns
/// - Exact column names per requirements
/// - One CSV file per device
/// - Efficient buffering for high-frequency data (256 Hz EEG)
class CSVWriterService {
  final String sessionId;
  final String deviceId;
  final Set<String> selectedColumns;
  final DateTime sessionStartTime;
  
  late final File _csvFile;
  late final IOSink _sink;
  
  bool _isInitialized = false;
  bool _isClosed = false;
  
  // Buffer for batching writes
  final List<List<dynamic>> _buffer = [];
  static const int _bufferSize = 50; // Write every 50 samples
  
  // Trigger count tracking
  int _currentTriggerCount = 0;

  CSVWriterService({
    required this.sessionId,
    required this.deviceId,
    required this.selectedColumns,
    DateTime? sessionStartTime,
  }) : sessionStartTime = sessionStartTime ?? DateTime.now();

  /// All possible CSV columns in exact order required
  static const List<String> allColumns = [
    'PACKET_TYPE',
    'CLOCK_TIME',
    'ms_ELAPSED',
    'TRIGGER_COUNT',
    'TP9_CONNECTION_STRENGTH(HSI)',
    'TP9_ARTIFACT_FREE(IS_GOOD)',
    'AF7_CONNECTION_STRENGTH(HSI)',
    'AF7_ARTIFACT_FREE(IS_GOOD)',
    'AF8_CONNECTION_STRENGTH(HSI)',
    'AF8_ARTIFACT_FREE(IS_GOOD)',
    'TP10_CONNECTION_STRENGTH(HSI)',
    'TP10_ARTIFACT_FREE(IS_GOOD)',
    'TP9_RAW',
    'AF7_RAW',
    'AF8_RAW',
    'TP10_RAW',
    'DRL',
    'REF',
    'TP9_DELTA_ABSOLUTE',
    'AF7_DELTA_ABSOLUTE',
    'AF8_DELTA_ABSOLUTE',
    'TP10_DELTA_ABSOLUTE',
    'TP9_THETA_ABSOLUTE',
    'AF7_THETA_ABSOLUTE',
    'AF8_THETA_ABSOLUTE',
    'TP10_THETA_ABSOLUTE',
    'TP9_ALPHA_ABSOLUTE',
    'AF7_ALPHA_ABSOLUTE',
    'AF8_ALPHA_ABSOLUTE',
    'TP10_ALPHA_ABSOLUTE',
    'TP9_BETA_ABSOLUTE',
    'AF7_BETA_ABSOLUTE',
    'AF8_BETA_ABSOLUTE',
    'TP10_BETA_ABSOLUTE',
    'TP9_GAMMA_ABSOLUTE',
    'AF7_GAMMA_ABSOLUTE',
    'AF8_GAMMA_ABSOLUTE',
    'TP10_GAMMA_ABSOLUTE',
    'TP9_DELTA_RELATIVE',
    'AF7_DELTA_RELATIVE',
    'AF8_DELTA_RELATIVE',
    'TP10_DELTA_RELATIVE',
    'TP9_THETA_RELATIVE',
    'AF7_THETA_RELATIVE',
    'AF8_THETA_RELATIVE',
    'TP10_THETA_RELATIVE',
    'TP9_ALPHA_RELATIVE',
    'AF7_ALPHA_RELATIVE',
    'AF8_ALPHA_RELATIVE',
    'TP10_ALPHA_RELATIVE',
    'TP9_BETA_RELATIVE',
    'AF7_BETA_RELATIVE',
    'AF8_BETA_RELATIVE',
    'TP10_BETA_RELATIVE',
    'TP9_GAMMA_RELATIVE',
    'AF7_GAMMA_RELATIVE',
    'AF8_GAMMA_RELATIVE',
    'TP10_GAMMA_RELATIVE',
    'GYRO_X',
    'GYRO_Y',
    'GYRO_Z',
    'ACCEL_X',
    'ACCEL_Y',
    'ACCEL_Z',
    '730nm_LEFT_OUTER',
    '730nm_RIGHT_OUTER',
    '850nm_LEFT_OUTER',
    '850nm_RIGHT_OUTER',
    '730nm_LEFT_INNER',
    '730nm_RIGHT_INNER',
    '850nm_LEFT_INNER',
    '850nm_RIGHT_INNER',
    'RED_LEFT_OUTER',
    'RED_RIGHT_OUTER',
    'AMBIENT_LEFT_OUTER',
    'AMBIENT_RIGHT_OUTER',
    'RED_LEFT_INNER',
    'RED_RIGHT_INNER',
    'AMBIENT_LEFT_INNER',
    'AMBIENT_RIGHT_INNER',
    'BATTERY_PERCENT',
  ];

  /// Initialize CSV file and write header
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Get app documents directory
    final directory = await getApplicationDocumentsDirectory();
    
    // Create subdirectory for this session
    final sessionDir = Directory('${directory.path}/sessions/$sessionId');
    await sessionDir.create(recursive: true);
    
    // Create file with timestamp and device ID
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'muse_session_${timestamp}_$deviceId.csv';
    _csvFile = File('${sessionDir.path}/$fileName');
    
    // Open file for writing
    _sink = _csvFile.openWrite();
    
    // Write header with selected columns only
    final headerRow = selectedColumns.toList();
    final csvString = const ListToCsvConverter().convert([headerRow]);
    _sink.write(csvString);
    
    _isInitialized = true;
  }

  /// Get the file path (must call initialize first)
  String getFilePath() {
    if (!_isInitialized) {
      throw StateError('CSVWriterService not initialized. Call initialize() first.');
    }
    return _csvFile.path;
  }

  /// Increment trigger count (called when user presses marker button)
  void incrementTrigger() {
    _currentTriggerCount++;
  }

  /// Write an EEG sample to CSV
  Future<void> writeEEGSample(EEGSample sample, {int? batteryPercent}) async {
    if (!_isInitialized) await initialize();
    if (_isClosed) return;

    final rowMap = {
      'PACKET_TYPE': 'EEG',
      'CLOCK_TIME': sample.timestamp.toUtc().toIso8601String(),
      'ms_ELAPSED': sample.msElapsed.toString(),
      'TRIGGER_COUNT': _currentTriggerCount.toString(),
      'TP9_CONNECTION_STRENGTH(HSI)': sample.tp9Hsi?.toString() ?? '',
      'TP9_ARTIFACT_FREE(IS_GOOD)': sample.tp9ArtifactFree != null ? (sample.tp9ArtifactFree! ? '1' : '0') : '',
      'AF7_CONNECTION_STRENGTH(HSI)': sample.af7Hsi?.toString() ?? '',
      'AF7_ARTIFACT_FREE(IS_GOOD)': sample.af7ArtifactFree != null ? (sample.af7ArtifactFree! ? '1' : '0') : '',
      'AF8_CONNECTION_STRENGTH(HSI)': sample.af8Hsi?.toString() ?? '',
      'AF8_ARTIFACT_FREE(IS_GOOD)': sample.af8ArtifactFree != null ? (sample.af8ArtifactFree! ? '1' : '0') : '',
      'TP10_CONNECTION_STRENGTH(HSI)': sample.tp10Hsi?.toString() ?? '',
      'TP10_ARTIFACT_FREE(IS_GOOD)': sample.tp10ArtifactFree != null ? (sample.tp10ArtifactFree! ? '1' : '0') : '',
      'TP9_RAW': sample.tp9Raw?.toStringAsFixed(6) ?? '',
      'AF7_RAW': sample.af7Raw?.toStringAsFixed(6) ?? '',
      'AF8_RAW': sample.af8Raw?.toStringAsFixed(6) ?? '',
      'TP10_RAW': sample.tp10Raw?.toStringAsFixed(6) ?? '',
      'DRL': sample.drl?.toStringAsFixed(6) ?? '',
      'REF': sample.ref?.toStringAsFixed(6) ?? '',
      'BATTERY_PERCENT': batteryPercent?.toString() ?? '',
    };

    _addRowFromMap(rowMap);
  }

  /// Write a band power sample to CSV
  Future<void> writeBandPowerSample(BandPowerSample sample, {int? batteryPercent}) async {
    if (!_isInitialized) await initialize();
    if (_isClosed) return;

    final rowMap = {
      'PACKET_TYPE': 'BAND_POWER',
      'CLOCK_TIME': sample.timestamp.toUtc().toIso8601String(),
      'ms_ELAPSED': sample.msElapsed.toString(),
      'TRIGGER_COUNT': _currentTriggerCount.toString(),
      // Absolute band powers
      'TP9_DELTA_ABSOLUTE': sample.tp9DeltaAbsolute?.toStringAsFixed(6) ?? '',
      'AF7_DELTA_ABSOLUTE': sample.af7DeltaAbsolute?.toStringAsFixed(6) ?? '',
      'AF8_DELTA_ABSOLUTE': sample.af8DeltaAbsolute?.toStringAsFixed(6) ?? '',
      'TP10_DELTA_ABSOLUTE': sample.tp10DeltaAbsolute?.toStringAsFixed(6) ?? '',
      'TP9_THETA_ABSOLUTE': sample.tp9ThetaAbsolute?.toStringAsFixed(6) ?? '',
      'AF7_THETA_ABSOLUTE': sample.af7ThetaAbsolute?.toStringAsFixed(6) ?? '',
      'AF8_THETA_ABSOLUTE': sample.af8ThetaAbsolute?.toStringAsFixed(6) ?? '',
      'TP10_THETA_ABSOLUTE': sample.tp10ThetaAbsolute?.toStringAsFixed(6) ?? '',
      'TP9_ALPHA_ABSOLUTE': sample.tp9AlphaAbsolute?.toStringAsFixed(6) ?? '',
      'AF7_ALPHA_ABSOLUTE': sample.af7AlphaAbsolute?.toStringAsFixed(6) ?? '',
      'AF8_ALPHA_ABSOLUTE': sample.af8AlphaAbsolute?.toStringAsFixed(6) ?? '',
      'TP10_ALPHA_ABSOLUTE': sample.tp10AlphaAbsolute?.toStringAsFixed(6) ?? '',
      'TP9_BETA_ABSOLUTE': sample.tp9BetaAbsolute?.toStringAsFixed(6) ?? '',
      'AF7_BETA_ABSOLUTE': sample.af7BetaAbsolute?.toStringAsFixed(6) ?? '',
      'AF8_BETA_ABSOLUTE': sample.af8BetaAbsolute?.toStringAsFixed(6) ?? '',
      'TP10_BETA_ABSOLUTE': sample.tp10BetaAbsolute?.toStringAsFixed(6) ?? '',
      'TP9_GAMMA_ABSOLUTE': sample.tp9GammaAbsolute?.toStringAsFixed(6) ?? '',
      'AF7_GAMMA_ABSOLUTE': sample.af7GammaAbsolute?.toStringAsFixed(6) ?? '',
      'AF8_GAMMA_ABSOLUTE': sample.af8GammaAbsolute?.toStringAsFixed(6) ?? '',
      'TP10_GAMMA_ABSOLUTE': sample.tp10GammaAbsolute?.toStringAsFixed(6) ?? '',
      // Relative band powers
      'TP9_DELTA_RELATIVE': sample.tp9DeltaRelative?.toStringAsFixed(6) ?? '',
      'AF7_DELTA_RELATIVE': sample.af7DeltaRelative?.toStringAsFixed(6) ?? '',
      'AF8_DELTA_RELATIVE': sample.af8DeltaRelative?.toStringAsFixed(6) ?? '',
      'TP10_DELTA_RELATIVE': sample.tp10DeltaRelative?.toStringAsFixed(6) ?? '',
      'TP9_THETA_RELATIVE': sample.tp9ThetaRelative?.toStringAsFixed(6) ?? '',
      'AF7_THETA_RELATIVE': sample.af7ThetaRelative?.toStringAsFixed(6) ?? '',
      'AF8_THETA_RELATIVE': sample.af8ThetaRelative?.toStringAsFixed(6) ?? '',
      'TP10_THETA_RELATIVE': sample.tp10ThetaRelative?.toStringAsFixed(6) ?? '',
      'TP9_ALPHA_RELATIVE': sample.tp9AlphaRelative?.toStringAsFixed(6) ?? '',
      'AF7_ALPHA_RELATIVE': sample.af7AlphaRelative?.toStringAsFixed(6) ?? '',
      'AF8_ALPHA_RELATIVE': sample.af8AlphaRelative?.toStringAsFixed(6) ?? '',
      'TP10_ALPHA_RELATIVE': sample.tp10AlphaRelative?.toStringAsFixed(6) ?? '',
      'TP9_BETA_RELATIVE': sample.tp9BetaRelative?.toStringAsFixed(6) ?? '',
      'AF7_BETA_RELATIVE': sample.af7BetaRelative?.toStringAsFixed(6) ?? '',
      'AF8_BETA_RELATIVE': sample.af8BetaRelative?.toStringAsFixed(6) ?? '',
      'TP10_BETA_RELATIVE': sample.tp10BetaRelative?.toStringAsFixed(6) ?? '',
      'TP9_GAMMA_RELATIVE': sample.tp9GammaRelative?.toStringAsFixed(6) ?? '',
      'AF7_GAMMA_RELATIVE': sample.af7GammaRelative?.toStringAsFixed(6) ?? '',
      'AF8_GAMMA_RELATIVE': sample.af8GammaRelative?.toStringAsFixed(6) ?? '',
      'TP10_GAMMA_RELATIVE': sample.tp10GammaRelative?.toStringAsFixed(6) ?? '',
      'BATTERY_PERCENT': batteryPercent?.toString() ?? '',
    };

    _addRowFromMap(rowMap);
  }

  /// Write an fNIRS sample to CSV
  Future<void> writeFNIRSSample(FNIRSSample sample, {int? batteryPercent}) async {
    if (!_isInitialized) await initialize();
    if (_isClosed) return;

    final rowMap = {
      'PACKET_TYPE': 'FNIRS',
      'CLOCK_TIME': sample.timestamp.toUtc().toIso8601String(),
      'ms_ELAPSED': sample.msElapsed.toString(),
      'TRIGGER_COUNT': _currentTriggerCount.toString(),
      '730nm_LEFT_OUTER': sample.nm730LeftOuter?.toStringAsFixed(6) ?? '',
      '730nm_RIGHT_OUTER': sample.nm730RightOuter?.toStringAsFixed(6) ?? '',
      '850nm_LEFT_OUTER': sample.nm850LeftOuter?.toStringAsFixed(6) ?? '',
      '850nm_RIGHT_OUTER': sample.nm850RightOuter?.toStringAsFixed(6) ?? '',
      '730nm_LEFT_INNER': sample.nm730LeftInner?.toStringAsFixed(6) ?? '',
      '730nm_RIGHT_INNER': sample.nm730RightInner?.toStringAsFixed(6) ?? '',
      '850nm_LEFT_INNER': sample.nm850LeftInner?.toStringAsFixed(6) ?? '',
      '850nm_RIGHT_INNER': sample.nm850RightInner?.toStringAsFixed(6) ?? '',
      'RED_LEFT_OUTER': sample.redLeftOuter?.toStringAsFixed(6) ?? '',
      'RED_RIGHT_OUTER': sample.redRightOuter?.toStringAsFixed(6) ?? '',
      'AMBIENT_LEFT_OUTER': sample.ambientLeftOuter?.toStringAsFixed(6) ?? '',
      'AMBIENT_RIGHT_OUTER': sample.ambientRightOuter?.toStringAsFixed(6) ?? '',
      'RED_LEFT_INNER': sample.redLeftInner?.toStringAsFixed(6) ?? '',
      'RED_RIGHT_INNER': sample.redRightInner?.toStringAsFixed(6) ?? '',
      'AMBIENT_LEFT_INNER': sample.ambientLeftInner?.toStringAsFixed(6) ?? '',
      'AMBIENT_RIGHT_INNER': sample.ambientRightInner?.toStringAsFixed(6) ?? '',
      'BATTERY_PERCENT': batteryPercent?.toString() ?? '',
    };

    _addRowFromMap(rowMap);
  }

  /// Write an IMU sample to CSV
  Future<void> writeIMUSample(IMUSample sample, {int? batteryPercent}) async {
    if (!_isInitialized) await initialize();
    if (_isClosed) return;

    final rowMap = {
      'PACKET_TYPE': 'IMU',
      'CLOCK_TIME': sample.timestamp.toUtc().toIso8601String(),
      'ms_ELAPSED': sample.msElapsed.toString(),
      'TRIGGER_COUNT': _currentTriggerCount.toString(),
      'GYRO_X': sample.gyroX?.toStringAsFixed(6) ?? '',
      'GYRO_Y': sample.gyroY?.toStringAsFixed(6) ?? '',
      'GYRO_Z': sample.gyroZ?.toStringAsFixed(6) ?? '',
      'ACCEL_X': sample.accelX?.toStringAsFixed(6) ?? '',
      'ACCEL_Y': sample.accelY?.toStringAsFixed(6) ?? '',
      'ACCEL_Z': sample.accelZ?.toStringAsFixed(6) ?? '',
      'BATTERY_PERCENT': batteryPercent?.toString() ?? '',
    };

    _addRowFromMap(rowMap);
  }

  /// Internal method to add a row from a map to the buffer
  void _addRowFromMap(Map<String, String> rowMap) {
    // Build row with only selected columns in correct order
    final row = selectedColumns.map((column) => rowMap[column] ?? '').toList();
    
    _buffer.add(row);
    
    // Flush buffer if full
    if (_buffer.length >= _bufferSize) {
      _flushBuffer();
    }
  }

  /// Flush buffered rows to disk
  void _flushBuffer() {
    if (_buffer.isEmpty) return;
    
    final csvString = const ListToCsvConverter().convert(_buffer);
    _sink.write(csvString);
    _buffer.clear();
  }

  /// Close the CSV file and flush any remaining data
  Future<void> close() async {
    if (_isClosed) return;
    
    // Flush any remaining buffered data
    _flushBuffer();
    
    // Close the file
    await _sink.flush();
    await _sink.close();
    
    _isClosed = true;
  }
}
