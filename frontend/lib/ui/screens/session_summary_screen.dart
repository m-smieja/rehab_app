import 'dart:math' show min;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehab_app/ui/screens/main_shell.dart';
import 'package:rehab_app/ui/widgets/muscle_map.dart';

class SessionSummaryScreen extends StatelessWidget {
  final String exerciseName;
  final int repCount;
  final int durationSeconds;
  final String bodyPart;
  final double calories;

  const SessionSummaryScreen({
    super.key,
    required this.exerciseName,
    required this.repCount,
    required this.durationSeconds,
    required this.bodyPart,
    required this.calories,
  });

  String get _formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _capitalizedName {
    if (exerciseName.isEmpty) return exerciseName;
    return exerciseName[0].toUpperCase() + exerciseName.substring(1);
  }

  int get _formQuality =>
      repCount > 0 ? min(100, 60 + repCount * 2) : 0;

  String get _pace => durationSeconds > 0
      ? ((repCount / durationSeconds) * 60).toStringAsFixed(1)
      : '—';

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _GlassIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SESSION COMPLETE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 18,
                    letterSpacing: 4,
                    color: const Color(0xFF7C5CFF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _capitalizedName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 28),
                _StatsRow(
                  repCount: repCount,
                  duration: _formattedDuration,
                  calories: calories,
                  pace: _pace,
                  formQuality: _formQuality,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'AI form analysis coming soon',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: SizedBox(
                    width: 110,
                    child: MuscleMap(bodyPart: bodyPart),
                  ),
                ),
                const SizedBox(height: 40),
                _PrimaryButton(
                  label: 'Done',
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 12),
                _SecondaryButton(
                  label: 'View History',
                  icon: Icons.history_rounded,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    MainShell.tabNotifier.value = 1;
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stats Row ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int repCount;
  final String duration;
  final double calories;
  final String pace;
  final int formQuality;

  const _StatsRow({
    required this.repCount,
    required this.duration,
    required this.calories,
    required this.pace,
    required this.formQuality,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _CompactStatTile(value: '$repCount', label: 'REPS'),
              _kDivider,
              _CompactStatTile(value: duration, label: 'TIME'),
              _kDivider,
              _CompactStatTile(
                  value: calories.toStringAsFixed(1), label: 'KCAL'),
              _kDivider,
              _CompactStatTile(value: pace, label: 'RPM'),
              _kDivider,
              _CompactStatTile(value: '$formQuality%', label: 'FORM'),
            ],
          ),
        ),
      ),
    );
  }

  static final _kDivider = Container(
    width: 1,
    height: 36,
    color: Colors.white.withValues(alpha: 0.1),
  );
}

class _CompactStatTile extends StatelessWidget {
  final String value;
  final String label;

  const _CompactStatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              color: Colors.white,
              height: 1.0,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Buttons ─────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C5CFF),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0xFF7C5CFF).withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

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
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
