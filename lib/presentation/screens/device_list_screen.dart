import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/muse_device.dart';
import '../../utils/constants.dart';
import '../providers/muse_providers.dart';
import '../widgets/hsi_indicator.dart';
import 'recording_config_screen.dart';

/// Home screen for discovering and selecting Muse devices.
/// 
/// Features:
/// - Scan for nearby Muse headbands
/// - Display device list with battery and connection status
/// - Multi-select devices for recording
/// - Navigate to recording configuration
class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request Bluetooth and location permissions
    await [Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
    
    // Also request from native side
    final repository = ref.read(museRepositoryProvider);
    await repository.requestPermissions();
  }

  Future<void> _startScanning() async {
    final repository = ref.read(museRepositoryProvider);
    ref.read(isScanningProvider.notifier).state = true;
    await repository.startScanning();
  }

  Future<void> _stopScanning() async {
    final repository = ref.read(museRepositoryProvider);
    ref.read(isScanningProvider.notifier).state = false;
    await repository.stopScanning();
  }

  Future<void> _connectDevice(MuseDevice device) async {
    final repository = ref.read(museRepositoryProvider);
    final success = await repository.connectDevice(device);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to ${device.name}')),
      );
    }
  }

  Future<void> _disconnectDevice(String deviceId) async {
    final repository = ref.read(museRepositoryProvider);
    await repository.disconnectDevice(deviceId);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device disconnected')),
    );
  }

  void _navigateToRecordingConfig() {
    final selectedDevices = ref.read(selectedDevicesProvider);
    
    if (selectedDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one device')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordingConfigScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesStreamProvider);
    final isScanning = ref.watch(isScanningProvider);
    final selectedDevices = ref.watch(selectedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.appName),
        actions: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: devicesAsync.when(
        data: (devices) => _buildDeviceList(devices, selectedDevices),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selectedDevices.isNotEmpty)
            FloatingActionButton.extended(
              heroTag: 'start_session',
              onPressed: _navigateToRecordingConfig,
              label: Text('Start Session (${selectedDevices.length})'),
              icon: const Icon(Icons.play_arrow),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: isScanning ? _stopScanning : _startScanning,
            child: Icon(isScanning ? Icons.stop : Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(List<MuseDevice> devices, Set<String> selectedDevices) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Muse devices found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the scan button to search',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final isSelected = selectedDevices.contains(device.id);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              final notifier = ref.read(selectedDevicesProvider.notifier);
              if (isSelected) {
                notifier.state = notifier.state..remove(device.id);
              } else {
                notifier.state = notifier.state..add(device.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          final notifier = ref.read(selectedDevicesProvider.notifier);
                          if (value == true) {
                            notifier.state = notifier.state..add(device.id);
                          } else {
                            notifier.state = notifier.state..remove(device.id);
                          }
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              device.id,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.battery_std,
                                size: 20,
                                color: device.batteryPercent > 20
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text('${device.batteryPercent}%'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: device.isConnected
                                  ? Colors.green
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              device.isConnected ? 'Connected' : 'Disconnected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (device.isConnected) ..[
                    const Divider(height: 24),
                    HSIIndicator(device: device, size: 250),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _disconnectDevice(device.id),
                          icon: const Icon(Icons.bluetooth_disabled, size: 18),
                          label: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  ] else ..[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _connectDevice(device),
                      icon: const Icon(Icons.bluetooth_connected, size: 18),
                      label: const Text('Connect'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
