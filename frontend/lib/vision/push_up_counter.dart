import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PushUpCounter {
  static const double _minLikelihood = 0.5;
  static const double _downThresholdDegrees = 110.0;
  static const double _upThresholdDegrees = 160.0;
  static const double _plankThresholdDegrees = 140.0;
  static const Duration _minDownDuration = Duration(milliseconds: 250);
  static const Duration _minBetweenReps = Duration(milliseconds: 500);

  final ValueNotifier<int> repCount = ValueNotifier<int>(0);
  final ValueNotifier<String> debugNotifier = ValueNotifier<String>('');
  bool _isDown = false;
  DateTime? _lastDownTime;
  DateTime? _lastRepTime;

  void processPose(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

    if (leftShoulder == null ||
        leftElbow == null ||
        leftWrist == null ||
        leftHip == null ||
        leftAnkle == null ||
        rightShoulder == null ||
        rightElbow == null ||
        rightWrist == null ||
        rightHip == null ||
        rightAnkle == null) {
      debugNotifier.value = 'Waiting for full body in frame…';
      return;
    }

    final double leftScore =
        leftShoulder.likelihood + leftElbow.likelihood + leftWrist.likelihood;
    final double rightScore = rightShoulder.likelihood +
        rightElbow.likelihood +
        rightWrist.likelihood;

    final bool useLeft = leftScore >= rightScore;
    final PoseLandmark activeShoulder = useLeft ? leftShoulder : rightShoulder;
    final PoseLandmark activeElbow = useLeft ? leftElbow : rightElbow;
    final PoseLandmark activeWrist = useLeft ? leftWrist : rightWrist;
    final PoseLandmark activeHip = useLeft ? leftHip : rightHip;
    final PoseLandmark activeAnkle = useLeft ? leftAnkle : rightAnkle;

    final double activeScore = useLeft ? leftScore : rightScore;
    final String sideLabel = useLeft ? 'LEFT' : 'RIGHT';
    final String scoreStr = (activeScore / 3.0).toStringAsFixed(2);

    if (activeScore / 3.0 < _minLikelihood) {
      debugNotifier.value =
          'Side: $sideLabel (Score: $scoreStr) — arm confidence too low';
      return;
    }
    if (activeHip.likelihood < _minLikelihood ||
        activeAnkle.likelihood < _minLikelihood) {
      debugNotifier.value =
          'Side: $sideLabel (Score: $scoreStr) — hip/ankle confidence too low';
      return;
    }

    final bodyAngle = _getAngle(activeShoulder, activeHip, activeAnkle);
    final bool isPlank = bodyAngle > _plankThresholdDegrees;
    final bool isWristAboveHip = activeWrist.y < activeHip.y;
    final elbowAngle = _getAngle(activeShoulder, activeElbow, activeWrist);

    String repEvent = '';

    if (isPlank && isWristAboveHip) {
      if (elbowAngle < _downThresholdDegrees && !_isDown) {
        _isDown = true;
        _lastDownTime = DateTime.now();
      } else if (elbowAngle > _upThresholdDegrees && _isDown) {
        final now = DateTime.now();
        final Duration downHeld = _lastDownTime == null
            ? Duration.zero
            : now.difference(_lastDownTime!);
        final Duration sinceLastRep = _lastRepTime == null
            ? const Duration(days: 1)
            : now.difference(_lastRepTime!);

        if (downHeld < _minDownDuration) {
          _isDown = false;
          _lastDownTime = null;
          repEvent = 'rejected: down held ${downHeld.inMilliseconds}ms';
        } else if (sinceLastRep < _minBetweenReps) {
          _isDown = false;
          _lastDownTime = null;
          repEvent = 'rejected: ${sinceLastRep.inMilliseconds}ms since last';
        } else {
          _isDown = false;
          _lastDownTime = null;
          _lastRepTime = now;
          repCount.value = repCount.value + 1;
          repEvent = 'counted';
        }
      }
    } else {
      _isDown = false;
      _lastDownTime = null;
    }

    debugNotifier.value = '''
Side: $sideLabel (Score: $scoreStr)
Elbow Angle: ${elbowAngle.toStringAsFixed(1)}
Body Angle (Plank): ${bodyAngle.toStringAsFixed(1)} (isPlank: $isPlank)
isWristAboveHip: $isWristAboveHip
isDown State: $_isDown${repEvent.isEmpty ? '' : '\nLast rep: $repEvent'}''';
  }

  double _getAngle(PoseLandmark p1, PoseLandmark p2, PoseLandmark p3) {
    double angle = (math.atan2(p3.y - p2.y, p3.x - p2.x) -
            math.atan2(p1.y - p2.y, p1.x - p2.x)) *
        (180 / math.pi);

    angle = angle.abs();
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    return angle;
  }

  void reset() {
    _isDown = false;
    _lastDownTime = null;
    _lastRepTime = null;
    repCount.value = 0;
  }

  void dispose() {
    repCount.dispose();
    debugNotifier.dispose();
  }
}
