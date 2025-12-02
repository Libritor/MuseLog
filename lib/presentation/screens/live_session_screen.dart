import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../utils/constants.dart';
import '../providers/muse_providers.dart';
import '../providers/recording_providers.dart';
import '../providers/chart_data_providers.dart';
import '../widgets/hsi_indicator.dart';
import '../widgets/eeg_chart.dart';
import 'post_session_screen.dart';

/// Live session screen showing real-time data and recording controls.
/// 
/// Features:
/// - Live HSI indicators for all connected devices
/// - Real-time charts (EEG, band powers, fNIRS, IMU)
/// - Recording controls (trigger markers, stop)
/// - Session statistics
class LiveSessionScreen extends ConsumerStatefulWidget {
  const LiveSessionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

class _LiveSessionScreenState extends ConsumerState<LiveSessionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Timer? _recordingTimer;
  Duration _elapsedTime = Duration.zero;

  // Visible electrodes for EEG chart
  final Set<String> _visibleElectrodes = {'TP9', 'AF7', 'AF8', 'TP10'};

  @override
  void initState() {
    super.initState();
    
    final session = ref.read(recordingSessionProvider);
    final deviceCount = session?.deviceIds.length ?? 1;
    
    _tabController = TabController(length: deviceCount, vsync: this);

    // Start timer to track elapsed time
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = _elapsedTime + const Duration(seconds: 1);
        });
      }
    });

    // Listen to data streams and write to CSV
    _setupDataStreamListeners();
  }

  void _setupDataStreamListeners() {
    final session = ref.read(recordingSessionProvider);
    if (session == null) return;

    // Listen to EEG data and write to CSV
    for (final deviceId in session.deviceIds) {
      ref.listen<AsyncValue<EEGSample>>(
        eegStreamForDeviceProvider(deviceId),
        (previous, next) {
          next.whenData((sample) async {
            final writers = ref.read(csvWritersProvider);
            final writer = writers[deviceId];
            if (writer != null) {
              final devices = ref.read(devicesProvider);
              final device = devices.firstWhere((d) => d.id == deviceId);
              await writer.writeEEGSample(
                sample,
                batteryPercent: device.batteryPercent,
              );
              
              // Increment sample count
              final count = ref.read(totalSamplesProvider);
              ref.read(totalSamplesProvider.notifier).state = count + 1;
            }
          });
        },
      );

      // Similar listeners for band power, fNIRS, and IMU
      // (Implementation follows same pattern)
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _stopRecording() async {
    // Confirm stop
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Recording?'),
        content: const Text(
          'Are you sure you want to stop recording? This will save and close the current session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Stop recording
    await ref.read(stopRecordingProvider)();

    if (!mounted) return;

    // Navigate to post-session screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PostSessionScreen(),
      ),
    );
  }

  void _addTriggerMarker() {
    ref.read(addTriggerProvider)();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trigger marker added (${ref.read(triggerCountProvider)})'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(recordingSessionProvider);
    final devices = ref.watch(devicesProvider);
    final totalSamples = ref.watch(totalSamplesProvider);
    final triggerCount = ref.watch(triggerCountProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No recording session')),
      );
    }

    final sessionDevices = devices
        .where((d) => session.deviceIds.contains(d.id))
        .toList();

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation while recording
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please stop recording before going back'),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.name),
              Text(
                _formatDuration(_elapsedTime),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopRecording,
              tooltip: 'Stop Recording',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: sessionDevices.map((device) {
              return Tab(text: device.name);
            }).toList(),
          ),
        ),
        body: Column(
          children: [
            // Session stats
            Container(
              padding: const EdgeInsets.all(16),
              color: Constants.primaryColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.assessment,
                    label: 'Samples',
                    value: totalSamples.toString(),
                  ),
                  _buildStatItem(
                    icon: Icons.flag,
                    label: 'Triggers',
                    value: triggerCount.toString(),
                  ),
                  _buildStatItem(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: _formatDuration(_elapsedTime),
                  ),
                ],
              ),
            ),

            // Device tabs with charts
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: sessionDevices.map((device) {
                  return _buildDeviceView(device);
                }).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addTriggerMarker,
          icon: const Icon(Icons.flag),
          label: const Text('Add Marker'),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceView(device) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // HSI Indicator
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: HSIIndicator(device: device, size: 250),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // EEG Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Raw EEG',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: EEGChart(
                    deviceId: device.id,
                    visibleElectrodes: _visibleElectrodes,
                  ),
                ),
                const SizedBox(height: 8),
                EEGChartLegend(
                  visibleElectrodes: _visibleElectrodes,
                  onToggle: (electrode) {
                    setState(() {
                      if (_visibleElectrodes.contains(electrode)) {
                        _visibleElectrodes.remove(electrode);
                      } else {
                        _visibleElectrodes.add(electrode);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Placeholder for other charts (band powers, fNIRS, IMU)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Additional Charts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Band Powers, fNIRS, and IMU charts can be added here',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
