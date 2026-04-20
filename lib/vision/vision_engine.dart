import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class VisionEngine {
  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );

  bool _isBusy = false;

  Future<List<Pose>> processImage(InputImage inputImage) async {
    if (_isBusy) return const <Pose>[];
    _isBusy = true;
    try {
      return await _detector.processImage(inputImage);
    } finally {
      _isBusy = false;
    }
  }

  Future<void> dispose() async {
    await _detector.close();
  }
}
