import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rehab_app/data/models/workout_session.dart';
import 'package:rehab_app/ui/screens/session_summary_screen.dart';
import 'package:rehab_app/ui/widgets/pose_painter.dart';
import 'package:rehab_app/vision/push_up_counter.dart';
import 'package:rehab_app/vision/vision_engine.dart';

const _deviceOrientationDegrees = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

class CameraScreen extends StatefulWidget {
  final String exerciseName;
  final String bodyPart;
  final String exerciseId;

  const CameraScreen({
    super.key,
    required this.exerciseName,
    required this.bodyPart,
    required this.exerciseId,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final VisionEngine _visionEngine = VisionEngine();
  final PushUpCounter _pushUpCounter = PushUpCounter();
  final ValueNotifier<List<Pose>> _posesNotifier =
      ValueNotifier<List<Pose>>(const []);

  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  String? _errorMessage;
  bool _initializing = true;
  bool _switching = false;

  bool _isProcessingImage = false;
  Size _latestImageSize = Size.zero;
  InputImageRotation _latestRotation = InputImageRotation.rotation0deg;

  late final DateTime _sessionStartTime;
  bool _sessionFinished = false;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _teardownController();
    _visionEngine.dispose();
    _posesNotifier.dispose();
    _pushUpCounter.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _teardownController();
    } else if (state == AppLifecycleState.resumed) {
      _bootstrap();
    }
  }

  Future<void> _teardownController() async {
    final c = _controller;
    _controller = null;
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) {
        await c.stopImageStream();
      }
    } catch (_) {}
    await c.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _initializing = true;
      _errorMessage = null;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage =
            'Camera permission denied. Enable it in system settings to continue.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _errorMessage = 'No cameras available on this device.';
        });
        return;
      }

      final frontIndex = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _cameras = cameras;
      _cameraIndex = frontIndex >= 0 ? frontIndex : 0;

      await _initControllerForIndex(_cameraIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _initControllerForIndex(int index) async {
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }

    await controller.startImageStream(_processCameraImage);

    _posesNotifier.value = const [];
    setState(() {
      _controller = controller;
      _cameraIndex = index;
      _initializing = false;
    });
  }

  Future<void> _flipCamera() async {
    if (_switching || _cameras.length < 2) return;
    _switching = true;
    try {
      final nextIndex = (_cameraIndex + 1) % _cameras.length;
      _posesNotifier.value = const [];
      setState(() {
        _initializing = true;
      });
      await _teardownController();
      await _initControllerForIndex(nextIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _errorMessage = 'Failed to switch camera: $e';
      });
    } finally {
      _switching = false;
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingImage) return;
    _isProcessingImage = true;

    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) return;

      final poses = await _visionEngine.processImage(inputImage);
      if (!mounted) return;

      _latestImageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      if (poses.isNotEmpty) {
        _pushUpCounter.processPose(poses.first);
      }
      _posesNotifier.value = poses;
    } catch (_) {
      // Drop frame on conversion/inference errors; next frame will retry.
    } finally {
      _isProcessingImage = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final controller = _controller;
    if (controller == null) return null;
    final camera = _cameras[_cameraIndex];

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    } else {
      final deviceRotation =
          _deviceOrientationDegrees[controller.value.deviceOrientation];
      if (deviceRotation == null) return null;
      var rotationCompensation = deviceRotation;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation =
            (camera.sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (camera.sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;
    _latestRotation = rotation;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  double _metForBodyPart(String bodyPart) {
    switch (bodyPart.toLowerCase().trim()) {
      case 'chest':
      case 'back':
      case 'shoulders':
        return 3.8;
      case 'legs':
      case 'waist':
        return 5.0;
      case 'upper arms':
      case 'lower arms':
      case 'cardio':
        return 4.0;
      default:
        return 3.5;
    }
  }

  Future<void> _finishSession() async {
    if (_sessionFinished) return;
    _sessionFinished = true;

    final reps = _pushUpCounter.repCount.value;
    final durationSeconds =
        DateTime.now().difference(_sessionStartTime).inSeconds;

    final settingsBox = Hive.box('settings');
    final weight =
        (settingsBox.get('weight', defaultValue: 70.0) as num).toDouble();
    final calories =
        _metForBodyPart(widget.bodyPart) * weight * (durationSeconds / 3600);

    final box = Hive.box<WorkoutSession>('workout_sessions');
    await box.add(WorkoutSession(
      exerciseName: widget.exerciseName,
      repCount: reps,
      durationSeconds: durationSeconds,
      date: DateTime.now(),
      bodyPart: widget.bodyPart,
      calories: calories,
      exerciseId: widget.exerciseId,
    ));

    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SessionSummaryScreen(
          exerciseName: widget.exerciseName,
          repCount: reps,
          durationSeconds: durationSeconds,
          bodyPart: widget.bodyPart,
          calories: calories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canFlip = _cameras.length >= 2 && _errorMessage == null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finishSession();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF05050A),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildCameraLayer(),
            if (_controller != null && _errorMessage == null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: Center(
                  child: _RepCounterOverlay(repCount: _pushUpCounter.repCount),
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: _GlassCircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: _finishSession,
              ),
            ),
            if (canFlip)
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: _GlassCircleButton(
                  icon: Icons.flip_camera_ios_rounded,
                  onTap: _flipCamera,
                ),
              ),
            if (_controller != null && _errorMessage == null)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 104,
                left: 0,
                right: 0,
                child: Center(
                  child: _ManualRepButton(
                    onTap: () => _pushUpCounter.repCount.value =
                        _pushUpCounter.repCount.value + 1,
                  ),
                ),
              ),
            if (_controller != null && _errorMessage == null)
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                child: _DebugHud(textListenable: _pushUpCounter.debugNotifier),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final controller = _controller;
    if (_initializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
      );
    }

    final mediaSize = MediaQuery.of(context).size;
    var scale = mediaSize.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    final isFront =
        _cameras[_cameraIndex].lensDirection == CameraLensDirection.front;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Center(child: CameraPreview(controller)),
          ),
        ),
        Positioned.fill(
          child: ValueListenableBuilder<List<Pose>>(
            valueListenable: _posesNotifier,
            builder: (context, poses, _) {
              if (poses.isEmpty || _latestImageSize == Size.zero) {
                return const SizedBox.shrink();
              }
              return CustomPaint(
                painter: PosePainter(
                  poses: poses,
                  imageSize: _latestImageSize,
                  rotation: _latestRotation,
                  mirror: isFront,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RepCounterOverlay extends StatelessWidget {
  final ValueListenable<int> repCount;

  const _RepCounterOverlay({required this.repCount});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 14, 32, 18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: repCount,
                builder: (context, value, _) {
                  return Text(
                    '$value',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: 2,
                      fontFeatures: const [ui.FontFeature.tabularFigures()],
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                'REPS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebugHud extends StatelessWidget {
  final ValueListenable<String> textListenable;

  const _DebugHud({required this.textListenable});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: textListenable,
      builder: (context, text, _) {
        if (text.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF30E070).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: const Color(0xFF7CFFA3),
              height: 1.45,
            ),
          ),
        );
      },
    );
  }
}

class _ManualRepButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ManualRepButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF7C5CFF).withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF7C5CFF).withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'REP',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
