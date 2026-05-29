import 'package:flutter/material.dart';

/// Front-view body silhouette with one muscle group highlighted in purple.
/// Constrain width via SizedBox; height follows the fixed 100:244 aspect ratio.
class MuscleMap extends StatelessWidget {
  final String bodyPart;

  const MuscleMap({super.key, required this.bodyPart});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _MuscleMapPainter.kW / _MuscleMapPainter.kH,
      child: CustomPaint(
        painter: _MuscleMapPainter(bodyPart: bodyPart),
      ),
    );
  }
}

class _MuscleMapPainter extends CustomPainter {
  final String bodyPart;

  const _MuscleMapPainter({required this.bodyPart});

  // Logical coordinate space — canvas is scaled to fit.
  static const kW = 100.0;
  static const kH = 244.0;

  // (segmentName, rect in logical coords, corner radius)
  static final _segments = <(String, Rect, double)>[
    ('head', const Rect.fromLTRB(32, 2, 68, 34), 18.0),
    ('neck', const Rect.fromLTRB(43, 34, 57, 44), 5.0),
    ('leftShoulder', const Rect.fromLTRB(10, 44, 30, 68), 10.0),
    ('rightShoulder', const Rect.fromLTRB(70, 44, 90, 68), 10.0),
    ('chest', const Rect.fromLTRB(28, 44, 72, 90), 8.0),
    ('core', const Rect.fromLTRB(29, 90, 71, 132), 8.0),
    ('leftUpperArm', const Rect.fromLTRB(10, 68, 26, 108), 7.0),
    ('rightUpperArm', const Rect.fromLTRB(74, 68, 90, 108), 7.0),
    ('leftForearm', const Rect.fromLTRB(10, 110, 25, 148), 6.0),
    ('rightForearm', const Rect.fromLTRB(75, 110, 90, 148), 6.0),
    ('leftHand', const Rect.fromLTRB(11, 150, 24, 162), 5.0),
    ('rightHand', const Rect.fromLTRB(76, 150, 89, 162), 5.0),
    ('hips', const Rect.fromLTRB(27, 132, 73, 150), 6.0),
    ('leftThigh', const Rect.fromLTRB(28, 152, 50, 196), 7.0),
    ('rightThigh', const Rect.fromLTRB(50, 152, 72, 196), 7.0),
    ('leftCalf', const Rect.fromLTRB(29, 198, 49, 232), 6.0),
    ('rightCalf', const Rect.fromLTRB(51, 198, 71, 232), 6.0),
    ('leftFoot', const Rect.fromLTRB(25, 234, 51, 244), 4.0),
    ('rightFoot', const Rect.fromLTRB(49, 234, 75, 244), 4.0),
  ];

  static Set<String> _highlightFor(String bodyPart) {
    switch (bodyPart.toLowerCase().trim()) {
      case 'chest':
        return {'chest'};
      case 'back':
        // front-view approximation: show upper torso + shoulders
        return {'chest', 'leftShoulder', 'rightShoulder'};
      case 'shoulders':
        return {'leftShoulder', 'rightShoulder'};
      case 'upper arms':
        return {'leftUpperArm', 'rightUpperArm'};
      case 'lower arms':
        return {'leftForearm', 'rightForearm'};
      case 'waist':
        return {'core'};
      case 'legs':
        return {'leftThigh', 'rightThigh', 'leftCalf', 'rightCalf'};
      case 'cardio':
        return {'chest', 'core', 'leftThigh', 'rightThigh'};
      default:
        return {};
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / kW, size.height / kH);

    final highlighted = _highlightFor(bodyPart);

    final basePaint = Paint()
      ..color = const Color(0xFF252538)
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = const Color(0xFF7C5CFF).withAlpha(210)
      ..style = PaintingStyle.fill;

    for (final (name, rect, radius) in _segments) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        highlighted.contains(name) ? highlightPaint : basePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MuscleMapPainter old) => old.bodyPart != bodyPart;
}
