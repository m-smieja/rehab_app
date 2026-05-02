import 'package:flutter/material.dart';
import 'package:rehab_app/data/models/exercise.dart';
import 'package:rehab_app/data/services/api_service.dart';
import 'package:rehab_app/ui/screens/camera_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  String get _capitalizedName {
    if (exercise.name.isEmpty) return exercise.name;
    return exercise.name[0].toUpperCase() + exercise.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final gifUrl = ApiService.gifUrl(exercise.id);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF2A1B54),
              Color(0xFF0F172A),
              Color(0xFF05050A),
            ],
            center: Alignment.topLeft,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            gifUrl,
                            fit: BoxFit.contain,
                            headers: ApiService.authHeaders,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white
                                      .withValues(alpha: 0.85),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) => Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color:
                                    Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        _capitalizedName,
                        style: textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (exercise.bodyPart.isNotEmpty)
                            _MetaChip(label: exercise.bodyPart),
                          if (exercise.target.isNotEmpty)
                            _MetaChip(label: exercise.target),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _DetailButton(
                        label: 'Manual Log',
                        icon: Icons.edit_note_rounded,
                        primary: false,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text('Manual logging coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _DetailButton(
                        label: 'Start AI Tracker',
                        icon: Icons.center_focus_strong_rounded,
                        primary: true,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(
                              exerciseName: exercise.name,
                              bodyPart: exercise.bodyPart,
                              exerciseId: exercise.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onPressed;

  const _DetailButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final background = primary
        ? const Color(0xFF7C5CFF)
        : Colors.white.withValues(alpha: 0.05);
    final borderColor = primary
        ? const Color(0xFF7C5CFF)
        : Colors.white.withValues(alpha: 0.12);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: primary ? 4 : 0,
        shadowColor: primary
            ? const Color(0xFF7C5CFF).withValues(alpha: 0.5)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
