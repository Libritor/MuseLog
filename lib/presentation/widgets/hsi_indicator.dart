import 'package:flutter/material.dart';
import '../../data/models/muse_device.dart';
import '../../utils/constants.dart';

/// Horseshoe-style indicator for EEG contact quality (HSI).
/// 
/// Displays four circles representing the four EEG electrodes:
/// - TP9 (left ear)
/// - AF7 (left forehead)
/// - AF8 (right forehead)
/// - TP10 (right ear)
/// 
/// Colors:
/// - Green (HSI = 1): Good connection
/// - Yellow (HSI = 2): Medium connection
/// - Red (HSI = 4): Bad connection
/// - Gray: Unknown
/// 
/// Small warning icon appears if artifact flag is set.
class HSIIndicator extends StatelessWidget {
  final MuseDevice device;
  final double size;

  const HSIIndicator({
    Key? key,
    required this.device,
    this.size = 200,
  }) : super(key: key);

  Color _getHSIColor(int hsi) {
    switch (hsi) {
      case Constants.hsiGood:
        return Constants.hsiGoodColor;
      case Constants.hsiMedium:
        return Constants.hsiMediumColor;
      case Constants.hsiBad:
        return Constants.hsiBadColor;
      default:
        return Constants.hsiUnknownColor;
    }
  }

  Widget _buildElectrode({
    required String label,
    required int hsi,
    required bool artifactFree,
    required double left,
    required double top,
  }) {
    final color = _getHSIColor(hsi);
    
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!artifactFree)
                const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'HSI: $hsi',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      child: Stack(
        children: [
          // Background horseshoe shape (optional)
          Positioned.fill(
            child: CustomPaint(
              painter: _HorseshoePainter(),
            ),
          ),
          
          // TP9 (left ear)
          _buildElectrode(
            label: 'TP9',
            hsi: device.tp9Hsi,
            artifactFree: device.tp9ArtifactFree,
            left: 0,
            top: size * 0.25,
          ),
          
          // AF7 (left forehead)
          _buildElectrode(
            label: 'AF7',
            hsi: device.af7Hsi,
            artifactFree: device.af7ArtifactFree,
            left: size * 0.25,
            top: 0,
          ),
          
          // AF8 (right forehead)
          _buildElectrode(
            label: 'AF8',
            hsi: device.af8Hsi,
            artifactFree: device.af8ArtifactFree,
            left: size * 0.5,
            top: 0,
          ),
          
          // TP10 (right ear)
          _buildElectrode(
            label: 'TP10',
            hsi: device.tp10Hsi,
            artifactFree: device.tp10ArtifactFree,
            left: size * 0.75,
            top: size * 0.25,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for horseshoe background
class _HorseshoePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    // Draw a simple arc representing the headband
    path.moveTo(size.width * 0.1, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.3, -size.height * 0.2,
      size.width * 0.5, 0,
    );
    path.quadraticBezierTo(
      size.width * 0.7, -size.height * 0.2,
      size.width * 0.9, size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
