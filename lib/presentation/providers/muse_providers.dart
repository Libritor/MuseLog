import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/muse_device.dart';
import '../../data/models/eeg_sample.dart';
import '../../data/models/band_power_sample.dart';
import '../../data/models/fnirs_sample.dart';
import '../../data/models/imu_sample.dart';
import '../../data/repositories/muse_repository.dart';
import '../../data/services/muse_service.dart';

// ===== SERVICE & REPOSITORY PROVIDERS =====

/// Muse service provider (singleton)
final museServiceProvider = Provider<MuseService>((ref) {
  final service = MuseService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Muse repository provider
final museRepositoryProvider = Provider<MuseRepository>((ref) {
  final service = ref.watch(museServiceProvider);
  final repository = MuseRepository(museService: service);
  return repository;
});

// ===== DEVICE PROVIDERS =====

/// Stream of discovered devices
final devicesStreamProvider = StreamProvider<List<MuseDevice>>((ref) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchDevices();
});

/// Current devices list (synchronous)
final devicesProvider = Provider<List<MuseDevice>>((ref) {
  final devicesAsync = ref.watch(devicesStreamProvider);
  return devicesAsync.maybeWhen(
    data: (devices) => devices,
    orElse: () => [],
  );
});

/// Connected devices only
final connectedDevicesProvider = Provider<List<MuseDevice>>((ref) {
  final devices = ref.watch(devicesProvider);
  return devices.where((d) => d.isConnected).toList();
});

/// Selected devices for recording (state)
final selectedDevicesProvider = StateProvider<Set<String>>((ref) => {});

// ===== DATA STREAM PROVIDERS =====

/// Stream of all EEG samples
final eegStreamProvider = StreamProvider<EEGSample>((ref) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchEEGData();
});

/// Stream of all band power samples
final bandPowerStreamProvider = StreamProvider<BandPowerSample>((ref) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchBandPowerData();
});

/// Stream of all fNIRS samples
final fnirsStreamProvider = StreamProvider<FNIRSSample>((ref) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchFNIRSData();
});

/// Stream of all IMU samples
final imuStreamProvider = StreamProvider<IMUSample>((ref) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchIMUData();
});

// ===== DEVICE-SPECIFIC DATA PROVIDERS =====

/// EEG stream for a specific device
final eegStreamForDeviceProvider = StreamProvider.family<EEGSample, String>((ref, deviceId) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchEEGDataForDevice(deviceId);
});

/// Band power stream for a specific device
final bandPowerStreamForDeviceProvider = StreamProvider.family<BandPowerSample, String>((ref, deviceId) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchBandPowerDataForDevice(deviceId);
});

/// fNIRS stream for a specific device
final fnirsStreamForDeviceProvider = StreamProvider.family<FNIRSSample, String>((ref, deviceId) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchFNIRSDataForDevice(deviceId);
});

/// IMU stream for a specific device
final imuStreamForDeviceProvider = StreamProvider.family<IMUSample, String>((ref, deviceId) {
  final repository = ref.watch(museRepositoryProvider);
  return repository.watchIMUDataForDevice(deviceId);
});

// ===== SCANNING STATE =====

/// Whether device scanning is active
final isScanningProvider = StateProvider<bool>((ref) => false);
