import 'package:flutter/services.dart';
import 'dart:async';
import '../models/muse_device.dart';
import '../models/eeg_sample.dart';
import '../models/band_power_sample.dart';
import '../models/fnirs_sample.dart';
import '../models/imu_sample.dart';

/// Platform channel interface for communicating with native Muse SDK code.
/// 
/// This class bridges Flutter (Dart) with platform-specific implementations:
/// - Android: Kotlin code using LibMuse
/// - iOS: Swift code using LibMuse
/// 
/// Native implementations should be placed in:
/// - Android: android/app/src/main/kotlin/.../MusePlatformChannel.kt
/// - iOS: ios/Runner/MusePlatformChannel.swift
class MusePlatformChannel {
  static const MethodChannel _methodChannel =
      MethodChannel('com.muselog.muse/methods');
  
  static const EventChannel _deviceScanChannel =
      EventChannel('com.muselog.muse/device_scan');
  
  static const EventChannel _eegDataChannel =
      EventChannel('com.muselog.muse/eeg_data');
  
  static const EventChannel _bandPowerChannel =
      EventChannel('com.muselog.muse/band_power');
  
  static const EventChannel _fnirsChannel =
      EventChannel('com.muselog.muse/fnirs');
  
  static const EventChannel _imuChannel =
      EventChannel('com.muselog.muse/imu');
  
  static const EventChannel _connectionStatusChannel =
      EventChannel('com.muselog.muse/connection_status');

  // ===== METHOD CALLS =====

