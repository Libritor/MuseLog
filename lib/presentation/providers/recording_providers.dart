import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/recording_session.dart';
import '../../data/services/csv_writer_service.dart';
import '../../utils/constants.dart';

// ===== RECORDING SESSION PROVIDERS =====

/// Current recording session (null if not recording)
final recordingSessionProvider = StateProvider<RecordingSession?>((ref) => null);

/// Whether currently recording
final isRecordingProvider = Provider<bool>((ref) {
  final session = ref.watch(recordingSessionProvider);
  return session?.isRecording ?? false;
});

/// Selected CSV columns for recording
final selectedColumnsProvider = StateProvider<Set<String>>(
  (ref) => Constants.defaultSelectedColumns,
);

/// Session name input
final sessionNameProvider = StateProvider<String>((ref) => '');

/// Session description input
final sessionDescriptionProvider = StateProvider<String>((ref) => '');

// ===== CSV WRITER PROVIDERS =====

/// CSV writers for each device (deviceId -> CSVWriterService)
final csvWritersProvider = StateProvider<Map<String, CSVWriterService>>((ref) => {});

/// Trigger count for current session
final triggerCountProvider = StateProvider<int>((ref) => 0);

/// Total samples recorded in current session
final totalSamplesProvider = StateProvider<int>((ref) => 0);

// ===== SESSION ACTIONS =====

/// Provider for starting a new recording session
final startRecordingProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final selectedDevices = ref.read(selectedDevicesProvider);
    final selectedColumns = ref.read(selectedColumnsProvider);
    final sessionName = ref.read(sessionNameProvider);
    final sessionDescription = ref.read(sessionDescriptionProvider);

    if (selectedDevices.isEmpty) {
      throw Exception('No devices selected');
    }

    if (sessionName.isEmpty) {
      throw Exception('Session name is required');
    }

    // Create new session
    final session = RecordingSession(
      id: const Uuid().v4(),
      name: sessionName,
      description: sessionDescription.isEmpty ? null : sessionDescription,
      deviceIds: selectedDevices.toList(),
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
      selectedColumns: selectedColumns,
      isRecording: true,
    );

    // Create CSV writers for each device
    final writers = <String, CSVWriterService>{};
    for (final deviceId in selectedDevices) {
      final writer = CSVWriterService(
        sessionId: session.id,
        deviceId: deviceId,
        selectedColumns: selectedColumns,
        sessionStartTime: session.startedAt!,
      );
      await writer.initialize();
      writers[deviceId] = writer;
    }

    // Update state
    ref.read(recordingSessionProvider.notifier).state = session;
    ref.read(csvWritersProvider.notifier).state = writers;
    ref.read(triggerCountProvider.notifier).state = 0;
    ref.read(totalSamplesProvider.notifier).state = 0;
  };
});

/// Provider for stopping the current recording session
final stopRecordingProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final session = ref.read(recordingSessionProvider);
    if (session == null || !session.isRecording) return;

    // Close all CSV writers
    final writers = ref.read(csvWritersProvider);
    final filePaths = <String, String>{};
    for (final entry in writers.entries) {
      await entry.value.close();
      filePaths[entry.key] = entry.value.getFilePath();
    }

    // Update session with end time and file paths
    final updatedSession = session.copyWith(
      endedAt: DateTime.now(),
      isRecording: false,
      csvFilePaths: filePaths,
      totalSamples: ref.read(totalSamplesProvider),
      triggerCount: ref.read(triggerCountProvider),
    );

    ref.read(recordingSessionProvider.notifier).state = updatedSession;
    ref.read(csvWritersProvider.notifier).state = {};
  };
});

/// Provider for adding a trigger marker
final addTriggerProvider = Provider<void Function()>((ref) {
  return () {
    final writers = ref.read(csvWritersProvider);
    final currentCount = ref.read(triggerCountProvider);
    
    // Increment trigger on all writers
    for (final writer in writers.values) {
      writer.incrementTrigger();
    }
    
    // Update state
    ref.read(triggerCountProvider.notifier).state = currentCount + 1;
  };
});
