import 'package:flutter/material.dart';

/// App-wide constants and configuration
class Constants {
  // ===== APP INFO =====
  static const String appName = 'MuseLog';
  static const String appVersion = '1.0.0';

  // ===== CHART CONFIGURATION =====
  
  /// How often to refresh charts (milliseconds)
  /// Lower = smoother but more CPU intensive
  static const int chartRefreshInterval = 100; // 10 Hz
  
  /// Time window for live charts (seconds)
  static const int eegChartTimeWindow = 10;
  static const int bandPowerChartTimeWindow = 20;
  static const int fnirsChartTimeWindow = 20;
  static const int imuChartTimeWindow = 10;
  
  /// Maximum data points to keep in memory per chart
  static const int maxEEGDataPoints = 2560; // 10 seconds at 256 Hz
  static const int maxBandPowerDataPoints = 100;
  static const int maxFNIRSDataPoints = 640; // 10 seconds at 64 Hz
  static const int maxIMUDataPoints = 520; // 10 seconds at 52 Hz

  // ===== HSI (Contact Quality) THRESHOLDS =====
  
  /// HSI value for good connection
  static const int hsiGood = 1;
  
  /// HSI value for medium connection
  static const int hsiMedium = 2;
  
  /// HSI value for bad connection
  static const int hsiBad = 4;

  // ===== COLORS =====
  
  /// Primary app color
  static const Color primaryColor = Color(0xFF6200EE);
  
  /// Accent color
  static const Color accentColor = Color(0xFF03DAC6);
  
  /// HSI indicator colors
  static const Color hsiGoodColor = Color(0xFF4CAF50); // Green
  static const Color hsiMediumColor = Color(0xFFFFC107); // Yellow
  static const Color hsiBadColor = Color(0xFFF44336); // Red
  static const Color hsiUnknownColor = Color(0xFF9E9E9E); // Gray
  
  /// EEG electrode colors for charts
  static const Color tp9Color = Color(0xFF2196F3); // Blue
  static const Color af7Color = Color(0xFF4CAF50); // Green
  static const Color af8Color = Color(0xFFFFC107); // Yellow
  static const Color tp10Color = Color(0xFFF44336); // Red
  
  /// Band power colors
  static const Color deltaColor = Color(0xFF9C27B0); // Purple
  static const Color thetaColor = Color(0xFF2196F3); // Blue
  static const Color alphaColor = Color(0xFF4CAF50); // Green
  static const Color betaColor = Color(0xFFFFC107); // Yellow
  static const Color gammaColor = Color(0xFFF44336); // Red

  // ===== CSV COLUMNS =====
  
  /// All available CSV columns grouped by category
  static const Map<String, List<String>> csvColumnGroups = {
    'Metadata': [
      'PACKET_TYPE',
      'CLOCK_TIME',
      'ms_ELAPSED',
      'TRIGGER_COUNT',
    ],
    'Contact Quality': [
      'TP9_CONNECTION_STRENGTH(HSI)',
      'TP9_ARTIFACT_FREE(IS_GOOD)',
      'AF7_CONNECTION_STRENGTH(HSI)',
      'AF7_ARTIFACT_FREE(IS_GOOD)',
      'AF8_CONNECTION_STRENGTH(HSI)',
      'AF8_ARTIFACT_FREE(IS_GOOD)',
      'TP10_CONNECTION_STRENGTH(HSI)',
      'TP10_ARTIFACT_FREE(IS_GOOD)',
    ],
    'Raw EEG': [
      'TP9_RAW',
      'AF7_RAW',
      'AF8_RAW',
      'TP10_RAW',
      'DRL',
      'REF',
    ],
    'Band Powers (Absolute)': [
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
    ],
    'Band Powers (Relative)': [
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
    ],
    'IMU': [
      'GYRO_X',
      'GYRO_Y',
      'GYRO_Z',
      'ACCEL_X',
      'ACCEL_Y',
      'ACCEL_Z',
    ],
    'fNIRS': [
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
    ],
    'Battery': [
      'BATTERY_PERCENT',
    ],
  };

  /// Default selected CSV columns (commonly used)
  static Set<String> get defaultSelectedColumns => {
    'PACKET_TYPE',
    'CLOCK_TIME',
    'ms_ELAPSED',
    'TRIGGER_COUNT',
    'TP9_CONNECTION_STRENGTH(HSI)',
    'AF7_CONNECTION_STRENGTH(HSI)',
    'AF8_CONNECTION_STRENGTH(HSI)',
    'TP10_CONNECTION_STRENGTH(HSI)',
    'TP9_RAW',
    'AF7_RAW',
    'AF8_RAW',
    'TP10_RAW',
    'TP9_ALPHA_ABSOLUTE',
    'AF7_ALPHA_ABSOLUTE',
    'AF8_ALPHA_ABSOLUTE',
    'TP10_ALPHA_ABSOLUTE',
    'BATTERY_PERCENT',
  };

  // ===== ELECTRODE POSITIONS =====
  
  /// Electrode names
  static const List<String> electrodes = ['TP9', 'AF7', 'AF8', 'TP10'];
  
  /// Band names
  static const List<String> bands = ['Delta', 'Theta', 'Alpha', 'Beta', 'Gamma'];

  // ===== PERMISSIONS =====
  
  static const String permissionRationale =
      'MuseLog needs Bluetooth and location permissions to discover and connect to Muse headbands.';
}
