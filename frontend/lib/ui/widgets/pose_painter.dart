import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool mirror;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
    required this.mirror,
  });

  static const _bones = <List<PoseLandmarkType>>[
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  static const _jointDots = <PoseLandmarkType>{
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightKnee,
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty || imageSize.isEmpty) return;

    final bool rotated =
        rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;
    final double srcW = rotated ? imageSize.height : imageSize.width;
    final double srcH = rotated ? imageSize.width : imageSize.height;

    final double scale = math.max(size.width / srcW, size.height / srcH);
    final double dx = (size.width - srcW * scale) / 2;
    final double dy = (size.height - srcH * scale) / 2;

    final dotPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF30E070)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    Offset toCanvas(PoseLandmark lm) {
      double x = lm.x;
      double y = lm.y;
      if (mirror) x = srcW - x;
      return Offset(x * scale + dx, y * scale + dy);
    }

    for (final pose in poses) {
      for (final bone in _bones) {
        final a = pose.landmarks[bone[0]];
        final b = pose.landmarks[bone[1]];
        if (a == null || b == null) continue;
        canvas.drawLine(toCanvas(a), toCanvas(b), linePaint);
      }

      for (final type in _jointDots) {
        final lm = pose.landmarks[type];
        if (lm == null) continue;
        canvas.drawCircle(toCanvas(lm), 5.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter old) =>
      old.poses != poses ||
      old.imageSize != imageSize ||
      old.rotation != rotation ||
      old.mirror != mirror;
}
