import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../providers/recording_providers.dart';
import '../providers/muse_providers.dart';
import 'device_list_screen.dart';

/// Post-session screen showing session summary and export options.
/// 
/// Features:
/// - Session statistics (duration, samples, triggers)
/// - List of recorded devices
/// - CSV file locations
/// - Share/export functionality
class PostSessionScreen extends ConsumerWidget {
  const PostSessionScreen({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _shareCSVFiles(
    BuildContext context,
    Map<String, String> filePaths,
  ) async {
    try {
      final xFiles = filePaths.values.map((path) => XFile(path)).toList();
      
      await Share.shareXFiles(
        xFiles,
        subject: 'MuseLog Recording Session',
        text: 'Muse brain-sensing data CSV files',
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing files: $e')),
      );
    }
  }

  Future<void> _openFileLocation(
    BuildContext context,
    String filePath,
  ) async {
    // Show file path in dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Location'),
        content: SelectableText(filePath),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startNewSession(BuildContext context, WidgetRef ref) {
    // Reset providers
    ref.read(recordingSessionProvider.notifier).state = null;
    ref.read(selectedDevicesProvider.notifier).state = {};
    ref.read(sessionNameProvider.notifier).state = '';
    ref.read(sessionDescriptionProvider.notifier).state = '';
    ref.read(selectedColumnsProvider.notifier).state =
        Constants.defaultSelectedColumns;

    // Navigate back to device list
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DeviceListScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(recordingSessionProvider);
    final devices = ref.watch(devicesProvider);

    if (session == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No session data available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _startNewSession(context, ref),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final sessionDevices = devices
        .where((d) => session.deviceIds.contains(d.id))
        .toList();

    final duration = session.duration ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Session Complete'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Success icon
          const Center(
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          
          // Session name
          Center(
            child: Text(
              session.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (session.description != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                session.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Session statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: _formatDuration(duration),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    icon: Icons.assessment,
                    label: 'Total Samples',
                    value: session.totalSamples.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    icon: Icons.flag,
                    label: 'Trigger Markers',
                    value: session.triggerCount.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    icon: Icons.devices,
                    label: 'Devices',
                    value: session.deviceIds.length.toString(),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    icon: Icons.table_chart,
                    label: 'CSV Columns',
                    value: session.selectedColumns.length.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Devices list
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recorded Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  ...sessionDevices.map((device) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.bluetooth, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(device.name),
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
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // CSV files
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CSV Files',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  if (session.csvFilePaths.isEmpty)
                    Text(
                      'No CSV files available',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  else
                    ...session.csvFilePaths.entries.map((entry) {
                      final deviceName = sessionDevices
                          .firstWhere(
                            (d) => d.id == entry.key,
                            orElse: () => sessionDevices.first,
                          )
                          .name;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.insert_drive_file, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    deviceName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value.split('/').last,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: () =>
                                  _openFileLocation(context, entry.value),
                              icon: const Icon(Icons.folder_open, size: 16),
                              label: const Text('View Location'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (session.csvFilePaths.isNotEmpty)
            FloatingActionButton.extended(
              heroTag: 'share',
              onPressed: () => _shareCSVFiles(context, session.csvFilePaths),
              icon: const Icon(Icons.share),
              label: const Text('Share CSV Files'),
            ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'new_session',
            onPressed: () => _startNewSession(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('New Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Constants.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
