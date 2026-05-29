import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehab_app/data/models/exercise.dart';
import 'package:rehab_app/data/models/workout_session.dart';
import 'package:rehab_app/ui/screens/exercise_detail_screen.dart';
import 'package:rehab_app/ui/widgets/muscle_map.dart';

class SessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const SessionDetailScreen({super.key, required this.session});

  static const _polishMonths = [
    'stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca',
    'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia',
  ];

  String get _formattedDate {
    final d = session.date;
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_polishMonths[d.month - 1]} ${d.year}, $h:$m';
  }

  String get _formattedDuration {
    final m = session.durationSeconds ~/ 60;
    final s = session.durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _formQuality =>
      session.repCount > 0 ? min(100, 60 + session.repCount * 2) : 0;

  String get _pace => session.durationSeconds > 0
      ? ((session.repCount / session.durationSeconds) * 60).toStringAsFixed(1)
      : '—';

  String get _capitalizedName {
    if (session.exerciseName.isEmpty) return session.exerciseName;
    return session.exerciseName[0].toUpperCase() +
        session.exerciseName.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _capitalizedName,
                        style: textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formattedDate,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 28),
                      _buildSectionLabel('FORM QUALITY'),
                      const SizedBox(height: 16),
                      _buildFormQualityIndicator(),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'AI form analysis coming soon',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildSectionLabel('MUSCLES TRAINED'),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: 110,
                          child: MuscleMap(bodyPart: session.bodyPart),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildDoAgainButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _StatTile(value: '${session.repCount}', label: 'REPS'),
          _kDivider,
          _StatTile(value: _formattedDuration, label: 'TIME'),
          _kDivider,
          _StatTile(
              value: session.calories.toStringAsFixed(1), label: 'KCAL'),
          _kDivider,
          _StatTile(value: _pace, label: 'RPM'),
        ],
      ),
    );
  }

  static final _kDivider = Container(
    width: 1,
    height: 36,
    color: Colors.white.withValues(alpha: 0.08),
  );

  Widget _buildFormQualityIndicator() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: _formQuality / 100,
              strokeWidth: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFF)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_formQuality%',
                style: GoogleFonts.bebasNeue(
                  fontSize: 38,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'FORM',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 3,
        color: Colors.white.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildDoAgainButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExerciseDetailScreen(
            exercise: Exercise(
              id: session.exerciseId,
              name: session.exerciseName,
              bodyPart: session.bodyPart,
              target: '',
            ),
          ),
        ),
      ),
      icon: const Icon(Icons.replay_rounded, size: 20),
      label: Text(
        'Zrób to ponownie',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
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

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 30,
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
