import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../providers/muse_providers.dart';
import '../providers/recording_providers.dart';
import 'live_session_screen.dart';

/// Screen for configuring a recording session.
/// 
/// Allows user to:
/// - Set session name and description
/// - Select CSV columns to record
/// - Start recording
class RecordingConfigScreen extends ConsumerStatefulWidget {
  const RecordingConfigScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecordingConfigScreen> createState() =>
      _RecordingConfigScreenState();
}

class _RecordingConfigScreenState extends ConsumerState<RecordingConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleColumnGroup(String groupName, bool value) {
    final columns = Constants.csvColumnGroups[groupName] ?? [];
    final selectedColumns = ref.read(selectedColumnsProvider);
    
    if (value) {
      // Add all columns in this group
      ref.read(selectedColumnsProvider.notifier).state = {
        ...selectedColumns,
        ...columns,
      };
    } else {
      // Remove all columns in this group
      ref.read(selectedColumnsProvider.notifier).state =
          selectedColumns.difference(columns.toSet());
    }
  }

  void _toggleColumn(String column) {
    final selectedColumns = ref.read(selectedColumnsProvider);
    
    if (selectedColumns.contains(column)) {
      ref.read(selectedColumnsProvider.notifier).state = {
        ...selectedColumns
      }..remove(column);
    } else {
      ref.read(selectedColumnsProvider.notifier).state = {
        ...selectedColumns,
        column,
      };
    }
  }

  Future<void> _startRecording() async {
    if (!_formKey.currentState!.validate()) return;

    // Update session name and description
    ref.read(sessionNameProvider.notifier).state = _nameController.text;
    ref.read(sessionDescriptionProvider.notifier).state =
        _descriptionController.text;

    try {
      // Start recording
      await ref.read(startRecordingProvider)();

      if (!mounted) return;

      // Navigate to live session screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LiveSessionScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDevices = ref.watch(selectedDevicesProvider);
    final devices = ref.watch(devicesProvider);
    final selectedColumns = ref.watch(selectedColumnsProvider);

    final deviceNames = devices
        .where((d) => selectedDevices.contains(d.id))
        .map((d) => d.name)
        .join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Recording'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selected devices info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Devices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deviceNames,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${selectedDevices.length} device(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Session name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Session Name *',
                hintText: 'e.g., Meditation Session 1',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a session name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Session description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add notes about this session',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // CSV columns selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Data Columns',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${selectedColumns.length} selected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            // Select all
                            final allColumns = Constants.csvColumnGroups.values
                                .expand((c) => c)
                                .toSet();
                            ref.read(selectedColumnsProvider.notifier).state =
                                allColumns;
                          },
                          child: const Text('Select All'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Clear all
                            ref.read(selectedColumnsProvider.notifier).state = {};
                          },
                          child: const Text('Clear All'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Reset to default
                            ref.read(selectedColumnsProvider.notifier).state =
                                Constants.defaultSelectedColumns;
                          },
                          child: const Text('Reset Default'),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...Constants.csvColumnGroups.entries.map((entry) {
                      final groupName = entry.key;
                      final columns = entry.value;
                      final allSelected = columns.every(
                        (col) => selectedColumns.contains(col),
                      );
                      final someSelected = columns.any(
                        (col) => selectedColumns.contains(col),
                      );

                      return ExpansionTile(
                        title: Row(
                          children: [
                            Checkbox(
                              value: allSelected,
                              tristate: true,
                              onChanged: (value) =>
                                  _toggleColumnGroup(groupName, value ?? false),
                            ),
                            Expanded(
                              child: Text(
                                groupName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${columns.where((c) => selectedColumns.contains(c)).length}/${columns.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        children: columns.map((column) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text(
                              column,
                              style: const TextStyle(fontSize: 12),
                            ),
                            value: selectedColumns.contains(column),
                            onChanged: (_) => _toggleColumn(column),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedColumns.isEmpty ? null : _startRecording,
        icon: const Icon(Icons.fiber_manual_record),
        label: const Text('Start Recording'),
        backgroundColor: selectedColumns.isEmpty ? Colors.grey : null,
      ),
    );
  }
}
