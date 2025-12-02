import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../providers/chart_data_providers.dart';

/// Real-time EEG chart displaying raw data from all four electrodes.
class EEGChart extends ConsumerWidget {
  final String deviceId;
  final Set<String> visibleElectrodes;

  const EEGChart({
    Key? key,
    required this.deviceId,
    this.visibleElectrodes = const {'TP9', 'AF7', 'AF8', 'TP10'},
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = ref.watch(eegChartDataProvider(deviceId));

    // Check if we have any data
    final hasData = chartData.tp9Data.isNotEmpty ||
        chartData.af7Data.isNotEmpty ||
        chartData.af8Data.isNotEmpty ||
        chartData.tp10Data.isNotEmpty;

    if (!hasData) {
      return Center(
        child: Text(
          'Waiting for EEG data...',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 100,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}s',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          if (visibleElectrodes.contains('TP9'))
            _buildLineData(
              chartData.tp9Data,
              Constants.tp9Color,
              'TP9',
            ),
          if (visibleElectrodes.contains('AF7'))
            _buildLineData(
              chartData.af7Data,
              Constants.af7Color,
              'AF7',
            ),
          if (visibleElectrodes.contains('AF8'))
            _buildLineData(
              chartData.af8Data,
              Constants.af8Color,
              'AF8',
            ),
          if (visibleElectrodes.contains('TP10'))
            _buildLineData(
              chartData.tp10Data,
              Constants.tp10Color,
              'TP10',
            ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineData(
    List<ChartDataPoint> data,
    Color color,
    String label,
  ) {
    if (data.isEmpty) {
      return LineChartBarData(spots: []);
    }

    // Get the earliest timestamp for relative X-axis
    final startTime = data.first.timestamp;

    final spots = data.map((point) {
      final x = point.timestamp.difference(startTime).inSeconds.toDouble();
      return FlSpot(x, point.value);
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 1.5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}

/// Legend widget for EEG chart
class EEGChartLegend extends StatelessWidget {
  final Set<String> visibleElectrodes;
  final Function(String) onToggle;

  const EEGChartLegend({
    Key? key,
    required this.visibleElectrodes,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('TP9', Constants.tp9Color),
        _buildLegendItem('AF7', Constants.af7Color),
        _buildLegendItem('AF8', Constants.af8Color),
        _buildLegendItem('TP10', Constants.tp10Color),
      ],
    );
  }

  Widget _buildLegendItem(String electrode, Color color) {
    final isVisible = visibleElectrodes.contains(electrode);
    
    return InkWell(
      onTap: () => onToggle(electrode),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isVisible,
            onChanged: (_) => onToggle(electrode),
            activeColor: color,
          ),
          Container(
            width: 20,
            height: 3,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            electrode,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isVisible ? FontWeight.bold : FontWeight.normal,
              color: isVisible ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
