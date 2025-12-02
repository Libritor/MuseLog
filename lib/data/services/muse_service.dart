import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../models/muse_device.dart';
import '../models/eeg_sample.dart';
import '../models/band_power_sample.dart';
import '../models/fnirs_sample.dart';
import '../models/imu_sample.dart';
import 'platform_channel.dart';

/// Service layer for interacting with Muse devices.
/// 
/// Provides a clean Dart API over the platform channel,
/// managing device discovery, connections, and data streams.
class MuseService {
  final MusePlatformChannel _platformChannel;
  
  // Stream controllers for managing data
  final _devicesController = BehaviorSubject<List<MuseDevice>>.seeded([]);
  final _eegController = StreamController<EEGSample>.broadcast();
  final _bandPowerController = StreamController<BandPowerSample>.broadcast();
  final _fnirsController = StreamController<FNIRSSample>.broadcast();
  final _imuController = StreamController<IMUSample>.broadcast();
  
  StreamSubscription? _deviceScanSubscription;
  StreamSubscription? _eegSubscription;
  StreamSubscription? _bandPowerSubscription;
  StreamSubscription? _fnirsSubscription;
  StreamSubscription? _imuSubscription;
  StreamSubscription? _connectionStatusSubscription;
  
  // Track connected devices
  final Map<String, MuseDevice> _connectedDevices = {};

  MuseService({MusePlatformChannel? platformChannel})
      : _platformChannel = platformChannel ?? MusePlatformChannel() {
    _initialize();
  }

  void _initialize() {
    // Listen to device scan results
    _deviceScanSubscription = _platformChannel.deviceScanStream.listen(
      (devices) {
        // Merge with connected device states
        final updatedDevices = devices.map((device) {
          if (_connectedDevices.containsKey(device.id)) {
            return _connectedDevices[device.id]!;
          }
          return device;
        }).toList();
        _devicesController.add(updatedDevices);
      },
      onError: (error) {
        print('Device scan error: $error');
      },
    );

    // Listen to connection status updates
    _connectionStatusSubscription = _platformChannel.connectionStatusStream.listen(
      (status) {
        final deviceId = status['deviceId'] as String?;
        if (deviceId != null) {
          final isConnected = status['isConnected'] as bool? ?? false;
          final batteryPercent = status['batteryPercent'] as int? ?? 0;
          
          if (_connectedDevices.containsKey(deviceId)) {
            _connectedDevices[deviceId] = _connectedDevices[deviceId]!.copyWith(
              isConnected: isConnected,
              batteryPercent: batteryPercent,
            );
          }
          
          // Update devices list
          final devices = _devicesController.value;
          final updatedDevices = devices.map((device) {
            if (device.id == deviceId) {
              return device.copyWith(
                isConnected: isConnected,
                batteryPercent: batteryPercent,
              );
            }
            return device;
          }).toList();
          _devicesController.add(updatedDevices);
        }
      },
    );

    // Forward data streams
    _eegSubscription = _platformChannel.eegDataStream.listen(
      (sample) => _eegController.add(sample),
      onError: (error) => print('EEG stream error: $error'),
    );

    _bandPowerSubscription = _platformChannel.bandPowerStream.listen(
      (sample) => _bandPowerController.add(sample),
      onError: (error) => print('Band power stream error: $error'),
    );

    _fnirsSubscription = _platformChannel.fnirsStream.listen(
      (sample) => _fnirsController.add(sample),
      onError: (error) => print('fNIRS stream error: $error'),
    );

    _imuSubscription = _platformChannel.imuStream.listen(
      (sample) => _imuController.add(sample),
      onError: (error) => print('IMU stream error: $error'),
    );
  }

  // ===== PUBLIC API =====

  /// Stream of discovered devices
  Stream<List<MuseDevice>> get devicesStream => _devicesController.stream;

  /// Current list of devices
  List<MuseDevice> get devices => _devicesController.value;

  /// Stream of EEG samples from all connected devices
  Stream<EEGSample> get eegStream => _eegController.stream;

  /// Stream of band power samples from all connected devices
  Stream<BandPowerSample> get bandPowerStream => _bandPowerController.stream;

  /// Stream of fNIRS samples from all connected devices
  Stream<FNIRSSample> get fnirsStream => _fnirsController.stream;

  /// Stream of IMU samples from all connected devices
  Stream<IMUSample> get imuStream => _imuController.stream;

  /// Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    return await _platformChannel.requestBluetoothPermissions();
  }

  /// Start scanning for nearby Muse devices
  Future<void> startScanning() async {
    await _platformChannel.startDeviceScan();
  }

  /// Stop scanning for devices
  Future<void> stopScanning() async {
    await _platformChannel.stopDeviceScan();
  }

  /// Connect to a Muse device
  Future<bool> connectDevice(MuseDevice device) async {
    final success = await _platformChannel.connectToDevice(device.id);
    if (success) {
      _connectedDevices[device.id] = device.copyWith(isConnected: true);
      await _platformChannel.startDataStream(device.id);
    }
    return success;
  }

  /// Disconnect from a Muse device
  Future<void> disconnectDevice(String deviceId) async {
    await _platformChannel.stopDataStream(deviceId);
    await _platformChannel.disconnectFromDevice(deviceId);
    _connectedDevices.remove(deviceId);
  }

  /// Get list of currently connected devices
  List<MuseDevice> getConnectedDevices() {
    return _connectedDevices.values.toList();
  }

  /// Check if a device is connected
  bool isDeviceConnected(String deviceId) {
    return _connectedDevices.containsKey(deviceId) &&
        _connectedDevices[deviceId]!.isConnected;
  }

  /// Dispose resources
  void dispose() {
    _deviceScanSubscription?.cancel();
    _eegSubscription?.cancel();
    _bandPowerSubscription?.cancel();
    _fnirsSubscription?.cancel();
    _imuSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    
    _devicesController.close();
    _eegController.close();
    _bandPowerController.close();
    _fnirsController.close();
    _imuController.close();
  }
}
