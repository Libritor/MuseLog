import 'dart:async';
import '../models/muse_device.dart';
import '../models/eeg_sample.dart';
import '../models/band_power_sample.dart';
import '../models/fnirs_sample.dart';
import '../models/imu_sample.dart';
import '../services/muse_service.dart';

/// Repository pattern for Muse data access.
/// 
/// Provides a clean abstraction over MuseService for use in
/// presentation layer (Riverpod providers).
class MuseRepository {
  final MuseService _museService;

  MuseRepository({MuseService? museService})
      : _museService = museService ?? MuseService();

  // ===== DEVICE MANAGEMENT =====

  /// Get stream of discovered devices
  Stream<List<MuseDevice>> watchDevices() => _museService.devicesStream;

  /// Get current devices list
  List<MuseDevice> getDevices() => _museService.devices;

  /// Request Bluetooth permissions
  Future<bool> requestPermissions() => _museService.requestPermissions();

  /// Start scanning for Muse devices
  Future<void> startScanning() => _museService.startScanning();

  /// Stop scanning
  Future<void> stopScanning() => _museService.stopScanning();

  /// Connect to a device
  Future<bool> connectDevice(MuseDevice device) => _museService.connectDevice(device);

  /// Disconnect from a device
  Future<void> disconnectDevice(String deviceId) => _museService.disconnectDevice(deviceId);

  /// Get connected devices
  List<MuseDevice> getConnectedDevices() => _museService.getConnectedDevices();

  /// Check if device is connected
  bool isDeviceConnected(String deviceId) => _museService.isDeviceConnected(deviceId);

  // ===== DATA STREAMS =====

  /// Stream of EEG data
  Stream<EEGSample> watchEEGData() => _museService.eegStream;

  /// Stream of band power data
  Stream<BandPowerSample> watchBandPowerData() => _museService.bandPowerStream;

  /// Stream of fNIRS data
  Stream<FNIRSSample> watchFNIRSData() => _museService.fnirsStream;

  /// Stream of IMU data
  Stream<IMUSample> watchIMUData() => _museService.imuStream;

  /// Filter stream by device ID
  Stream<EEGSample> watchEEGDataForDevice(String deviceId) {
    return _museService.eegStream.where((sample) => sample.deviceId == deviceId);
  }

  Stream<BandPowerSample> watchBandPowerDataForDevice(String deviceId) {
    return _museService.bandPowerStream.where((sample) => sample.deviceId == deviceId);
  }

  Stream<FNIRSSample> watchFNIRSDataForDevice(String deviceId) {
    return _museService.fnirsStream.where((sample) => sample.deviceId == deviceId);
  }

  Stream<IMUSample> watchIMUDataForDevice(String deviceId) {
    return _museService.imuStream.where((sample) => sample.deviceId == deviceId);
  }

  /// Dispose repository
  void dispose() {
    _museService.dispose();
  }
}