  /// Requests Bluetooth permissions (Android 12+)
  /// 
  /// TODO (Native): Implement in MusePlatformChannel.kt
  /// - Request BLUETOOTH_SCAN and BLUETOOTH_CONNECT permissions
  /// - Return true if granted, false otherwise
  Future<bool> requestBluetoothPermissions() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'requestBluetoothPermissions',
      );
      return result ?? false;
    } catch (e) {
      print('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  /// Starts scanning for Muse devices
  /// 
  /// TODO (Native): Implement in MusePlatformChannel.kt / MusePlatformChannel.swift
  /// Android (Kotlin):
  /// ```kotlin
  /// val manager = MuseManagerAndroid.getInstance()
  /// manager.startListening()
  /// manager.addMuseListener(object : MuseListener {
  ///   override fun museListChanged() {
  ///     val devices = manager.muses
  ///     // Send device list via EventChannel
  ///   }
  /// })
  /// ```
  /// 
  /// iOS (Swift):
  /// ```swift
  /// let manager = IXNMuseManager.shared()
  /// manager.startListening()
  /// // Observe for kIXNMuseListChangedNotification
  /// // Send device list via EventChannel
  /// ```
  Future<void> startDeviceScan() async {
    try {
      await _methodChannel.invokeMethod('startDeviceScan');
    } catch (e) {
      print('Error starting device scan: $e');
      rethrow;
    }
  }

  /// Stops scanning for Muse devices
  Future<void> stopDeviceScan() async {
    try {
      await _methodChannel.invokeMethod('stopDeviceScan');
    } catch (e) {
      print('Error stopping device scan: $e');
    }
  }

  /// Connects to a Muse device by ID
  /// 
  /// TODO (Native): Implement connection logic
  /// Android:
  /// ```kotlin
  /// val muse = manager.muses.find { it.macAddress == deviceId }
  /// muse?.let {
  ///   it.registerConnectionListener(connectionListener)
  ///   it.registerDataListener(eegListener, MuseDataPacketType.EEG)
  ///   it.registerDataListener(bandPowerListener, MuseDataPacketType.BAND_POWER)
  ///   it.registerDataListener(fnirsListener, MuseDataPacketType.FNIRS)
  ///   it.registerDataListener(imuListener, MuseDataPacketType.ACCELEROMETER)
  ///   it.runAsynchronously()
  /// }
  /// ```
  Future<bool> connectToDevice(String deviceId) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'connectToDevice',
        {'deviceId': deviceId},
      );
      return result ?? false;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  /// Disconnects from a Muse device
  Future<void> disconnectFromDevice(String deviceId) async {
    try {
      await _methodChannel.invokeMethod(
        'disconnectFromDevice',
        {'deviceId': deviceId},
      );
    } catch (e) {
      print('Error disconnecting from device: $e');
    }
  }

  /// Starts data streaming for a connected device
  Future<void> startDataStream(String deviceId) async {
    try {
      await _methodChannel.invokeMethod(
        'startDataStream',
        {'deviceId': deviceId},
      );
    } catch (e) {
      print('Error starting data stream: $e');
    }
  }

  /// Stops data streaming for a device
  Future<void> stopDataStream(String deviceId) async {
    try {
      await _methodChannel.invokeMethod(
        'stopDataStream',
        {'deviceId': deviceId},
      );
    } catch (e) {
      print('Error stopping data stream: $e');
    }
  }

  // ===== EVENT STREAMS =====

  /// Stream of discovered Muse devices
  /// 
  /// Native side should send JSON arrays of device objects:
  /// ```json
  /// [
  ///   {
  ///     "id": "00:55:DA:B0:XX:XX",
  ///     "name": "Muse-XXXX",
  ///     "isConnected": false,
  ///     "batteryPercent": 0
  ///   }
  /// ]
  /// ```
  Stream<List<MuseDevice>> get deviceScanStream {
    return _deviceScanChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is List) {
        return event.map((item) {
          if (item is Map) {
            return MuseDevice.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        }).whereType<MuseDevice>().toList();
      }
      return <MuseDevice>[];
    });
  }

  /// Stream of EEG data samples
  /// 
  /// Native side should send JSON objects for each EEG packet:
  /// ```json
  /// {
  ///   "deviceId": "00:55:DA:B0:XX:XX",
  ///   "timestamp": 1234567890123,
  ///   "msElapsed": 1500,
  ///   "tp9Raw": 850.5,
  ///   "af7Raw": 920.3,
  ///   "af8Raw": 915.7,
  ///   "tp10Raw": 840.2,
  ///   "drl": 0.0,
  ///   "ref": 0.0,
  ///   "tp9Hsi": 1,
  ///   "af7Hsi": 1,
  ///   "af8Hsi": 2,
  ///   "tp10Hsi": 1,
  ///   "tp9ArtifactFree": true,
  ///   "af7ArtifactFree": true,
  ///   "af8ArtifactFree": false,
  ///   "tp10ArtifactFree": true
  /// }
  /// ```
  Stream<EEGSample> get eegDataStream {
    return _eegDataChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        return EEGSample.fromJson(Map<String, dynamic>.from(event));
      }
      throw FormatException('Invalid EEG data format');
    });
  }

  /// Stream of band power data
  Stream<BandPowerSample> get bandPowerStream {
    return _bandPowerChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        return BandPowerSample.fromJson(Map<String, dynamic>.from(event));
      }
      throw FormatException('Invalid band power data format');
    });
  }

  /// Stream of fNIRS data
  Stream<FNIRSSample> get fnirsStream {
    return _fnirsChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        return FNIRSSample.fromJson(Map<String, dynamic>.from(event));
      }
      throw FormatException('Invalid fNIRS data format');
    });
  }

  /// Stream of IMU data
  Stream<IMUSample> get imuStream {
    return _imuChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        return IMUSample.fromJson(Map<String, dynamic>.from(event));
      }
      throw FormatException('Invalid IMU data format');
    });
  }

  /// Stream of connection status updates
  /// 
  /// Native side sends:
  /// ```json
  /// {
  ///   "deviceId": "00:55:DA:B0:XX:XX",
  ///   "isConnected": true,
  ///   "batteryPercent": 75
  /// }
  /// ```
  Stream<Map<String, dynamic>> get connectionStatusStream {
    return _connectionStatusChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }
}
